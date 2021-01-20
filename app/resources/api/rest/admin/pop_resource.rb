# frozen_string_literal: true

class Api::Rest::Admin::PopResource < ::BaseResource
  attributes :name
  paginator :paged
  filter :name # DEPRECATED

  ransack_filter :name, type: :string

  def self.updatable_fields(_context)
    %i[
      name
    ]
  end

  def self.creatable_fields(_context)
    %i[
      id
      name
    ]
  end
end
