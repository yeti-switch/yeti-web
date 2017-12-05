module ActiveRecord
  class Migrator
    def migrate
      if !target && @target_version && @target_version > 0
        raise UnknownMigrationVersionError.new(@target_version)
      end

      runnable.each do |migration|
        Base.logger.info "Migrating to #{migration.name} (#{migration.version})" if Base.logger

        begin
          execute_migration_in_transaction(migration, @direction)
        rescue => e
          canceled_msg = use_transaction?(migration) ? "this and " : ""
          raise StandardError, "An error has occurred, #{canceled_msg}all later migrations canceled:\n\n#{e}", e.backtrace
        end

        if @direction == :up && !ENV["IGNORE_STOPS"] && migration.send(:migration).try(:stop_step)
          puts "IMPORTANT: Now update and restart your servers. And after that run `rake db:migrate` again."
          break
        end
      end
    end
  end
end
