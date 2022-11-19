# frozen_string_literal: true

require 'active_model_types/yeti_date_time_type'
require 'active_model_types/json_attribute_type'
require 'active_model_types/array_type'
require 'active_model_types/string_presence'

ActiveModel::Type.register(:db_datetime, ActiveRecord::ConnectionAdapters::PostgreSQL::OID::DateTime)
