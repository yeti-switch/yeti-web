# frozen_string_literal: true

# ActiveAdmin 4 removed the `columns` component in favour of plain divs with
# Tailwind classes. app/admin still uses `columns { column { ... } }` in ~14
# resources, so it is restored here as an equal-width responsive grid.
#
# The AA3 component supported `column(span: n)`; nothing in this app used it, so
# it is not implemented. Add a `col-span-*` class if that changes.
module ActiveAdmin
  module Views
    class Columns < ActiveAdmin::Component
      builder_method :columns

      def build(*args)
        super
        add_class 'grid grid-cols-1 md:grid-flow-col md:auto-cols-fr gap-4 mb-4'
      end

      def column(*args, &block)
        insert_tag(Arbre::HTML::Div, *args, &block)
      end
    end
  end
end
