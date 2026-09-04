# frozen_string_literal: true

# Resolves the external uuid of a record back to its id, for surfaces that
# expose the uuid instead of the sequential id.
module UuidLookup
  extend ActiveSupport::Concern

  UUID_FORMAT = /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/

  class_methods do
    # @return [Integer, nil] nil for a malformed uuid or one nobody holds
    def id_by_uuid(value)
      uuid = value.to_s.strip.downcase
      return nil unless uuid.match?(UUID_FORMAT)

      where(uuid: uuid).pick(:id)
    end
  end
end
