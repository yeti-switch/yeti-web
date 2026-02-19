# frozen_string_literal: true

class Api::Rest::Dns::ZoneResource < ::BaseResource
  model_name 'Equipment::Dns::Zone'
  immutable
  paginator :paged

  attributes :name, :serial

  ransack_filter :id, type: :number
  ransack_filter :name, type: :string
  ransack_filter :serial, type: :number

  def self.sortable_fields(_context = nil)
    %i[id name serial]
  end
end
