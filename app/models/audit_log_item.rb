# frozen_string_literal: true

# == Schema Information
#
# Table name: versions
#
#  id             :integer          not null, primary key
#  item_type      :string(255)      not null
#  item_id        :integer          not null
#  event          :string(255)      not null
#  whodunnit      :string(255)
#  object         :text
#  created_at     :datetime
#  ip             :string(255)
#  object_changes :text
#  txid           :integer
#

class AuditLogItem < PaperTrail::Version
  scope :destroyed, -> { where event: 'destroy' }
  scope :updated,   -> { where event: 'update'  }
  scope :created,   -> { where event: 'create'  }
end
