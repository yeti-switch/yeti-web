# frozen_string_literal: true

module AdminApi
  class AccountBalanceCorrectionForm < ProxyForm
    with_model_name 'Account'
    model_class 'Account'

    attribute :correction, :decimal

    private

    def _save
      model.with_lock do
        model.balance += correction
        unless model.save(validate: false)
          propagate_errors(model)
          throw(:error)
        end
      end
    end

    def propagate_errors(record)
      record.errors.each do |error|
        errors.add(error.attribute, error.message)
      end
    end
  end
end
