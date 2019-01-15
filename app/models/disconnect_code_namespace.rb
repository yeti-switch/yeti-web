# frozen_string_literal: true

# == Schema Information
#
# Table name: disconnect_code_namespace
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class DisconnectCodeNamespace < ActiveRecord::Base
  self.table_name = 'disconnect_code_namespace'

  def display_name
    name
  end
end
