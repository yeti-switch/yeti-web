class Stats::Traffic < Stats::Base
  self.abstract_class = true

  def self.to_chart(id, options = {})
    points = self.where(account_id: id).
        where('timestamp <= NOW() AND timestamp > ?', 12.hours.ago).order('timestamp asc').
        pluck(:timestamp, :amount, :profit)
    [
     {
         key: 'Profit',
         values: points.map { |p| {x: p[0].to_datetime.to_s(:db), y: p[2].to_f } }
     },
     {
              key: 'Amount',
              values: points.map { |p| {x: p[0].to_datetime.to_s(:db), y: p[1].to_f } }
          }


    ]
  end

  def self.hourly(column, hours_ago)
    where('timestamp <= NOW() AND timestamp > ?', hours_ago.hours.ago).select(" sum(#{column}) as #{column}, date_trunc('hour',timestamp) as timestamp").
          group("date_trunc('hour',timestamp)").order("timestamp")
  end

  def self.stats(column, hours_ago = 48)
   scope = hourly(column, hours_ago)
   res = [
     key: column.to_s.humanize,
     values: scope.map { |p|   {x: p[:timestamp].to_datetime.to_s(:db), y: p[column].to_f} }
   ]
    res
  end

end