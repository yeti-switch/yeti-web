module Jobs
  class DialpeerRatesApply < ::BaseJob

    def execute
      ActiveRecord::Base.transaction do
        DialpeerNextRate.ready_for_apply.find_each do |rate|
          rate.dialpeer.update!(
              current_rate_id: rate.id,
              initial_interval: rate.initial_interval,
              next_interval: rate.next_interval,
              initial_rate: rate.rate,
              next_rate: rate.rate,
              connect_fee: rate.connect_fee
          )
          rate.update!(applied: true)
        end
      end
    end

  end
end