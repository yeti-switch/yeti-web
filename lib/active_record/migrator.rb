# frozen_string_literal: true

module ActiveRecord
  class Migrator
    def migrate_without_lock
      if invalid_target?
        raise UnknownMigrationVersionError, @target_version
      end

      result = runnable.each do |migration|
        execute_migration_in_transaction(migration)
        if up? && !ENV['IGNORE_STOPS'] && migration.send(:migration).try(:stop_step)
          warn 'IMPORTANT: Now update and restart your servers. And after that run `rake db:migrate` again.'
          break
        end
      end
      record_environment
      result
    end
  end
end
