class Log::BalanceNotification < ActiveRecord::Base
  self.table_name = 'balance_notifications'
  scope :processed, -> {where('is_processed')}
  scope :not_processed, -> {where('not is_processed')}

  def display_name
    self.id.to_s
  end

  def process!
    acc=Account.find(data["id"].to_i)

    if direction=="low"&&action=="fire"
      acc.fire_low_balance_alarm(data)

    elsif direction=="low"&&action=="clear"
      acc.clear_low_balance_alarm(data)

    elsif direction=="high"&&action=="fire"
      acc.fire_high_balance_alarm(data)

    elsif direction=="high"&&action=="clear"
      acc.clear_high_balance_alarm(data)

    end

    self.is_processed=true
    self.processed_at=Time.now #seems it will write wrong time when timezone is not UTC
    self.save!

  end


end
