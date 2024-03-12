# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.numberlists
#
#  id                         :integer(2)       not null, primary key
#  default_dst_rewrite_result :string
#  default_dst_rewrite_rule   :string
#  default_src_rewrite_result :string
#  default_src_rewrite_rule   :string
#  defer_dst_rewrite          :boolean          default(FALSE), not null
#  defer_src_rewrite          :boolean          default(FALSE), not null
#  external_type              :string
#  name                       :string           not null
#  tag_action_value           :integer(2)       default([]), not null, is an Array
#  created_at                 :timestamptz
#  updated_at                 :timestamptz
#  default_action_id          :integer(2)       default(1), not null
#  external_id                :bigint(8)
#  lua_script_id              :integer(2)
#  mode_id                    :integer(2)       default(1), not null
#  tag_action_id              :integer(2)
#
# Indexes
#
#  blacklists_name_key                             (name) UNIQUE
#  numberlists_external_id_external_type_key_uniq  (external_id,external_type) UNIQUE
#  numberlists_external_id_key_uniq                (external_id) UNIQUE WHERE (external_type IS NULL)
#
# Foreign Keys
#
#  numberlists_lua_script_id_fkey  (lua_script_id => lua_scripts.id)
#  numberlists_tag_action_id_fkey  (tag_action_id => tag_actions.id)
#

class Routing::Numberlist < ApplicationRecord
  include WithPaperTrail
  self.table_name = 'class4.numberlists'

  DEFAULT_ACTION_REJECT = 1
  DEFAULT_ACTION_ACCEPT = 2
  DEFAULT_ACTIONS = {
    DEFAULT_ACTION_REJECT => 'Reject call',
    DEFAULT_ACTION_ACCEPT => 'Allow call'
  }.freeze

  MODE_STRICT = 1
  MODE_PREFIX = 2
  MODE_RANDOM = 3
  MODES = {
    MODE_STRICT => 'Strict number match',
    MODE_PREFIX => 'Prefix match',
    MODE_RANDOM => 'Random'
  }.freeze

  class << self
    def ransackable_scopes(_auth_object = nil)
      %i[
        search_for
      ]
    end
  end

  attribute :external_type, :string_presence

  belongs_to :tag_action, class_name: 'Routing::TagAction', optional: true
  belongs_to :lua_script, class_name: 'System::LuaScript', foreign_key: :lua_script_id, optional: true

  array_belongs_to :tag_action_values, class_name: 'Routing::RoutingTag', foreign_key: :tag_action_value

  has_many :routing_numberlist_items, class_name: 'Routing::NumberlistItem', foreign_key: :numberlist_id, dependent: :delete_all
  has_many :src_customers_auths, class_name: 'CustomersAuth', foreign_key: :src_numberlist_id, dependent: :restrict_with_error
  has_many :dst_customers_auths, class_name: 'CustomersAuth', foreign_key: :dst_numberlist_id, dependent: :restrict_with_error
  has_many :termination_dst_gateways, class_name: 'Gateway', foreign_key: :termination_dst_numberlist_id, dependent: :restrict_with_error
  has_many :termination_src_gateways, class_name: 'Gateway', foreign_key: :termination_src_numberlist_id, dependent: :restrict_with_error

  validates :name, presence: true
  validates :name, uniqueness: true

  validates :default_action_id, inclusion: { in: DEFAULT_ACTIONS.keys }, allow_nil: false
  validates :mode_id, inclusion: { in: MODES.keys }, allow_nil: false
  validates :external_type, absence: { message: 'requires external_id' }, unless: :external_id
  validates :external_id,
            uniqueness: { scope: :external_type },
            if: proc { external_id && external_type }
  validates :external_id,
            uniqueness: { conditions: -> { where(external_type: nil) } },
            if: proc { external_id && !external_type }

  validates_with TagActionValueValidator

  scope :search_for, ->(term) { where("numberlists.name || ' | ' || numberlists.id::varchar ILIKE ?", "%#{term}%") }

  def display_name
    "#{name} | #{id}"
  end

  def default_action_name
    DEFAULT_ACTIONS[default_action_id]
  end

  def mode_name
    MODES[mode_id]
  end
end
