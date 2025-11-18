# frozen_string_literal: true

ActiveAdmin.register Yeti::TimeZoneHelper, as: 'time_zone' do
  menu false

  actions :none

  collection_action :search, method: :get do
    authorize!
    render json: [] and return if params.dig(:q, :search_for).blank?

    lowercase_search_query = params.dig(:q, :search_for).downcase
    data = Yeti::TimeZoneHelper.all.select { |entry| entry.downcase.include?(lowercase_search_query) }.map do |entry|
      { id: entry, value: entry }
    end
    render json: data
  end
end
