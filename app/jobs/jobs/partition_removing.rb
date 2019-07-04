# frozen_string_literal: true

module Jobs
  class PartitionRemoving < ::BaseJob
    def execute
      remove_partition! PartitionModel::Cdr, Cdr::Cdr
      remove_partition! PartitionModel::Cdr, Cdr::AuthLog
      remove_partition! PartitionModel::Cdr, Cdr::RtpStatistic
    end

    private

    def partition_remove_delay
      Rails.configuration.yeti_web.fetch('partition_remove_delay')
    end

    def remove_partition!(partition_class, model_class)
      table_name = model_class.table_name
      remove_delay = partition_remove_delay[table_name]
      if remove_delay.blank?
        logger.error { "#{self.class}: blank remove delay for #{table_name}" }
        return
      end

      cdr_collection = partition_class
                       .where(parent_table_eq: table_name)
                       .to_a
                       .select { |r| r.date_to < Time.now.utc }
                       .to_a
                       .sort_by(&:date_to)

      if cdr_collection.size <= remove_delay
        logger.error { "#{self.class}: does not enough partitions for #{table_name}" }
        return
      end

      cdr_remove_candidate = cdr_collection.first
      cdr_remove_candidate.destroy!
    rescue ActiveRecord::RecordNotDestroyed => e
      logger.error { "#{self.class}: {#{table_name}} #{cdr_remove_candidate&.name} - #{e.message}" }
    rescue StandardError => e
      logger.error { "#{self.class}: {#{table_name}} <#{e.class}>: #{e.message}\n#{e.backtrace.join("\n")}" }
      raise e
    end
  end
end
