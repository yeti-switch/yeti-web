# frozen_string_literal: true

# == Schema Information
#
# Table name: nodes
#
#  id              :integer          not null, primary key
#  signalling_ip   :string
#  signalling_port :integer
#  name            :string
#  pop_id          :integer          not null
#  rpc_endpoint    :string
#

class Node < ActiveRecord::Base
  belongs_to :pop

  validates_presence_of :pop, :signalling_ip, :signalling_port, :rpc_endpoint, :name
  validates :name, uniqueness: true
  #  validates :rpc_uri, format: URI::regexp(%w(http https))

  validates_uniqueness_of :rpc_endpoint

  has_many :events, dependent: :destroy
  has_many :registrations, class_name: 'Equipment::Registration', dependent: :restrict_with_error

  has_paper_trail class_name: 'AuditLogItem'

  def self.random_node
    ids = pluck(:id)
    find(ids.sample)
  end

  def api
    @api ||= YetisNode::Client.new(rpc_endpoint, transport: :json_rpc, logger: logger)
  end

  def total_calls_count
    api.calls_count
  end

  # todo
  # add empty_on_error option handling (same as ActiveCalls)
  def registration(id)
    RealtimeData::OutgoingRegistration.new(api.registrations(id))
  end

  def registrations
    RealtimeData::OutgoingRegistration.collection(api.registrations)
  end

  def total_registrations_count
    api.registrations_count
  end

  def stats
    api.stats
  end

  def system_status
    api.system_status
  end

  def clear_cache
    api.router_cache_clear
  end

  def drop_call(id)
    api.call_disconnect(id)
  end

  # def calls(only = nil, empty_on_error = true)
  def calls(options = {})
    empty_on_error = !!options[:empty_on_error]
    args = []
    method_name = +'calls'
    if options[:only]
      method_name << '.filtered'
      args << options[:only]
    end
    if options[:where]
      args << 'WHERE'
      args << options[:where]
    end

    begin
      api.invoke_show_command(method_name, args.flatten)
    rescue StandardError => e
      if empty_on_error
        logger.warn { e.message }
        logger.warn { e.backtrace.join '\n' }
        return []
      else
        raise e
      end
    end
  end

  def as_json(options)
    super(options.merge(include: :pop))
  end

  def active_call(id)
    RealtimeData::ActiveCall.new(api.calls(id))
  end

  def active_calls(only = nil)
    if only
      RealtimeData::ActiveCall.collection(api.calls_filtered(only))
    else
      RealtimeData::ActiveCall.collection(api.calls)
    end
  end
end
