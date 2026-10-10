# frozen_string_literal: true

module Jobs
  class SyncDatabaseTables < ::BaseJob
    self.cron_line = '0 2 * * *'

    module CONST
      BATCH_SIZE = 1_000
      freeze
    end.freeze

    def execute
      Cdr::Base.transaction do
        Cdr::Country.delete_all
        Cdr::Country.import System::Country.all.to_a, validate: false

        Cdr::Network.delete_all
        Cdr::Network.import System::Network.all.to_a, validate: false

        Cdr::NetworkPrefix.delete_all
        System::NetworkPrefix.find_in_batches(batch_size: CONST::BATCH_SIZE) do |prefixes|
          Cdr::NetworkPrefix.import prefixes.to_a, validate: false
        end
      end
    end
  end
end
