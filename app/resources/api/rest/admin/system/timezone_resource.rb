class Api::Rest::Admin::System::TimezoneResource < ::BaseResource
  model_name 'System::Timezone'
  immutable
  attributes :name, :abbrev, :utc_offset, :is_dst
  filter :name
end
