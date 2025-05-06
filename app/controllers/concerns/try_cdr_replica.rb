# frozen_string_literal: true

module TryCdrReplica
  private

  def try_cdr_replica(&)
    Cdr::Base.try_replica_with_fallback(&)
  end
end
