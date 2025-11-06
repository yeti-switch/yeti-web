# frozen_string_literal: true

##
# patch the main filter method defined inside ActiveAdmin gem active_admin/filters/dsl.rb:7
# so we can prepend into original module ActiveAdmin::Filters::DSL
module ActiveAdminFilterBlock
  # Override filter to accept block-style DSL
  #
  # ** ajax.auto_fill_in_related_filters - config defines what dependent filters will be defined
  # as children. And this children will be fill in their options automatically on dropdown open
  # throughout AJAX request.
  #
  # Example:
  #
  # filter :customer_id do
  #   as :tom_select
  #   ajax resource: 'Customer', auto_fill_in_related_filters: [:contact_id]
  # end
  #
  # filter :contact_id do
  #   as :tom_select
  #   ajax resource: 'Contact', parent_filter: :customer_id
  # end
  #
  #
  # ** ajax.related_filters - config defines what dependent filters will be defined
  # as children. And this child filters will load their options throughout AJAX by using
  # the query parameter to fetch only this records that belongs to parent filter.
  # For example, we have Contractor filter parent :contractor_id and child :gateway_id filter
  # once user choose Contractor and then user search gateway this AJAX request will be performed
  # GET /gateways/all_options?q[contractor_id]=3
  #
  # Example:
  # filter :customer_id do
  #   as :tom_select
  #   ajax resource: 'Customer', related_filters: [:contact_id]
  # end
  #
  # filter :contact_id do
  #   as :tom_select
  #   ajax resource: 'Contact', parent_filter: :customer_id
  # end
  def filter(attribute, options = {}, &block)
    if block_given?
      builder = ActiveAdmin::FilterBuilder.new(options)
      # Evaluate DSL methods (ajax, ajax_params, as, label, etc.) inside the builder
      builder.instance_eval(&block)
      # Delegate to the original implementation (which calls config.add_filter)
      super(attribute, builder.to_options)
    else
      super(attribute, options)
    end
  end

  # Provide a `filters do ... end` wrapper that lets you group multiple filter calls.
  # If ActiveAdmin already implements a filters method elsewhere, calling super() will
  # delegate to it; otherwise we just instance_eval the block and return nil.
  def filters(&block)
    if block_given?
      instance_eval(&block)
    else
      begin
        super()
      rescue NoMethodError
        nil
      end
    end
  end
end
