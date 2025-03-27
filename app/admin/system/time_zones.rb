# frozen_string_literal: true

ActiveAdmin.register System::Timezone, as: 'time_zone' do
  menu false

  collection_action :search, method: :get do
    render json: [] and return if params.dig(:q, :search_for).blank?

    lowercase_search_query = params.dig(:q, :search_for).downcase
    data = Yeti::TimeZoneHelper.all.select { |entry| entry.name.include?(lowercase_search_query) }.map do |entry|
      { id: entry.name, value: entry.name }
    end
    render json: data
  end
end
