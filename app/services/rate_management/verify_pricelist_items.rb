# frozen_string_literal: true

module RateManagement
  class VerifyPricelistItems < VerifyAttributesList
    parameter :pricelist, required: true
    delegate :project, to: :pricelist
    self.row_number_offset = 2 # row with index 0 will have row_number 2 (first line always header)

    NOT_TAGGED = 'not tagged'

    verify_attribute :prefix, apply: lambda { |prefix, row_number|
      add_error('Prefix must be exist', row_number) if prefix.nil?
      add_error('Prefix space is not allowed', row_number) if /\s/.match?(prefix)

      prefix
    }

    verify_attribute :routing_tag_names, apply: lambda { |routing_tag_names, row_number|
      return project.routing_tag_ids if routing_tag_names.nil?
      return [] if routing_tag_names == NOT_TAGGED

      routing_tag_ids = routing_tag_names.split(',').map do |routing_tag_name|
        routing_tag_name = routing_tag_name.lstrip

        # when at least one routing_tag_name is invalid do not check others
        unless routing_tags_hash.key?(routing_tag_name)
          add_error('Routing tag names are invalid', row_number)
          return # rubocop:disable Lint/NonLocalExitFromIterator
        end

        routing_tags_hash[routing_tag_name]
      end
      RoutingTagsSort.call(routing_tag_ids)
    }

    verify_attribute :routing_tag_mode, apply: lambda { |routing_tag_mode, row_number|
      if routing_tag_mode.nil?
        add_error("Routing tag mode can't be blank", row_number) if project.routing_tag_mode_id.nil?
        return project.routing_tag_mode_id
      end

      routing_tag_mode_id = Routing::RoutingTagMode::MODES.invert[routing_tag_mode]
      add_error('Routing tag mode is invalid', row_number) if routing_tag_mode_id.nil?
      routing_tag_mode_id
    }

    verify_attribute :initial_rate, apply: lambda { |initial_rate, row_number|
      if initial_rate.nil?
        add_error("Initial rate can't be blank", row_number)
        return
      end

      initial_rate = convert_to_decimal(initial_rate)
      if initial_rate.nil?
        add_error('Initial rate is not a number', row_number)
        return
      end

      initial_rate
    }

    verify_attribute :next_rate, apply: lambda { |next_rate, row_number|
      if next_rate.nil?
        add_error("Next rate can't be blank", row_number)
        return
      end

      next_rate = convert_to_decimal(next_rate)
      if next_rate.nil?
        add_error('Next rate is not a number', row_number)
        return
      end

      next_rate
    }

    verify_attribute :connect_fee, apply: lambda { |connect_fee, row_number|
      if connect_fee.nil?
        add_error("Connect fee can't be blank", row_number)
        return
      end

      connect_fee = convert_to_decimal(connect_fee)
      if connect_fee.nil?
        add_error('Connect fee is not a number', row_number)
        return
      end

      connect_fee
    }

    verify_attribute :dst_number_min_length, apply: lambda { |dst_number_min_length, row_number|
      return project.dst_number_min_length if dst_number_min_length.nil?

      dst_number_min_length = convert_to_integer(dst_number_min_length)
      if dst_number_min_length.nil?
        add_error('Dst number min length must be an integer', row_number)
        return
      end

      add_error('Dst number min length must be greater or equal to 0 and less or equal to 100', row_number) if dst_number_min_length.negative? || dst_number_min_length >= 100
      dst_number_min_length
    }

    verify_attribute :dst_number_max_length, apply: lambda { |dst_number_max_length, row_number|
      return project.dst_number_max_length if dst_number_max_length.nil?

      dst_number_max_length = convert_to_integer(dst_number_max_length)
      if dst_number_max_length.nil?
        add_error('Dst number max length must be an integer', row_number)
        return
      end

      add_error('Dst number max length must be greater or equal to 0 and less or equal to 100', row_number) if dst_number_max_length.negative? || dst_number_max_length >= 100
      dst_number_max_length
    }

    verify_attribute :initial_interval, apply: lambda { |initial_interval, row_number|
      if initial_interval.nil?
        add_error("Initial interval can't be blank", row_number) if project.initial_interval.nil?
        return project.initial_interval
      end

      initial_interval = convert_to_integer(initial_interval)
      if initial_interval.nil?
        add_error('Initial interval must be an integer', row_number)
        return
      end

      add_error('Initial interval must be greater or equal to 0', row_number) if initial_interval.negative?
      initial_interval
    }

    verify_attribute :next_interval, apply: lambda { |next_interval, row_number|
      if next_interval.nil?
        add_error("Next interval can't be blank", row_number) if project.next_interval.nil?
        return project.next_interval
      end

      next_interval = convert_to_integer(next_interval)
      if next_interval.nil?
        add_error('Next interval must be an integer', row_number)
        return
      end

      add_error('Next interval must be greater or equal to 0', row_number) if next_interval.negative?
      next_interval
    }

    verify_attribute :enabled, apply: lambda { |enabled, row_number|
      return if enabled.nil?

      enabled = convert_to_boolean(enabled)
      add_error('Enabled is invalid', row_number) if enabled.nil?
      enabled
    }

    verify_attribute :priority, apply: lambda { |priority, row_number|
      return if priority.nil?

      priority = convert_to_integer(priority)
      add_error('Priority must be an integer', row_number) if priority.nil?
      priority
    }

    verify_attribute :valid_from, apply: lambda { |valid_from, row_number|
      return pricelist.valid_from if valid_from.nil?

      valid_from = convert_to_time(valid_from)
      if valid_from.nil?
        add_error('Valid from is invalid', row_number)
        return
      end

      add_error('Valid from must be in future', row_number) unless valid_from.future?
      add_error('Valid from must be less than Pricelist Valid till', row_number) if valid_from >= pricelist.valid_till
      valid_from
    }

    verify_items apply: lambda { |items|
      uniq_map = {}
      items.each_with_index do |attrs, index|
        item = attrs.values_at(:prefix, :routing_tag_ids)
        uniq_map[item] ||= []
        uniq_map[item] << index + row_number_offset # row number
      end

      uniq_map.each_value do |row_numbers|
        next if row_numbers.size == 1

        add_error 'has duplicates', row_numbers.join(':')
      end
    }

    private

    def process_attributes(attributes, row_number)
      {
        prefix: verify_attribute(:prefix, attributes, row_number: row_number),
        initial_rate: verify_attribute(:initial_rate, attributes, row_number: row_number),
        next_rate: verify_attribute(:next_rate, attributes, row_number: row_number),
        connect_fee: verify_attribute(:connect_fee, attributes, row_number: row_number),
        routing_tag_ids: verify_attribute(:routing_tag_names, attributes, row_number: row_number),
        routing_tag_mode_id: verify_attribute(:routing_tag_mode, attributes, row_number: row_number),
        dst_number_min_length: verify_attribute(:dst_number_min_length, attributes, row_number: row_number),
        dst_number_max_length: verify_attribute(:dst_number_max_length, attributes, row_number: row_number),
        initial_interval: verify_attribute(:initial_interval, attributes, row_number: row_number),
        next_interval: verify_attribute(:next_interval, attributes, row_number: row_number),
        enabled: verify_attribute(:enabled, attributes, row_number: row_number),
        priority: verify_attribute(:priority, attributes, row_number: row_number),
        valid_from: verify_attribute(:valid_from, attributes, row_number: row_number),
        src_rewrite_rule: project.src_rewrite_rule,
        dst_rewrite_rule: project.dst_rewrite_rule,
        src_rewrite_result: project.src_rewrite_result,
        dst_rewrite_result: project.dst_rewrite_result,
        src_name_rewrite_rule: project.src_name_rewrite_rule,
        src_name_rewrite_result: project.src_name_rewrite_result,
        asr_limit: project.asr_limit,
        acd_limit: project.acd_limit,
        capacity: project.capacity,
        lcr_rate_multiplier: project.lcr_rate_multiplier,
        force_hit_rate: project.force_hit_rate,
        short_calls_limit: project.short_calls_limit,
        exclusive_route: project.exclusive_route,
        reverse_billing: project.reverse_billing,
        gateway_id: project.gateway_id,
        gateway_group_id: project.gateway_group_id,
        account_id: project.account_id,
        vendor_id: project.vendor_id,
        routing_group_id: project.routing_group_id,
        routeset_discriminator_id: project.routeset_discriminator_id,
        pricelist_id: pricelist.id,
        valid_till: pricelist.valid_till
      }
    end

    define_memoizable :routing_tags_hash, apply: lambda {
      Routing::RoutingTag.pluck(:name, :id).to_h.merge(Routing::RoutingTag::ANY_TAG => nil)
    }

    # @return [Array<String>]
    def build_error_lines
      @errors.map do |message, row_numbers|
        "#{message} for row#{'s' if row_numbers.size > 1} #{row_numbers.join(', ')}"
      end
    end
  end
end
