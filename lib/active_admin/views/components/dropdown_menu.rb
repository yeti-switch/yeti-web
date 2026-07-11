# frozen_string_literal: true

# ActiveAdmin 4 removed the `dropdown_menu` component along with the actions
# dropdown. It is still used by three call sites:
#   - ResourceDSL::ActsAsStat#acts_as_stats_actions ("Statistics" action item)
#   - app/admin/equipment/cnam_databases.rb ("New CNAM Database")
#   - app/admin/equipment/lnp_databases.rb ("New Lnp Database")
#
# Rebuilt on Flowbite's dropdown, which ActiveAdmin 4 pins in its importmap and
# initialises for any element carrying `data-dropdown-toggle`.
#
# Matches the AA3 API: `dropdown_menu('Label') { item('Title', url_or_options) }`
# where the options hash is passed through url_for.
module ActiveAdmin
  module Views
    class DropdownMenu < ActiveAdmin::Component
      builder_method :dropdown_menu

      BUTTON_CLASSES = 'action-item-button inline-flex items-center'
      MENU_CLASSES = 'z-50 hidden min-w-max rounded shadow-lg outline outline-black/5 ' \
                     'dark:-outline-offset-1 dark:outline-white/10 py-1 text-sm ' \
                     'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300'
      ITEM_CLASSES = 'block px-2.5 py-2 no-underline text-gray-700 hover:bg-gray-100 ' \
                     'hover:text-gray-900 dark:text-gray-300 dark:hover:bg-white/5 dark:hover:text-white'

      def build(label, options = {})
        super(options)
        add_class 'dropdown_menu inline-block relative'

        menu_id = "dropdown-menu-#{object_id}"
        button(label,
               type: 'button',
               class: BUTTON_CLASSES,
               'data-dropdown-toggle': menu_id)
        @menu = div(id: menu_id, class: MENU_CLASSES) { @list = ul }
      end

      # AA3 signature: item(title, url = nil, html_options = {}).
      # A bare trailing hash (e.g. `item 'X', action: :new, id: 1`) lands in `url`
      # and is resolved with url_for.
      def item(title, url = nil, html_options = {})
        href = url.is_a?(Hash) ? url_for(url) : url
        html_options = html_options.merge(class: [ITEM_CLASSES, html_options[:class]].compact.join(' '))

        within @list do
          li do
            a title, html_options.merge(href: href)
          end
        end
      end
    end
  end
end
