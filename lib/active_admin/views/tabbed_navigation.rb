# frozen_string_literal: true

class ::ActiveAdmin::Views::TabbedNavigation
  def priority_for(item)
    child_item = item.children.detect { |child| display_item?(child) }
    child_item ? child_item.priority : item.priority
  end

  private :priority_for

  # Returns an Array of items to display
  def displayable_items(items)
    items.select do |item|
      display_item? item
    end.sort { |i1, i2| priority_for(i1) <=> priority_for(i2) }
  end
end
