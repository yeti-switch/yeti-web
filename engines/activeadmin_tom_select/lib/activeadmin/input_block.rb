# frozen_string_literal: true

# Patch to allow ActiveAdmin form inputs to accept block-style DSL
# This module will be prepended to ActiveAdmin::Views::ActiveAdminForm
module ActiveAdminInputBlock
  # Override input to accept block-style DSL
  # Example 1
  #
  # form do |f|
  #   f.inputs do
  #     f.input :customer_id do
  #       as :tom_select
  #       ajax resource: 'Customer', related_filters: :customer_id
  #     end
  #
  #    f.input :contact_id do
  #      as :tom_select
  #      ajax resource: 'Contact', parent_filter: :customer_id
  #    end
  #   end
  # end
  #
  # Example 2
  #
  # form do |f|
  #   f.inputs do
  #     f.input :customer_id do
  #       as :tom_select
  #       ajax resource: 'Customer', auto_fill_in_related_filters: :customer_id
  #     end
  #
  #    f.input :contact_id do
  #      as :tom_select
  #      ajax resource: 'Contact', parent_filter: :customer_id
  #    end
  #   end
  # end
  def input(*args, &block)
    if block_given?
      # Extract the attribute name (first argument)
      attribute = args.shift
      options = args.extract_options!

      # Create a builder to collect DSL options
      builder = ActiveAdmin::InputBuilder.new(options)

      # Evaluate DSL methods (as, ajax, label, etc.) inside the builder
      builder.instance_eval(&block)

      # Merge the builder options back and delegate to original implementation
      merged_options = builder.to_options

      # Call the original input method with merged options
      proxy_call_to_form(:input, attribute, merged_options)
    else
      # No block given, call original implementation
      super(*args)
    end
  end
end
