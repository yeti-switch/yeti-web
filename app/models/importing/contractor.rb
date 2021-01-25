# frozen_string_literal: true

# == Schema Information
#
# Table name: data_import.import_contractors
#
#  id                   :bigint(8)        not null, primary key
#  address              :string
#  customer             :boolean
#  description          :string
#  enabled              :boolean
#  error_string         :string
#  is_changed           :boolean
#  name                 :string
#  phones               :string
#  smtp_connection_name :string
#  vendor               :boolean
#  o_id                 :integer(4)
#  smtp_connection_id   :integer(4)
#

class Importing::Contractor < Importing::Base
  self.table_name = 'data_import.import_contractors'
  attr_accessor :file

  belongs_to :smtp_connection, class_name: 'System::SmtpConnection', optional: true

  self.import_attributes = %w[enabled name vendor customer smtp_connection_id]

  import_for ::Contractor
end
