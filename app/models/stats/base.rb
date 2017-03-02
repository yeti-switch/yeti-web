class Stats::Base < Cdr::Base
   self.abstract_class = true


   def self.create_stats(calls = {}, now_time, foreign_scope, foreign_key)
    foreign_ids = foreign_scope.pluck(:id)
    foreign_ids -= calls.keys.map(&:to_i)
    self.transaction do

      calls.each do |foreign_id, sub_calls|

        self.create!(
            created_at: now_time,
            count: sub_calls.count,
            foreign_key.to_sym => foreign_id
        )

      end
      foreign_ids.each do |foreign_id|
        self.create!(
            created_at: now_time,
            count: 0,
            foreign_key.to_sym => foreign_id
        )
      end
    end
  end
end
