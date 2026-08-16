# frozen_string_literal: true

# Restores ActiveAdmin 3's rendering of NULL boolean columns.
#
# Before the ActiveAdmin 4 upgrade this app formatted booleans through its own
# `render_data` override (lib/active_admin/views/components/table_for.rb), which
# decided on the VALUE:
#
#   is_boolean_val?(value)  # => BOOLEAN_VALUES.include?(value), i.e. true/false only
#
# so a nil never became a status tag and fell through to `pretty_format`, which
# renders it blank.
#
# ActiveAdmin 4's `format_attribute` decides on the COLUMN TYPE instead
# (`boolean_attr?` -> `attribute_types[attr].is_a?(ActiveModel::Type::Boolean)`),
# so a NULL boolean now renders `status_tag(nil)` => "UNKNOWN". That applies to
# every nullable boolean column in every index and show table — e.g. every row of
# the import preview's "is changed" column, which is NULL until an import runs.
#
# The upgrade did not intend this: table_for.rb dropped `render_data` on the
# grounds that AA4 "already renders booleans as status tags", which is true for
# true/false and not for nil.
#
# true/false keep AA4's status tags; only nil changes.
module ActiveAdmin
  module NilBooleanDisplay
    # Patched here rather than in `format_attribute`, deliberately: that method
    # resolves the value itself, so an override that pre-computed `find_value`
    # in order to inspect it would evaluate the attribute TWICE. For a `column`
    # given a block that builds Arbre, the second evaluation appends a second
    # element, and the cell renders a status tag wrapped around a status tag.
    #
    # Narrowing `boolean_attr?` instead leaves the single evaluation intact and
    # is the more faithful restoration anyway: AA3 decided on the value
    # (`is_boolean_val?` accepted only true/false), where AA4 decides on the
    # column type and so treats NULL as a boolean worth a tag.
    # AA3's rule exactly: a status tag is for an actual boolean VALUE. AA4 asks
    # the column type instead, which mis-fires two ways on this app:
    #
    #   nil  - every NULL boolean column renders "UNKNOWN" rather than blank.
    #   pre-rendered HTML - decorators return markup for boolean columns (see
    #     RateManagementPricelistItemDecorator#changes_for_column, which yields
    #     `status_tag(:empty)` or a `<b>old => new</b>` diff). The column is still
    #     boolean, so AA4 wraps that markup in a second status tag and it renders
    #     escaped, as visible angle brackets.
    #
    # Checking the value covers both, because true/false are the only values a
    # boolean column can hold that should become a tag.
    def boolean_attr?(_resource, _attr, value)
      value.is_a?(TrueClass) || value.is_a?(FalseClass)
    end
  end
end

# ActiveAdmin::DisplayHelper lives in the gem's app/helpers, so it is autoloaded
# rather than required — it does not exist yet while config/initializers run
# (this file is required from active_admin.rb). Defer to to_prepare, which also
# re-applies the patch after a reload clears the constant.
Rails.application.config.to_prepare do
  ActiveAdmin::DisplayHelper.prepend(ActiveAdmin::NilBooleanDisplay)
end
