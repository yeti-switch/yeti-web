# frozen_string_literal: true

module RateManagement
  class ApplyPricelist < ApplicationService
    parameter :pricelist, required: true

    Error = Class.new(StandardError)

    SCOPE_FIELDS = %w[vendor_id account_id routing_group_id routeset_discriminator_id].freeze
    DATA_FIELDS = %w[
      enabled
      prefix
      src_rewrite_rule
      dst_rewrite_rule
      acd_limit
      asr_limit
      gateway_id
      next_rate
      connect_fee
      src_rewrite_result
      dst_rewrite_result
      priority
      capacity
      lcr_rate_multiplier
      initial_rate
      initial_interval
      next_interval
      gateway_group_id
      force_hit_rate
      short_calls_limit
      src_name_rewrite_rule
      src_name_rewrite_result
      exclusive_route
      dst_number_min_length
      dst_number_max_length
      reverse_billing
      routing_tag_ids
      routing_tag_mode_id
    ].freeze
    NEXT_RATE_FIELDS = %w[connect_fee initial_interval next_interval initial_rate next_rate].freeze
    NON_NEXT_RATE_FIELDS = DATA_FIELDS - NEXT_RATE_FIELDS

    def call
      pricelist.with_lock do
        raise_if_invalid!

        prepare_items!

        create_new_dialpeers!
        delete_dialpeers!
        update_dialpeers!
        create_next_rates!

        # We need to nullify foreign key dialpeer_id
        # because after pricelist applied we keep it and its items for N days.
        # But after pricelist applied we need to have possibility to delete any related dialpeer.
        # We will still have dialpeer.id in detected_dialpeer_ids for types CHANGE and DELETE.
        pricelist.items.where.not(dialpeer_id: nil).update_all(dialpeer_id: nil)

        pricelist.update!(
          state_id: RateManagement::Pricelist::CONST::STATE_ID_APPLIED,
          applied_at: Time.zone.now,
          apply_changes_in_progress: false
        )
      end
    end

    private

    def raise_if_invalid!
      raise Error, 'Pricelist must be in dialpeers detected state' unless pricelist.dialpeers_detected?
      raise Error, 'Pricelist must be without error items' if pricelist.items.with_error.any?
      raise Error, 'Pricelist valid_till must be in the future' unless pricelist.valid_till.future?
    end

    def prepare_items!
      pricelist.items.where('valid_from IS NULL OR valid_from < NOW()').update_all('valid_from = NOW()')

      items_dialpeer_ids = pricelist.items.to_change.joins(:dialpeer)
                                    .where('dialpeers.valid_from >= pricelist_items.valid_from').pluck(:id, :dialpeer_id).to_h
      RateManagement::PricelistItem.where(id: items_dialpeer_ids.keys).update_all(dialpeer_id: nil, detected_dialpeer_ids: [])
      DialpeerNextRate.delete_by(dialpeer_id: items_dialpeer_ids.values)
      Dialpeer.delete_by(id: items_dialpeer_ids.values)
    end

    def create_new_dialpeers!
      SqlCaller::Yeti.execute <<-SQL.squish
        INSERT INTO class4.dialpeers
          (#{(DATA_FIELDS + SCOPE_FIELDS).join(', ')}, valid_till, valid_from, network_prefix_id)
        SELECT
          #{(DATA_FIELDS + SCOPE_FIELDS).join(', ')}, valid_till, valid_from, network_prefix_id
        FROM (
          SELECT
            #{(DATA_FIELDS + SCOPE_FIELDS).map { |field| "pricelist_items.#{field}" }.join(', ')},
            valid_till,
            valid_from,
            sys.network_prefixes.id AS network_prefix_id,
            ROW_NUMBER() OVER (
              PARTITION BY pricelist_items.id
              ORDER BY LENGTH(network_prefixes.prefix) DESC
            )
          FROM ratemanagement.pricelist_items
          LEFT JOIN sys.network_prefixes
            ON prefix_range(sys.network_prefixes.prefix)@>prefix_range(pricelist_items.prefix)
          WHERE
            pricelist_id = #{pricelist.id} AND
            dialpeer_id IS NULL
        ) r
        WHERE ROW_NUMBER = 1
      SQL
    end

    def delete_dialpeers!
      dialpeer_ids = pricelist.items.to_delete.pluck(:dialpeer_id)
      return if dialpeer_ids.empty?

      SqlCaller::Yeti.execute <<-SQL.squish
        UPDATE class4.dialpeers
          SET valid_till = pricelist_items.valid_from
          FROM ratemanagement.pricelist_items
          WHERE
              dialpeers.id = pricelist_items.dialpeer_id
              AND pricelist_items.pricelist_id = #{pricelist.id}
              AND dialpeers.id IN (#{dialpeer_ids.join(', ')})
      SQL

      pricelist.items.to_delete.update_all(dialpeer_id: nil)
      for_delete_dialpeer_ids = Dialpeer.where(id: dialpeer_ids)
                                        .without_ratemanagement_pricelist_items
                                        .where('valid_till <= NOW() OR valid_from >= valid_till')
                                        .pluck(:id)
      DeleteDialpeers.call(dialpeer_ids: for_delete_dialpeer_ids)
    end

    def update_dialpeers!
      SqlCaller::Yeti.execute <<-SQL.squish
        UPDATE class4.dialpeers
        SET valid_till = pricelist_items.valid_from
          FROM ratemanagement.pricelist_items
          WHERE
            dialpeers.id = pricelist_items.dialpeer_id
            AND pricelist_items.pricelist_id = #{pricelist.id}
            AND NOT pricelist_items.to_delete
            AND (#{NON_NEXT_RATE_FIELDS.map { |field| "pricelist_items.#{field}" }.join(', ')})
                IS DISTINCT FROM
                (#{NON_NEXT_RATE_FIELDS.map { |field| "dialpeers.#{field}" }.join(', ')})
      SQL

      SqlCaller::Yeti.execute <<-SQL.squish
        INSERT INTO class4.dialpeers(#{(DATA_FIELDS + SCOPE_FIELDS).join(', ')}, valid_till, valid_from, network_prefix_id)
        SELECT
          #{(DATA_FIELDS + SCOPE_FIELDS).map { |field| "pricelist_items.#{field}" }.join(', ')},
          pricelist_items.valid_till,
          pricelist_items.valid_from,
          dialpeers.network_prefix_id
        FROM ratemanagement.pricelist_items
        INNER JOIN class4.dialpeers ON dialpeers.id = pricelist_items.dialpeer_id
        WHERE
          pricelist_items.pricelist_id = #{pricelist.id}
          AND NOT pricelist_items.to_delete
          AND (#{NON_NEXT_RATE_FIELDS.map { |field| "pricelist_items.#{field}" }.join(', ')})
              IS DISTINCT FROM
              (#{NON_NEXT_RATE_FIELDS.map { |field| "dialpeers.#{field}" }.join(', ')})
      SQL
    end

    def create_next_rates!
      SqlCaller::Yeti.execute <<-SQL.squish
        UPDATE dialpeers
        SET valid_till = pricelist_items.valid_till
        FROM ratemanagement.pricelist_items
        WHERE
          dialpeers.id = pricelist_items.dialpeer_id
          AND pricelist_items.pricelist_id = #{pricelist.id}
          AND NOT pricelist_items.to_delete
          AND (#{NON_NEXT_RATE_FIELDS.map { |field| "pricelist_items.#{field}" }.join(', ')})
          IS NOT DISTINCT FROM
          (#{NON_NEXT_RATE_FIELDS.map { |field| "dialpeers.#{field}" }.join(', ')})
      SQL

      SqlCaller::Yeti.execute <<-SQL.squish
        INSERT INTO class4.dialpeer_next_rates(
                              dialpeer_id,
                              apply_time,
                              created_at,
                              #{NEXT_RATE_FIELDS.join(', ')}
                            )
        SELECT
          dialpeers.id,
          pricelist_items.valid_from,
          NOW(),
          #{NEXT_RATE_FIELDS.map { |field| "pricelist_items.#{field}" }.join(', ')}
        FROM class4.dialpeers
        INNER JOIN ratemanagement.pricelist_items ON dialpeers.id = pricelist_items.dialpeer_id
        WHERE
          pricelist_items.pricelist_id = #{pricelist.id}
          AND NOT pricelist_items.to_delete
          AND (#{NON_NEXT_RATE_FIELDS.map { |field| "pricelist_items.#{field}" }.join(', ')})
              IS NOT DISTINCT FROM
              (#{NON_NEXT_RATE_FIELDS.map { |field| "dialpeers.#{field}" }.join(', ')})
          AND (#{NEXT_RATE_FIELDS.map { |field| "pricelist_items.#{field}" }.join(', ')})
              IS DISTINCT FROM
              (#{NEXT_RATE_FIELDS.map { |field| "dialpeers.#{field}" }.join(', ')})
      SQL
    end
  end
end
