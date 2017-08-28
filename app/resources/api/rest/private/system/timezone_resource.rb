class Api::Rest::Private::System::TimezoneResource < ::BaseResource
  model_name 'System::Timezone'

  attributes :name, :abbrev, :utc_offset, :is_dst
end
