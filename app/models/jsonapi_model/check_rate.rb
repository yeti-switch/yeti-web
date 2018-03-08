module JsonapiModel
  class CheckRate < Base
    attr_accessor :rateplan_id, :number, :rates

    validates_presence_of :rateplan_id, :number
    validate do
      errors.add(:rateplan_id, 'Rateplan not found') unless rateplan
    end

    def initialize(**params)
      super

      @errors = ActiveModel::Errors.new(self)
      @rateplan_id = params[:rateplan_id]
      @number = params[:number]
    end

    def call
      get_rates
      self
    end

    def save(*args)
      begin
        get_rates
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
        Rails.logger.error(e.record.errors)
        return false
      end
      true
    end

    def rateplan
      Rateplan.find_by(uuid: @rateplan_id) if Rateplan.where(uuid: @rateplan_id).exists?
    end

    def self.all
      raise JSONAPI::Exceptions::RecordNotFound.new(nil)
    end

    def self.find(id)
      raise JSONAPI::Exceptions::RecordNotFound.new(nil)
    end

    private

    def get_rates
      @rates = rateplan.number_rates(@number).map { |el|
        el.slice!('uuid',
                 'prefix',
                 'initial_rate',
                 'initial_interval',
                 'next_rate',
                 'next_interval',
                 'connect_fee',
                 'reject_calls',
                 'valid_from',
                 'valid_till',
                 'network_prefix_id',
                 'routing_tag_names')
        el['id'] = el.delete('uuid')
        el
      }
    end

  end
end
