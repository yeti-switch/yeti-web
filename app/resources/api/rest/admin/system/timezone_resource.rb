# frozen_string_literal: true

class Api::Rest::Admin::System::TimezoneResource < ::BaseResource
  model_name 'System::Timezone'
  immutable
  attributes :name, :abbrev, :utc_offset, :is_dst
  paginator :paged
  filter :name
end
