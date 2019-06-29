# frozen_string_literal: true

module Jobs
  class PartitionRemoving < ::BaseJob
    def execute
      remove_partition! PartitionModel::Cdr, Cdr::Cdr
      remove_partition! PartitionModel::Cdr, Cdr::AuthLog
    end

    private

    def remove_partition!(partition_class, model_class)
      remove_delay = Rails.configuration.yeti_web.dig('partition_remove_delay', model_class.table_name)
      return if remove_delay.blank?

      cdr_collection = partition_class
                       .where(partition_table_eq: model_class.table_name)
                       .to_a
                       .select { |r| r.date_to < Time.now.utc }
                       .sort_by(&:date_to)

      cdr_remove_candidate = cdr_collection[(remove_delay.to_i)..-1].last
      cdr_remove_candidate&.destroy!
    end
  end
end
