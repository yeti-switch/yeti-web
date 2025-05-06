# frozen_string_literal: true

module TryCdrReplica
  private

  def try_cdr_replica(&)
    Cdr::Base.connected_to(role: :reading, &)
  end
end
