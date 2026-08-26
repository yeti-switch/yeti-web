# frozen_string_literal: true

# Restores `attributes_table { row :attr, class: 'x' }`.
#
# ActiveAdmin 3's AttributesTable#row called `args.extract_options!` FIRST and
# used `options[:class]` for the <tr>:
#
#   title   = args[0]
#   options = args.extract_options!
#   classes = [:row]; classes << options[:class] if options[:class]
#
# ActiveAdmin 4 resolves the data source before extracting:
#
#   title   = args[0]
#   data    = args[1] || args[0]     # <- picks up the options hash
#   options = args.extract_options!
#
# so `row :auth_password, class: 'password-mask'` passes the hash as the value to
# render and dies with "{...} is not a symbol nor a string". Extract the options
# first, exactly as AA3 did, then let the gem do the rest.
#
# AA4 also stopped putting `row` on the <tr> (it identifies rows by `data-row`
# now); the class given here is still applied, which is what
# app/assets/javascripts/password-toggle.js hooks.

require 'active_admin/views/components/attributes_table'

module ActiveAdmin
  module Views
    module AttributesTableRowOptions
      # A copy of ActiveAdmin 4's AttributesTable#row with `extract_options!`
      # moved above the `data` lookup. Delegating with `super` is not possible:
      # the gem's signature is `row(*args, &block)`, so any hash passed back —
      # positionally or as keywords — lands in `args` again and is re-read as the
      # data source. Keep in sync with the gem on upgrade.
      def row(*args, &block)
        options = args.extract_options!
        title = args[0]
        data = args[1] || args[0]
        options['data-row'] = title.to_s.parameterize(separator: '_') if title.present?

        @table << tr(options) do
          th do
            header_content_for(title)
          end
          @collection.each do |record|
            td do
              content_for(record, block || data)
            end
          end
        end
      end
    end
  end
end

ActiveAdmin::Views::AttributesTable.prepend(ActiveAdmin::Views::AttributesTableRowOptions)
