# frozen_string_literal: true

module Report
  class BaseForm < ApplicationForm
    include Hints

    attr_reader :report
    delegate :id, to: :report, allow_nil: true

    attribute :date_start, :datetime
    attribute :date_end, :datetime

    validates :date_start, :date_end, presence: true
  end
end
