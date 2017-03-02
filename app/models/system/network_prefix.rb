# == Schema Information
#
# Table name: sys.network_prefixes
#
#  id         :integer          not null, primary key
#  prefix     :string           not null
#  network_id :integer          not null
#  country_id :integer
#

class System::NetworkPrefix < Yeti::ActiveRecord
  self.table_name = 'sys.network_prefixes'
  belongs_to :country, class_name: 'System::Country', foreign_key: :country_id
  belongs_to :network, class_name: 'System::Network', foreign_key: :network_id

  has_paper_trail class_name: 'AuditLogItem'


  validates_uniqueness_of :prefix
  validates_presence_of :prefix, :network
  scope :number_contains, ->(prefix) {  where('prefix_range(sys.network_prefixes.prefix)@>prefix_range(?)', "#{prefix}") } do
    def longest_match_network
      order("length(prefix) desc").limit(1).take
    end
  end


  def self.prefix_hint(prefix)
    self.longest_match(prefix).try(:hint) || Yeti::NetworkDetector::EMPTY_NETWORK_HINT
  end

  def self.longest_match(prefix)
    number_contains(prefix).longest_match_network
  end

  def self.prefix_list_by_network(net)
    self.select("string_agg(prefix,', ') as prefix_list").where(network_id: net).to_a[0][:prefix_list]
  end

  def hint
    [self.country.try!(:name), self.network.try!(:name)].compact.join(",")
  end

  private

  def self.ransackable_scopes(auth_object = nil)
    [
        :number_contains
    ]
  end



end
