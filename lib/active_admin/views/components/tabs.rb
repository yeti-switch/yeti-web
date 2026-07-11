# frozen_string_literal: true

# ActiveAdmin 4 removed the `tabs` component. app/admin uses it in ~14 resources
# (dashboard, CDRs, gateways, invoices, accounts, ...), so it is restored here.
#
# AA3 rendered jQuery UI tabs; AA4 ships no jQuery. This builds Flowbite tab
# markup instead — Flowbite is pinned in ActiveAdmin's own importmap and
# initialises anything carrying `data-tabs-toggle` on load.
#
# Flowbite's "Default tabs" variant (boxed, rounded-top) is used rather than the
# "Underline" one, because that is the shape ActiveAdmin 3 had: an inactive tab
# filled with --aa-tab-inactive, an active tab filled with --aa-surface that
# overlaps the content panel's top border and merges into it. The colours and
# borders live in yeti_admin.css.scss (`.tabs [role="tab"]`), driven by the
# --aa-* tokens; only structural classes are set here.
#
# ajax_tab.js lazy-loads a tab's content the first time it is shown, and the
# chart partials in app/views/charts bind their render to the tab click. Flowbite
# has no DOM event for either, so each tab button carries `data-tab-target` and
# both hook off it. Keep the three in sync.
module ActiveAdmin
  module Views
    class Tabs < ActiveAdmin::Component
      builder_method :tabs

      def build(*args)
        super
        add_class 'tabs mb-4'
        @panels_id = "tab-panels-#{object_id}"
        # -mb-px pulls the row down one pixel so each tab's bottom edge sits on
        # the <ul>'s baseline border; the active tab then paints over it.
        @menu = ul(class: 'aa-tablist flex flex-wrap -mb-px',
                   role: 'tablist',
                   'data-tabs-toggle': "##{@panels_id}")
        @tabs_content = div(id: @panels_id, class: 'tab-content')
        @first = true
      end

      def tab(title, options = {}, &block)
        title = title.to_s.titleize if title.is_a?(Symbol)
        fragment = options.fetch(:id, fragmentize(title))
        selected = @first
        @first = false

        within @menu do
          li(role: 'presentation') do
            button(title,
                   type: 'button',
                   role: 'tab',
                   id: "#{fragment}-tab",
                   'data-tabs-target': "##{fragment}",
                   'data-tab-target': "##{fragment}", # read by ajax_tab.js + charts
                   'aria-controls': fragment,
                   'aria-selected': selected.to_s)
          end
        end

        within @tabs_content do
          div(options.reverse_merge(id: fragment).merge(
                role: 'tabpanel',
                class: [options[:class], (selected ? nil : 'hidden')].compact.join(' '),
                'aria-labelledby': "#{fragment}-tab"
              ), &block)
        end
      end

      private

      def fragmentize(string)
        result = string.parameterize
        result = CGI.escape(string) if result.blank?
        result
      end
    end
  end
end
