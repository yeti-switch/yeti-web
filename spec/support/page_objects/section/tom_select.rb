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
        item_text_node = items_texts(text:, exact_text: exact, minimum: 1, maximum: 1)[0]
        Control::MultiItem.new(root_element, item_text_node.ancestor('.item'))
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
        option = options(text:, exact_text: exact, minimum: 1, maximum: 1)[0]
        # root_element.scroll_to(option, :top)
        option.click
      end

      # Wait until an option with the given text is rendered (e.g. after an ajax
      # search has loaded results), without selecting it.
      def wait_for_option(text, exact: true)
        options(text:, exact_text: exact, minimum: 1)
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
      root_element.reload[:class].include?('dropdown-active')
    end

    def select(texts, exact: true)
      # Options are already loaded from the <select>, so select straight through
      # the API — no need to open the dropdown.
      Array.wrap(texts).each { |text| add_item_by_text(text, exact:) }
    end

    def search_and_select(search, select: nil, exact: true)
      with_opened_dropdown do
        dropdown.search(search)
        Array.wrap(select || search).each do |text|
          dropdown.wait_for_option(text, exact:) # wait for the ajax-loaded option
          add_item_by_text(text, exact:)
        end
      end
    end

    # Select known options in an ajax tom-select purely through the API: inject
    # the option (so no server round-trip is needed) and add it. This avoids the
    # type -> throttled-fetch -> render -> addItem chain of #search_and_select,
    # which can race under CI load and drop the selection. Use it when the test
    # already knows the value+text and only cares that the filter/form submits
    # the right value, not that the ajax search UI works.
    def select_by_value(pairs)
      pairs.each do |value, text|
        add_option_and_select(value, text)
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
      open_dropdown unless was_open
      dropdown # waits until dropdown is visible
      result = yield
      control.native.send_keys(:escape) if !was_open && dropdown_open?
      dropdown(visible: false) # waits until dropdown is hidden
      result
    end

    # JS prologue that resolves this widget's tom-select instance into `ts`.
    # tom-select keeps the original <select> as the wrapper's previous sibling;
    # fall back to matching by instance.wrapper. arguments[0] is the wrapper.
    INSTANCE_JS = <<~JS
      var wrapper = arguments[0];
      var el = wrapper.previousElementSibling;
      if (!el || !el.tomselect) {
        var nodes = document.querySelectorAll('.tomselected');
        for (var i = 0; i < nodes.length; i++) {
          if (nodes[i].tomselect && nodes[i].tomselect.wrapper === wrapper) { el = nodes[i]; break; }
        }
      }
      var ts = el && el.tomselect;
    JS

    # Open the dropdown via tom-select's own API rather than clicking the
    # control. Clicking the control is unsafe now that the per-chip remove plugin
    # is enabled: there is no empty element to target (the control holds only
    # chips, a 0x0 input and the clear button), a centre click can land on a
    # chip's remove icon and silently delete an item, and cuprite coordinate
    # clicks don't auto-scroll so targeting empty space by x/y is unreliable.
    # `open()` is deterministic and never touches the chips.
    def open_dropdown
      root_element.session.execute_script("#{INSTANCE_JS}\nif (ts) { ts.open(); }", root_element)
    end

    # Select an option through tom-select's API (addItem with its value) instead
    # of clicking the rendered .option. A 20x page-CPU throttle does not
    # reproduce the CI "lost selection" flake, which rules out a page-side render
    # race and points at the driver/CDP coordinate-click pipeline under host load
    # (the same reason the dropdown is opened via the API). addItem needs no
    # coordinates and no dropdown positioning, so the selection is deterministic.
    # Raises if the option isn't found, so genuine problems still surface.
    def add_item_by_text(text, exact:)
      # evaluate_script wraps the script as `function () { return <expr> }`, so it
      # must be a single expression — hence the IIFE. arguments[0..2] are wrapper,
      # text, exact.
      result = root_element.session.evaluate_script(<<~JS, root_element, text.to_s, exact)
        (function () {
          #{INSTANCE_JS}
          if (!ts) { return 'no-instance'; }
          var text = String(arguments[1]).trim(), exact = arguments[2];
          var labelField = ts.settings.labelField, valueField = ts.settings.valueField;
          var match = null;
          Object.keys(ts.options).some(function (key) {
            var label = String(ts.options[key][labelField]).trim();
            if (exact ? label === text : label.indexOf(text) !== -1) { match = ts.options[key]; return true; }
            return false;
          });
          if (!match) { return 'not-found'; }
          ts.addItem(String(match[valueField]), false);
          return 'ok';
        })(arguments[0], arguments[1], arguments[2])
      JS
      raise "tom-select: could not select #{text.inspect} (#{result})" unless result == 'ok'
    end

    # Inject an option (value + label) and select it, entirely through the
    # tom-select API — no dropdown, no typing, no ajax. Mirrors what the ajax
    # loader would have produced for a matching search, so the underlying
    # <select> submits the value. arguments[0..2] are wrapper, value, text.
    def add_option_and_select(value, text)
      root_element.session.execute_script(<<~JS, root_element, value.to_s, text.to_s)
        #{INSTANCE_JS}
        if (ts) {
          var opt = {};
          opt[ts.settings.valueField] = arguments[1];
          opt[ts.settings.labelField] = arguments[2];
          ts.addOption(opt);
          ts.addItem(String(arguments[1]), false);
        }
      JS
    end
  end
end
