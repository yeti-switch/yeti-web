# frozen_string_literal: true

module ActiveRecord
  class Migrator
    def migrate
      if !target && @target_version && @target_version > 0
        raise UnknownMigrationVersionError, @target_version
      end

      runnable.each do |migration|
        Base.logger&.info "Migrating to #{migration.name} (#{migration.version})"

        begin
          execute_migration_in_transaction(migration, @direction)
        rescue StandardError => e
          canceled_msg = use_transaction?(migration) ? 'this and ' : ''
          raise StandardError, "An error has occurred, #{canceled_msg}all later migrations canceled:\n\n#{e}", e.backtrace
        end

        if @direction == :up && !ENV['IGNORE_STOPS'] && migration.send(:migration).try(:stop_step)
          warn 'IMPORTANT: Now update and restart your servers. And after that run `rake db:migrate` again.'
          break
        end
      end
    end
  end
end
