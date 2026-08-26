# frozen_string_literal: true

# These two Ransack predicates were registered by active_admin_datetimepicker,
# removed during the ActiveAdmin 4 upgrade. The gem's date-time picker widget is
# gone, but the predicate NAMES are still used all over app/admin (default index
# filters via with_default_params, the CDR -> RTP-stream links) and are baked
# into filters already persisted in admin_users.saved_filters, so they are
# re-declared here verbatim.
#
# Note the asymmetry, which is the gem's and is deliberately preserved:
#   *_gteq_datetime_picker  -> arel `gteq`  (inclusive lower bound)
#   *_lteq_datetime_picker  -> arel `lt`    (EXCLUSIVE upper bound)
#
# Renaming these to plain `_gteq` / `_lteq` would silently widen every upper
# bound by one interval; a rename must map `_lteq_datetime_picker` to `_lt`.
Ransack.configure do |config|
  config.add_predicate 'gteq_datetime_picker',
                       arel_predicate: 'gteq'

  config.add_predicate 'lteq_datetime_picker',
                       arel_predicate: 'lt'
end
