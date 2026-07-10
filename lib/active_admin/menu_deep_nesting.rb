# frozen_string_literal: true

# Restores multi-level menu nesting, which ActiveAdmin 4 removed ("Deeply nested
# submenus has been reverted. Only one level nested menu is supported").
#
# yeti-web groups resources two levels deep — `menu parent: %w[Billing Settings]`
# renders Billing > Settings > Currencies — in 19 app/admin files.
#
# Two methods were dropped from ActiveAdmin::Menu::MenuNode in 4.0; both are
# restored verbatim from 3.5.1. They are needed together:
#
#   #add       walks a parent chain, creating intermediate menus as it goes.
#              Without it, an Array parent raises
#              "TypeError: Array isn't supported as a Menu ID" from normalize_id.
#
#   #include?  recurses into descendants. Without it a grandchild never marks its
#              ancestors current, so visiting /currencies would not highlight the
#              top-level "Billing" item (current_menu_item? -> current? -> include?).
#
# MenuItem includes Menu::MenuNode too, so reopening the module reaches both.
# ActiveAdmin 4's `current?(item, children:)` keyword is deliberately left alone —
# the navigation partials call it with `children: false` for the parent link.
require 'active_admin/menu'

module ActiveAdmin
  class Menu
    module MenuNode
      # Recursively builds any given menu items. Supports a chain of parents:
      #   menu.add parent: %w[Billing Settings], label: 'Currencies'
      def add(options)
        options = options.dup # Make sure parameter is not modified
        parent_chain = Array.wrap(options.delete(:parent))

        item = if (parent = parent_chain.shift)
                 options[:parent] = parent_chain if parent_chain.any?
                 (self[parent] || add(label: parent)).add options
               else
                 _add options.merge parent: self
               end

        yield(item) if block_given?

        item
      end

      # Whether this node or any descendant matches the given item.
      def include?(item)
        @children.value?(item) || @children.values.any? { |child| child.include?(item) }
      end
    end
  end
end
