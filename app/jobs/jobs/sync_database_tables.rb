# frozen_string_literal: true

module Jobs
  class SyncDatabaseTables < ::BaseJob
    self.cron_line = '0 2 * * *'

    module CONST
      BATCH_SIZE = 1_000
      freeze
    end.freeze

    def execute
      ApplicationRecord.transaction do
        Cdr::Country.delete_all
        Cdr::Country.import System::Country.all.to_a

        Cdr::Network.delete_all
        Cdr::Network.import System::Network.all.to_a

        Cdr::NetworkPrefix.delete_all
        System::NetworkPrefix.find_in_batches(batch_size: CONST::BATCH_SIZE) do |prefixes|
          Cdr::NetworkPrefix.import prefixes.to_a
        end
      end
    end
  end
end
