# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications.attachments
#
#  id       :integer          not null, primary key
#  filename :string           not null
#  data     :binary
#

class Notification::Attachment < ActiveRecord::Base
  self.table_name = 'notifications.attachments'

  def basename
    Pathname.new(filename).basename
  end
end
