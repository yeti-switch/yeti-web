# frozen_string_literal: true

# == Schema Information
#
# Table name: nodes
#
#  id           :integer(4)       not null, primary key
#  name         :string
#  rpc_endpoint :string
#  pop_id       :integer(4)       not null
#
# Indexes
#
#  node_name_key           (name) UNIQUE
#  nodes_rpc_endpoint_key  (rpc_endpoint) UNIQUE
#
# Foreign Keys
#
#  node_pop_id_fkey  (pop_id => pops.id)
#

class Node < ApplicationRecord
  include WithPaperTrail

  belongs_to :pop

  validates :id, :pop, :rpc_endpoint, :name, presence: true
  validates :id, :name, :rpc_endpoint, uniqueness: true

  has_many :events, dependent: :destroy
  has_many :registrations, class_name: 'Equipment::Registration', dependent: :restrict_with_error

  def self.random_node
    ids = pluck(:id)
    find(ids.sample)
  end

  def api
    NodeApi.find(rpc_endpoint)
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

  delegate :stats, to: :api

  delegate :system_status, to: :api

  def clear_cache
    api.router_cache_clear
  end

  def drop_call(id)
    api.call_disconnect(id)
  end

  # jsonrpc call 'yeti.show.aors'
  # @param auth_id [Integer] - filter by gateway.id (nil to show all data)
  def incoming_registrations(auth_id: nil, empty_on_error: false)
    params = auth_id.nil? ? [] : [auth_id]
    api.aors(params)
  rescue StandardError => e
    if empty_on_error
      logger.error { "Failed to fetch incoming_registrations with auth_id=#{auth_id.inspect}" }
      logger.error { "<#{e.class}>: #{e.message}" }
      logger.error { e.backtrace.join("\n") }
      CaptureError.capture(e, extra: { model_class: self.class.name, auth_id: auth_id })
      []
    else
      raise e
    end
  end

  # def calls(only = nil, empty_on_error = true)
  def calls(options = {})
    empty_on_error = !!options[:empty_on_error]
    args = []
    method_name = :calls
    if options[:only]
      method_name = :calls_filtered
      args << options[:only]
    end
    if options[:where]
      args << 'WHERE'
      args << options[:where]
    end

    begin
      api.public_send(method_name, *args.flatten)
    rescue NodeApi::ConnectionError => e
      if empty_on_error
        logger.warn { "#{e.class} #{e.message}" }
        []
      else
        raise e
      end
    rescue StandardError => e
      if empty_on_error
        logger.warn { "#{e.class} #{e.message}" }
        logger.warn { e.backtrace.join '\n' }
        CaptureError.capture(e)
        []
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
