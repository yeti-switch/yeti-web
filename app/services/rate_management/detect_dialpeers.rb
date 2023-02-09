# frozen_string_literal: true

module RateManagement
  class DetectDialpeers < ApplicationService
    parameter :pricelist, required: true
    delegate :project, to: :pricelist

    Error = Class.new(StandardError)

    def call
      pricelist.with_lock do
        raise_if_invalid!

        detect_dialpeers!
        apply_not_detected_items_enabled!
        apply_detected_items_enabled!
        apply_detected_items_priority!
        apply_not_detected_items_priority!
        create_to_delete_items!
        pricelist.update!(
          state_id: RateManagement::Pricelist::CONST::STATE_ID_DIALPEERS_DETECTED,
          detect_dialpeers_in_progress: false,
          items_count: pricelist.items.count
        )
      end
    end

    private

    def raise_if_invalid!
      raise Error, 'Pricelist must be in New state' unless pricelist.new?
    end

    def detect_dialpeers!
      SqlCaller::Yeti.execute <<-SQL
          WITH dp_cte (id, detected_dialpeer_ids) AS (
            SELECT
              items.id,
              ARRAY_AGG(dialpeers.id) AS detected_dialpeer_ids
            FROM
              ratemanagement.pricelist_items AS items
            INNER JOIN class4.dialpeers ON
              dialpeers.vendor_id = #{project.vendor_id}
              AND dialpeers.account_id = #{project.account_id}
              AND dialpeers.routing_group_id = #{project.routing_group_id}
              AND dialpeers.routeset_discriminator_id = #{project.routeset_discriminator_id}
              AND dialpeers.prefix = items.prefix
              AND dialpeers.routing_tag_ids = items.routing_tag_ids
            WHERE
              items.pricelist_id = #{pricelist.id}
            GROUP BY
              items.id
          )
          UPDATE ratemanagement.pricelist_items
          SET detected_dialpeer_ids = dp_cte.detected_dialpeer_ids
          FROM dp_cte
          WHERE pricelist_items.id = dp_cte.id;
      SQL

      SqlCaller::Yeti.execute <<-SQL
        UPDATE ratemanagement.pricelist_items
        SET dialpeer_id = detected_dialpeer_ids[1]
        WHERE
          pricelist_id = #{pricelist.id}
          AND ARRAY_LENGTH(detected_dialpeer_ids, 1) = 1
      SQL
    end

    def apply_not_detected_items_enabled!
      pricelist.items.to_create.where(enabled: nil).update_all(enabled: project.enabled)
    end

    def apply_detected_items_enabled!
      if pricelist.retain_enabled
        SqlCaller::Yeti.execute <<-SQL
          UPDATE ratemanagement.pricelist_items SET enabled = dialpeers.enabled
          FROM class4.dialpeers
          WHERE
            pricelist_items.pricelist_id = #{pricelist.id} AND
            pricelist_items.dialpeer_id IS NOT NULL AND
            pricelist_items.enabled IS NULL AND
            pricelist_items.dialpeer_id = dialpeers.id
        SQL
      else
        pricelist.items.to_change.where(enabled: nil).update_all(enabled: project.enabled)
      end
    end

    def apply_not_detected_items_priority!
      pricelist.items.to_create.where(priority: nil).update_all(priority: project.priority)
    end

    def apply_detected_items_priority!
      if pricelist.retain_priority
        SqlCaller::Yeti.execute <<-SQL
          UPDATE ratemanagement.pricelist_items SET priority = dialpeers.priority
          FROM class4.dialpeers
          WHERE
            pricelist_items.pricelist_id = #{pricelist.id} AND
            pricelist_items.dialpeer_id IS NOT NULL AND
            pricelist_items.priority IS NULL AND
            pricelist_items.dialpeer_id = dialpeers.id
        SQL
      else
        pricelist.items.to_change.where(priority: nil).update_all(priority: project.priority)
      end
    end

    def create_to_delete_items!
      SqlCaller::Yeti.execute <<-SQL
        INSERT INTO ratemanagement.pricelist_items (
          enabled,
          prefix,
          src_rewrite_rule,
          dst_rewrite_rule,
          acd_limit,
          asr_limit,
          gateway_id,
          routing_group_id,
          next_rate,
          connect_fee,
          vendor_id,
          account_id,
          src_rewrite_result,
          dst_rewrite_result,
          priority,
          capacity,
          lcr_rate_multiplier,
          initial_rate,
          initial_interval,
          next_interval,
          valid_from,
          valid_till,
          gateway_group_id,
          force_hit_rate,
          short_calls_limit,
          src_name_rewrite_rule,
          src_name_rewrite_result,
          exclusive_route,
          dst_number_min_length,
          dst_number_max_length,
          reverse_billing,
          routing_tag_ids,
          routing_tag_mode_id,
          routeset_discriminator_id,
          pricelist_id,
          dialpeer_id,
          detected_dialpeer_ids,
          to_delete
        )
        SELECT
          dialpeers.enabled,
          dialpeers.prefix,
          dialpeers.src_rewrite_rule,
          dialpeers.dst_rewrite_rule,
          dialpeers.acd_limit,
          dialpeers.asr_limit,
          dialpeers.gateway_id,
          dialpeers.routing_group_id,
          dialpeers.next_rate,
          dialpeers.connect_fee,
          dialpeers.vendor_id,
          dialpeers.account_id,
          dialpeers.src_rewrite_result,
          dialpeers.dst_rewrite_result,
          dialpeers.priority,
          dialpeers.capacity,
          dialpeers.lcr_rate_multiplier,
          dialpeers.initial_rate,
          dialpeers.initial_interval,
          dialpeers.next_interval,
          dialpeers.valid_from,
          dialpeers.valid_till,
          dialpeers.gateway_group_id,
          dialpeers.force_hit_rate,
          dialpeers.short_calls_limit,
          dialpeers.src_name_rewrite_rule,
          dialpeers.src_name_rewrite_result,
          dialpeers.exclusive_route,
          dialpeers.dst_number_min_length,
          dialpeers.dst_number_max_length,
          dialpeers.reverse_billing,
          dialpeers.routing_tag_ids,
          dialpeers.routing_tag_mode_id,
          dialpeers.routeset_discriminator_id,
          #{pricelist.id},
          dialpeers.id,
          ARRAY[dialpeers.id],
          true
        FROM
          class4.dialpeers
        WHERE
          dialpeers.id NOT IN (
            SELECT unnest(detected_dialpeer_ids) FROM ratemanagement.pricelist_items WHERE pricelist_id = #{pricelist.id}
          )
          AND dialpeers.vendor_id = #{project.vendor_id}
          AND dialpeers.account_id = #{project.account_id}
          AND dialpeers.routing_group_id = #{project.routing_group_id}
          AND dialpeers.routeset_discriminator_id = #{project.routeset_discriminator_id}
      SQL
    end
  end
end
