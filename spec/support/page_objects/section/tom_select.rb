# frozen_string_literal: true

module Section
  class TomSelect < SitePrism::Section
    class Control < SitePrism::Section
      class MultiItem < SitePrism::Section
        set_default_search_arguments '.item'

        element :item_text, '.item-text'
        element :remove_btn, '.remove'
      end

      set_default_search_arguments '.ts-control'

      # for single
      element :item, '.item'

      # for multiple
      elements :items_texts, '.item .item-text'
      sections :items, MultiItem

      # if .plugin-clear_button
      element :clear_btn, '.clear-button'

      def has_items_with_text?(texts)
        RSpec::Matchers::BuiltIn::Satisfy.new(nil) do
          actual_texts = items(minimum: texts.size, maximum: texts.size).map { |n| n.item_text.text }
          expect(actual_texts).to match_array(texts)
        end
      end

      def has_item_with_text?(text)
        has_item? && has_item?(exact_text: text)
      end

      def find_item_by_text(text, exact: true)
        item_text_node = items_texts(text:, exact_text: exact, minimum: 1, maximum: 1)
        Control::MultiItem.new(root_element, item_text_node.parent)
      end
    end

    class Dropdown < SitePrism::Section
      set_default_search_arguments '.ts-dropdown'

      # for single
      element :option, '.option'
      # for multiple
      elements :options, '.option'
      # if .plugin-dropdown_input
      element :input, '.dropdown-input'

      def select_option(text, exact: true)
        options(text:, exact_text: exact, minimum: 1, maximum: 1)[0].click
      end

      def search(text)
        input.native.send_keys(text.to_s)
      end

      def has_options_with_text?(texts)
        has_opts = has_options?(minimum: 1)
        raise Capybara::ExpectationNotMet, 'no options in select' unless has_opts

        actual_texts = options.map(&:text)
        unless actual_texts.sort == texts.sort
          raise Capybara::ExpectationNotMet, "expect #{actual_texts.sort} to match #{texts.sort}"
        end

        true
        # RSpec::Matchers::BuiltIn::Satisfy.new(nil) do
        #   actual_texts = options(minimum: texts.size, maximum: texts.size).map(&:text)
        #   expect(actual_texts).to match_array(texts)
        #   true
        # end
      end
    end

    set_default_search_arguments '.ts-wrapper'

    section :control, Control
    section :dropdown, Dropdown

    class << self
      def by_label(label, exact: false, parent: nil)
        parent ||= Capybara.current_session
        # root_element = parent.find(:parent_by_label, label, exact:)
        label = parent.find(:label, text: label, exact_text: exact, match: :prefer_exact)
        ts_control = parent.find("##{label[:for]}")
        root_element = ts_control.ancestor(default_search_arguments[0])
        new(parent, root_element)
      end
    end

    def has_selected_texts?(texts)
      control.has_items_with_text?(texts)
    end

    def has_selected_text?(texts)
      control.has_item_with_text?(texts)
    end

    def has_options_texts?(texts)
      with_opened_dropdown do
        dropdown.has_options_with_text?(texts)
      end
    end

    def dropdown_open?
      root_element[:class].include?('dropdown-active')
    end

    def select(texts, exact: true)
      with_opened_dropdown do
        Array.wrap(texts).each do |text|
          dropdown.select_option(text, exact:)
        end
      end
    end

    def search_and_select(search, select: nil, exact: true)
      with_opened_dropdown do
        dropdown.search(search) if dropdown.has_input?(wait: 0)
        Array.wrap(select || search).each do |text|
          dropdown.select_option(text, exact:)
        end
      end
    end

    def clear
      control.root_element.hover
      control.clear_btn.click
    end

    def remove_item(texts, exact: true)
      Array.wrap(texts).each do |text|
        item = control.find_item_by_text(text, exact:)
        item.remove_btn.click
      end
    end

    def with_opened_dropdown
      was_open = dropdown_open?
      control.click unless was_open
      result = yield
      control.click if !was_open && dropdown_open?
      result
    end
  end
end
