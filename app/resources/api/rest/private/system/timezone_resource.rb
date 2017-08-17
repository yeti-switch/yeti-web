class Api::Rest::Private::System::TimezoneResource < ::BaseResource
  immutable
  model_name 'System::Timezone'
  type 'system/timezones'

  attributes :name, :abbrev, :utc_offset, :is_dst
end
