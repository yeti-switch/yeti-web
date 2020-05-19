# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.rateplans
#
#  id                     :integer          not null, primary key
#  name                   :string
#  profit_control_mode_id :integer          default(1), not null
#  send_quality_alarms_to :integer          is an Array
#  uuid                   :uuid             not null
#

class Rateplan < ActiveRecord::Base
  self.table_name = 'class4.rateplans'

  has_paper_trail class_name: 'AuditLogItem'

  belongs_to :profit_control_mode, class_name: 'Routing::RateProfitControlMode', foreign_key: 'profit_control_mode_id'
  has_many :customers_auths, dependent: :restrict_with_error
  has_many :destinations, class_name: 'Routing::Destination', foreign_key: :rateplan_id, dependent: :destroy

  scope :where_customer, lambda { |id|
    joins(:customers_auths).where(CustomersAuth.table_name => { customer_id: id })
  }

  scope :where_account, lambda { |id|
    joins(:customers_auths).where(CustomersAuth.table_name => { account_id: id })
  }

  validates :name, :profit_control_mode, presence: true
  validates :name, uniqueness: { allow_blank: false }

  validate do
    if send_quality_alarms_to.present? && send_quality_alarms_to.any?
      errors.add(:send_quality_alarms_to, :invalid) if contacts.count != send_quality_alarms_to.count
    end
  end

  def display_name
    "#{name} | #{id}"
  end

  def send_quality_alarms_to=(send_to_ids)
    # This "else" statement is needed only cause of this PR
    # https://github.com/yeti-switch/yeti-web/pull/129
    # TODO: Rewrite PR #129 in other way and remove this hotfix here
    self[:send_quality_alarms_to] = if send_to_ids.is_a?(Array)
                                      send_to_ids.reject(&:blank?)
                                    else
                                      send_to_ids # hotfix
                                    end
  end

  def contacts
    @contacts ||= Billing::Contact.where(id: send_quality_alarms_to)
  end

  def number_rates(number)
    sql_query = %{
      SELECT *
      FROM (
        SELECT
        d.*,
        rank() OVER (
          PARTITION BY d.routing_tag_ids
          ORDER BY length(prefix_range(prefix)) DESC
        ) AS rank
        FROM class4.destinations d
        WHERE
          prefix_range(prefix)@>prefix_range('#{number}')
            AND rateplan_id=#{id}
            AND enabled
            AND valid_from <= now()
            AND valid_till >= now()
      ) AS data
      WHERE data.rank=1;
    }
    result = self.class.connection.exec_query(sql_query)
    return [] if result.empty?

    # fix boolean columns: 't' => true, 'f' => false
    res = result.cast_values.map { |values| Hash[[result.columns, values].transpose] }
    # routing_tag_ids => routing_tag_names
    res.map do |el|
      el['valid_from'] = el['valid_from'].in_time_zone.iso8601(3)
      el['valid_till'] = el['valid_till'].in_time_zone.iso8601(3)
      names = el['routing_tag_ids'].map { |id| routing_tag_collection[id] }
      el['routing_tag_names'] = names
      el
    end
  end

  private

  def routing_tag_collection
    @routing_tag_collection ||= Routing::RoutingTag.pluck(:id, :name).to_h
  end
end
