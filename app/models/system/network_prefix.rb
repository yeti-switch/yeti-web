# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.network_prefixes
#
#  id                :integer          not null, primary key
#  prefix            :string           not null
#  network_id        :integer          not null
#  country_id        :integer
#  number_min_length :integer          default(0), not null
#  number_max_length :integer          default(100), not null
#  uuid              :uuid             not null
#

class System::NetworkPrefix < Yeti::ActiveRecord
  self.table_name = 'sys.network_prefixes'

  belongs_to :country, class_name: 'System::Country', foreign_key: :country_id
  belongs_to :network, class_name: 'System::Network', foreign_key: :network_id

  has_paper_trail class_name: 'AuditLogItem'

  validates :number_max_length,
            presence: true,
            numericality: {
              allow_blank: true,
              only_integer: true,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: PgConst::SMALLINT_MAX
            }

  validates :number_min_length,
            presence: true,
            numericality: {
              allow_blank: true,
              only_integer: true,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: :number_max_length,
              if: :number_max_length
            }

  validates :prefix, uniqueness: { allow_blank: true }, presence: true
  validates :network, presence: true

  scope :number_contains, lambda { |prefix|
    where('prefix_range(sys.network_prefixes.prefix)@>prefix_range(?)', prefix.to_s)
  } do
    def longest_match_network
      order(Arel.sql('length(prefix) desc')).limit(1).take
    end
  end

  def self.prefix_hint(prefix)
    longest_match(prefix).try(:hint) || Yeti::NetworkDetector::EMPTY_NETWORK_HINT
  end

  def self.longest_match(prefix)
    number_contains(prefix).longest_match_network
  end

  def self.prefix_list_by_network(net)
    select("string_agg(prefix,', ') as prefix_list").where(network_id: net).to_a[0][:prefix_list]
  end

  def hint
    [country.try!(:name), network.try!(:name)].compact.join(',')
  end

  def self.ransackable_scopes(_auth_object = nil)
    [
      :number_contains
    ]
  end
end
