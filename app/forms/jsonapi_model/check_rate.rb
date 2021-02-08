# frozen_string_literal: true

module JsonapiModel
  class CheckRate < Base
    attribute :rateplan_id
    attribute :number
    attribute :rates

    validates :rateplan_id, :number, presence: true
    validate do
      errors.add(:rateplan_id, 'Rateplan not found') unless rateplan
    end

    def call
      get_rates
      self
    end

    def rateplan
      return @rateplan if defined?(@rateplan)

      @rateplan = rateplan_id ? Routing::Rateplan.find_by(uuid: rateplan_id) : nil
    end

    def self.all
      raise JSONAPI::Exceptions::RecordNotFound, nil
    end

    def self.find(_id)
      raise JSONAPI::Exceptions::RecordNotFound, nil
    end

    private

    def _save
      get_rates
    end

    def get_rates
      self.rates = rateplan.number_rates(number).map do |el|
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
      end
    end
  end
end
