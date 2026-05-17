# frozen_string_literal: true

module Helpers
  # Resolves the predicate operator label exactly as ActiveAdmin renders it in
  # filter forms, so specs assert against the locale (config/locales/ransack.en.yml)
  # instead of hardcoded strings.
  #
  # Mirrors ActiveAdmin::Inputs::Filters::Base::SearchMethodSelect#filter_options:
  #   I18n.t("ransack.predicates.#{filter}").capitalize
  module RansackPredicates
    def ransack_predicate_label(key)
      I18n.t("ransack.predicates.#{key}").capitalize
    end

    def ransack_predicate_labels(*keys)
      keys.map { |k| ransack_predicate_label(k) }
    end
  end
end

RSpec.configure do |config|
  config.include Helpers::RansackPredicates
end
