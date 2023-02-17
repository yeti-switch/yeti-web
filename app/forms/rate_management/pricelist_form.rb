# frozen_string_literal: true

module RateManagement
  class PricelistForm < ApplicationForm
    with_transaction true
    with_model_name 'RateManagement::Pricelist'
    with_policy_class 'RateManagement::PricelistPolicy'

    VALID_TILL_DEFAULT_INTERVAL = 5.years.freeze

    attr_reader :model

    attribute :name, :string
    attribute :project_id, :integer
    attribute :valid_till, :datetime, default: proc { VALID_TILL_DEFAULT_INTERVAL.from_now.beginning_of_day }
    attribute :valid_from, :datetime
    attribute :retain_enabled, :boolean, default: true
    attribute :retain_priority, :boolean, default: true

    attribute :file

    validates :name, :project_id, :valid_till, presence: true
    validates :retain_enabled, :retain_priority, inclusion: { in: [true, false] }
    validate :validate_file
    validate :validate_project_pricelists
    validate :validate_valid_from
    validate :validate_valid_till

    private

    def _save
      AdvisoryLock::Yeti.with_lock(:rate_management) do
        pricelist = RateManagement::Pricelist.create!(
          name: name,
          project: project,
          valid_till: valid_till,
          valid_from: valid_from,
          filename: file.original_filename,
          state_id: RateManagement::Pricelist::CONST::STATE_ID_NEW,
          retain_enabled: retain_enabled,
          retain_priority: retain_priority
        )
        csv_rows = RateManagement::PricelistItemsParser.call(
          project: project,
          file: file
        )
        pricelist_items_attrs = RateManagement::VerifyPricelistItems.call(
          pricelist: pricelist,
          attributes_list: csv_rows
        )
        RateManagement::CreatePricelistItems.call(
          pricelist: pricelist,
          pricelist_items_attrs: pricelist_items_attrs
        )
        @model = pricelist
      end
    rescue RateManagement::PricelistItemsParser::Error => e
      errors.add(:file, e.message)
      throw(:error)
    rescue RateManagement::VerifyPricelistItems::Error => e
      # Adding errors for :base because we don't want potentially long errors be in input error hint.
      # Long error hint will break form UI appearance.
      e.error_lines.map { |message| errors.add(:base, "File #{message}") }
      throw(:error)
    rescue RateManagement::CreatePricelistItems::InvalidAttributesError => e
      errors.add(:base, "File #{e.message}")
      throw(:error)
    rescue RateManagement::CreatePricelistItems::Error => e
      errors.add(:base, e.message)
      throw(:error)
    end

    define_memoizable :project, apply: lambda {
      RateManagement::Project.find_by(id: project_id) if project_id
    }

    def validate_file
      errors.add(:file, "can't be blank") if file.nil?
      errors.add(:file, 'must be a csv format') if file && file.content_type != 'text/csv'
    end

    def validate_project_pricelists
      return if project.nil?

      errors.add(:project, 'have New or Dialpeers detection pricelist, please delete or complete it first') if project.pricelists.in_progress.exists?
    end

    def validate_valid_from
      return if valid_from.nil?

      errors.add(:valid_from, 'must be in future') unless valid_from.future?
      errors.add(:valid_from, 'must be earlier than Valid till') if valid_till && valid_from >= valid_till
    end

    def validate_valid_till
      return if valid_till.nil?

      errors.add(:valid_till, 'must be in future') unless valid_till.future?
    end
  end
end
