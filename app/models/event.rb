# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  command    :string           not null
#  retries    :integer          default(0), not null
#  node_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime
#  last_error :string
#

class Event < ActiveRecord::Base
  belongs_to :node


  CMD = {
        reload_registrations: 'request.registrations.reload',
        reload_translations: 'request.router.translations.reload',
        reload_codec_groups: 'request.router.codec-groups.reload', #'reload codecs_groups',
        reload_sensors: 'request.sensors.reload',
        reload_radius_auth_profiles: 'request.radius.authorization.profiles.reload',
        reload_radius_acc_profiles: 'request.radius.accounting.profiles.reload',
        reload_incoming_auth: 'request.auth.credentials.reload'
  }


  def self.reload_registrations(options = {})
    command = CMD[__method__] + ' ' + options[:id].to_s
    scope = Node.all
    if options[:node_id].present?
      scope = scope.where(id: options[:node_id].to_i)
    elsif options[:pop_id].present?
      scope = scope.where(pop_id: options[:pop_id].to_i)
    end
    create_events_for_nodes  command, scope

  end

  def self.reload_translations
    create_events_for_nodes CMD[__method__]
  end

  def self.reload_codec_groups
    create_events_for_nodes CMD[__method__]
  end

  def self.reload_radius_auth_profiles
    create_events_for_nodes CMD[__method__]
  end

  def self.reload_radius_acc_profiles
    create_events_for_nodes CMD[__method__]
  end

  def self.reload_sensors
    create_events_for_nodes CMD[__method__]
  end

  def self.reload_incoming_auth
    create_events_for_nodes CMD[__method__]
  end

  def self.create_events_for_nodes(command, node_scope = nil)
    node_scope = node_scope || Node.all
    node_scope.pluck(:id).each do |node_id|
      Event.create({node_id: node_id, command: command})
    end
  end


end
