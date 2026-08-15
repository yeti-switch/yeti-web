# frozen_string_literal: true

# ActiveAdmin 4 markup overrides for the capybara_active_admin gem.
#
# The gem describes ActiveAdmin 3 markup and has no AA4 support: its latest
# release (1.0.0, 2026-04-09) still selects `table.index_table`, `td.col.col-*`,
# `.filter_form` and friends, and its gemspec pins `activeadmin >= 3.0, < 4.0`,
# so upgrading is not an option. Upstream has a single branch with no AA4 work
# in progress.
#
# Every matcher, finder and action in the gem is built on top of these
# `*_selector` methods, so redefining them here re-points the whole DSL at AA4
# markup instead of rewriting hundreds of call sites. This module is included
# after Capybara::ActiveAdmin::TestHelpers (see spec_helper.rb), so it wins.
#
# Kept free of yeti-specific helpers: if this is ever extracted into a fork of
# the gem, it should be a file move.
#
# Selectors deliberately NOT overridden, because AA4 still matches the gem:
#   sidebar_selector          '#sidebar'          (restored by _sidebar.html.erb)
#   panel_selector            '.panel'
#   panel_title_selector      'h3'                (AA4 renders h3.panel-title)
#   tab_content_selector      '.tab-content'      (see views/components/tabs.rb)
#   batch_action_selector     'li a[data-action]' (AA4 keeps data-action)
#   table_row_selector        'tbody > tr[id$=...]'
#
# Known gaps that are NOT a rename and still need a decision:
#   flash_message_selector - AA4's _flash_messages.html.erb renders Tailwind
#     utility classes only, with no `.flash`/`.flash_<type>` hook to select on.
#   modal_dialog_selector - `.active_admin_dialog` came from
#     active_admin_scoped_collection_actions, which this branch removed. AA4
#     confirms batch actions through rails-ujs `data-confirm`, i.e. a native
#     browser dialog (accept_confirm), not an in-page dialog.
module CapybaraActiveAdminAa4
  # --- table ------------------------------------------------------------------

  # @param resource_name [String, nil] active admin resource name.
  # @return [String] selector.
  def table_selector(resource_name = nil)
    # The `index_table_<plural>` id survives in AA4; only the `.index_table`
    # class is gone, replaced by TableFor's `.data-table` and the
    # `.index-as-table` wrapper. Scope by the wrapper so panel/attribute tables
    # (which also carry `.data-table`) are not matched.
    return '.index-as-table table' if resource_name.nil?

    resource_name = resource_name.to_s.gsub(' ', '_').pluralize.downcase
    "table#index_table_#{resource_name}"
  end

  # AA4 dropped the `col`/`col-<name>` classes and identifies columns with a
  # `data-column` attribute instead (see TableFor#build_table_cell).
  # @return [String] selector.
  def table_header_selector
    'thead > tr > th[data-column]'
  end

  # @param column [String, nil] column name.
  # @return [String] selector.
  def table_cell_selector(column = nil)
    return 'td[data-column]' if column.nil?

    %(td[data-column="#{aa4_parameterize(column)}"])
  end

  # AA4 renders scopes as a button group of links rather than a segmented <ul>.
  # @return [String] selector.
  def table_scopes_container_selector
    '.scopes .index-button-group'
  end

  # @return [String] selector.
  def table_scope_selector
    'a.index-button'
  end

  # --- attributes table -------------------------------------------------------

  # AA4 renamed the wrapper class (underscores -> dash) but kept the id.
  # @return [String] selector.
  def attributes_table_selector(model: nil, id: nil)
    return 'div.attributes-table' if model.nil?

    model = Capybara::ActiveAdmin::Util.parse_model_name(model)
    selector = "div.attributes-table.#{model}"
    selector += "#attributes_table_#{model}_#{id}" if id
    selector
  end

  # AA3 marked each row `tr.row.row-<attr>`; AA4 carries the attribute in a
  # `data-row` attribute instead (AttributesTable#row sets it from the attribute
  # name, parameterized with '_').
  # @param label [String, nil] attribute name.
  # @return [String] selector.
  def attributes_row_selector(label = nil)
    return 'tr[data-row] > td' if label.nil?

    "tr[data-row=\"#{aa4_parameterize(label)}\"] > td"
  end

  # --- filters ----------------------------------------------------------------

  # @return [String] selector.
  def filter_form_selector
    '.filters-form'
  end

  # --- layout -----------------------------------------------------------------

  # AA3's `#titlebar_right .action_items` is gone. This branch renders action
  # items from app/views/active_admin/_page_header.html.erb, which wraps them in
  # `[data-test-action-items]`; each item carries `.action-item-button` (see
  # app/helpers/active_admin/action_item_helper.rb).
  # @return [String] selector.
  def action_items_container_selector
    '[data-test-action-items]'
  end

  # @return [String] selector.
  def action_item_selector
    "#{action_items_container_selector} .action-item-button"
  end

  # The page title is the <h2> in the page header bar, not AA3's `#page_title`.
  # @return [String] selector.
  def page_title_selector
    '[data-test-page-header] h2'
  end

  # @return [String] selector.
  def footer_selector
    # app/views/active_admin/_site_footer.html.erb, replacing AA3's div.footer#footer.
    '.site-footer'
  end

  # AA3 rendered jQuery UI tabs; this branch rebuilds them on Flowbite, where
  # each tab is a <button role="tab"> carrying data-tab-target.
  # @see lib/active_admin/views/components/tabs.rb
  # @return [String] selector.
  def tab_header_link_selector
    '.tabs [role="tab"]'
  end

  # @return [String] selector.
  def panel_content_selector
    # AA4's Panel component builds div.panel-body (was .panel_contents).
    '.panel-body'
  end

  # --- batch actions ----------------------------------------------------------

  # @return [String] selector.
  def batch_actions_button_selector
    # AA4 renders _batch_actions_dropdown.html.erb: a toggle <button> beside the
    # menu, both inside .batch-actions-dropdown. The button is what opens it (and
    # stays `disabled` until at least one row is selected).
    'button.batch-actions-dropdown-toggle'
  end

  # @return [String] selector.
  def dropdown_list_selector
    # Only ever used by the gem together with batch_action_selector, so it can be
    # the batch-actions menu specifically. It is always in the DOM and merely
    # hidden, which is what open_batch_action_menu's visible-only check relies on.
    'ul.batch-actions-dropdown-menu'
  end

  private

  # Mirrors `title.to_s.parameterize(separator: '_')`, which is how AA4 derives
  # the `data-row` / `data-column` values it now identifies cells by. The gem's
  # own `gsub(' ', '_').downcase` diverges as soon as a label contains anything
  # other than spaces and letters.
  def aa4_parameterize(value)
    value.to_s.parameterize(separator: '_')
  end
end
