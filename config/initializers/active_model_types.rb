# frozen_string_literal: true

require 'active_model_types/yeti_date_time_type'
require 'active_model_types/json_attribute_type'

ActiveModel::Type.register(:db_datetime, ActiveRecord::ConnectionAdapters::PostgreSQL::OID::DateTime)
