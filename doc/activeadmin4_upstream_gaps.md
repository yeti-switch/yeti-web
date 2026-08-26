# ActiveAdmin 4 — upstream gaps found during the yeti-web migration

Working notes for merge requests we may send upstream. Everything here was hit
while porting yeti-web to `activeadmin 4.0.0.beta22`, and every item links to
the workaround already living in this repo, so a PR can be lifted from it.

Two upstream targets:

1. **`activeadmin/activeadmin`** — regressions and gaps in AA4 itself.
2. **`activeadmin-plugins/capybara_active_admin`** — the Capybara test DSL, which
   has no AA4 support at all.

---

## 1. activeadmin/activeadmin

### 1.1 Flash messages carry no role and no type hook — *best first PR*

`app/views/active_admin/_flash_messages.html.erb` renders each message as a bare
`div` with Tailwind utility classes. There is no `role`, no `id`, no class, and
no data attribute. The three types are distinguished **only by colour**:

| type | classes |
| --- | --- |
| `notice` | `bg-green-50 text-green-800` |
| `alert` | `bg-yellow-50 text-yellow-800` |
| `error` | `bg-red-50 text-red-800` |

Two separate problems:

- **Accessibility.** A flash banner with no `role="alert"` is not announced by
  screen readers. This is a defect regardless of anything else, and is the part
  most likely to be accepted without debate.
- **No semantic hook.** Nothing can identify a flash by type without matching on
  its palette. That breaks any app CSS/JS that wants to target flashes, and it
  breaks every test DSL (see §2).

Proposed change: add `role="alert"` to each message, `flashes` to the container,
and `flash flash_<type>` to each message — the ActiveAdmin 3 convention. Purely
additive; existing styling is untouched.

Our implementation: [`app/views/active_admin/_flash_messages.html.erb`](../app/views/active_admin/_flash_messages.html.erb)
(structurally identical to the gem's partial, so it is a clean diff).

### 1.2 Components removed in 4.0 that had no replacement

Each of these forced a re-implementation. Worth raising as issues even where a
PR is unlikely, since the removals are undocumented in the upgrade notes.

| Removed | Impact here | Our port |
| --- | --- | --- |
| `tabs` component | used by ~14 resources | [`lib/active_admin/views/components/tabs.rb`](../lib/active_admin/views/components/tabs.rb) — rebuilt on Flowbite, which AA4 already pins |
| `dropdown_menu` component | 3 call sites | [`lib/active_admin/views/components/dropdown_menu.rb`](../lib/active_admin/views/components/dropdown_menu.rb) — also Flowbite |
| `columns` component | ~14 resources | [`lib/active_admin/views/components/columns.rb`](../lib/active_admin/views/components/columns.rb) |
| Deep menu nesting (>1 level) | 19 `app/admin` files use `menu parent: %w[A B]` | [`lib/active_admin/menu_deep_nesting.rb`](../lib/active_admin/menu_deep_nesting.rb) |
| `config.footer` | — | [`app/views/active_admin/_site_footer.html.erb`](../app/views/active_admin/_site_footer.html.erb) |
| `config.meta_tags`, `config.register_stylesheet` | — | [`app/views/active_admin/_html_head.html.erb`](../app/views/active_admin/_html_head.html.erb) |
| `ActiveAdmin::Helpers::Collection` | `collection_size` moved to `ActiveAdmin::IndexHelper` | [`lib/active_admin/fast_count.rb`](../lib/active_admin/fast_count.rb) |

Since `tabs`, `dropdown_menu` and `columns` were all rebuilt on Flowbite — which
AA4 ships in its own importmap — upstreaming them is plausible: they would be
AA4-native, not jQuery leftovers.

### 1.3 `id_column` no longer marks the link

AA3 rendered `link_to resource.id, resource_path(resource), class: "resource_id_link"`.
AA4 (`lib/active_admin/views/index_as_table.rb`) drops the class. There is now no
way to select the ID link generically. Restoring the class is a one-line,
backwards-compatible change.

Our workaround: `id_column` override in [`lib/active_admin/views/index_as_table.rb`](../lib/active_admin/views/index_as_table.rb).

### 1.4 Table footer / totals row

`TableFor` still has no first-class way to render a `<tfoot>`, tracked upstream
as [activeadmin#3797](https://github.com/activeadmin/activeadmin/issues/3797).
AA4 made this easier to patch (its `build_table_cell` already formats values), so
our port is now a small patch rather than a full copy of the component — a good
basis for a PR that adds `footer:` / `footer_data:` properly.

Our port: [`lib/active_admin/views/components/table_for.rb`](../lib/active_admin/views/components/table_for.rb).

### 1.5 Lower priority / probably intentional

- **Columns identified by `data-column` instead of `col col-<name>` classes.**
  Defensible, but it silently breaks every CSS rule and test selector written
  against AA3. Worth a note in the upgrade guide rather than a PR.
- **Action items must opt into `action-item-button`.** AA3 styled the container
  (`.action_items a`), so every custom `action_item` block renders unstyled after
  the upgrade until each one adds the class. An upgrade-guide note would save
  people the hunt. See [`app/helpers/active_admin/action_item_helper.rb`](../app/helpers/active_admin/action_item_helper.rb).

---

## 2. activeadmin-plugins/capybara_active_admin

**The gem does not support ActiveAdmin 4 at all**, and cannot be used with it:

- `capybara_active_admin.gemspec` declares `activeadmin >= 3.0, < 4.0`.
- The latest release, **1.0.0 (2026-04-09)**, is still entirely AA3 markup — its
  selectors are unchanged from 0.3.3 (2020). The 1.0.0 changelog is purely
  additive (`have_table_header`, `click_table_scope`, `have_status_tag`, …).
- Upstream has a single branch, `master`, HEAD `5e049dc bump 1.0.0`. No AA4 work
  in progress.

Every matcher, finder and action in the gem composes its `*_selector` methods, so
**an AA4 port is essentially a new selector set** — which is exactly what we
already derived and validated against this app's feature suite.

### 2.1 Selector mapping (the PR content)

Verified against rendered AA4 output, not guessed from templates.

| Selector | AA3 | AA4 |
| --- | --- | --- |
| `table_selector` (no arg) | `table.index_table` | `.index-as-table table` |
| `table_selector(name)` | `table#index_table_<plural>` | unchanged (id survives) |
| `table_header_selector` | `thead > tr > th.col` | `thead > tr > th[data-column]` |
| `table_cell_selector` | `td.col.col-<column>` | `td[data-column="<column>"]` |
| `table_scopes_container_selector` | `.scopes > ul.table_tools_segmented_control` | `.scopes .index-button-group` |
| `table_scope_selector` | `li.scope` | `a.index-button` |
| `filter_form_selector` | `.filter_form` | `.filters-form` |
| `action_items_container_selector` | `#titlebar_right .action_items` | container varies; items carry `.action-item-button` |
| `action_item_selector` | `… .action_item` | `… .action-item-button` |
| `page_title_selector` | `#page_title` | the page header `h2` |
| `footer_selector` | `div.footer#footer` | AA4 renders `_site_footer` |
| `tab_header_link_selector` | `.tabs.ui-tabs li.ui-tabs-tab a` | `.tabs [role="tab"]` |
| `panel_content_selector` | `.panel_contents` | `.panel-body` |
| `batch_actions_button_selector` | `div.batch_actions_selector` | `button.batch-actions-dropdown-toggle` |
| `dropdown_list_selector` | `ul.dropdown_menu_list` | `ul.batch-actions-dropdown-menu` |

Unchanged in AA4 (no override needed): `sidebar_selector` `#sidebar`,
`panel_selector` `.panel`, `panel_title_selector` `h3`, `tab_content_selector`
`.tab-content`, `batch_action_selector` `li a[data-action]`, `table_row_selector`.

Our implementation, deliberately kept free of app-specific helpers so it can be
lifted wholesale: [`spec/support/helpers/capybara_active_admin_aa4.rb`](../spec/support/helpers/capybara_active_admin_aa4.rb).

Note two entries above depend on app-side markup rather than AA4 itself
(`action_items_container_selector`, `footer_selector`), because AA4 leaves those
containers unmarked — see §1.1 and §1.2. A proper upstream port should either
select on AA4's own structure or push for hooks upstream first.

### 2.2 Not a rename — needs a decision upstream

- **`flash_message_selector`** — unfixable by selector alone while §1.1 stands;
  the only discriminator is the Tailwind palette. Best sequencing: land the AA4
  flash PR, then this becomes trivial.
- **`modal_dialog_selector`** (`.active_admin_dialog`) — that markup came from
  `active_admin_scoped_collection_actions`, not from ActiveAdmin. AA4 confirms
  batch actions through rails-ujs `data-confirm`, i.e. a native browser dialog,
  so the AA4 equivalent is Capybara's `accept_confirm` rather than a selector.

### 2.3 Suggested approach

Fork to `yeti-switch/capybara_active_admin`, drop in the selector set above,
relax the gemspec to allow AA4, and pin this repo's Gemfile at the fork. Offer it
upstream once it is proven against a full suite — a port validated against a real
application is a much stronger PR than a speculative one.

---

## 3. Also found — not upstream, our own AA4 migration debt

Recorded here so it is not lost; these are yeti-web bugs, not upstream ones.

- **`app/assets/javascripts/modal_link.js:36` calls `ActiveAdmin.modal_dialog`**,
  an AA3 global that AA4 removed entirely. Clicking those links throws
  `ReferenceError: ActiveAdmin is not defined`, so the contractor-import flows
  ("Apply unique columns", "Create new ones", …) are broken in the browser.
  Needs a small Flowbite-based modal, and would also settle §2.2.
- **Batch actions** built on `active_admin_scoped_collection_actions` are still
  awaiting reimplementation on AA4 batch actions — see the comment in
  `app/admin/routing/destinations.rb`.
- **`app/assets/javascripts/tom-select.js`** still used `form.filter_form
  div.select_and_search > select`, so filter predicate dropdowns never became
  tom-selects after the upgrade. *Fixed.*
