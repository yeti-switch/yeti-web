# frozen_string_literal: true

# == Schema Information
#
# Table name: notifications.attachments
#
#  id       :integer(4)       not null, primary key
#  data     :binary
#  filename :string           not null
#

class Notification::Attachment < ActiveRecord::Base
  self.table_name = 'notifications.attachments'

  def basename
    Pathname.new(filename).basename
  end
end
