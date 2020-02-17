# frozen_string_literal: true

class PolicyAdapter < ActiveAdmin::PunditAdapter
  class_attribute :logger, instance_writer: false, default: Rails.logger

  def pretty_subject(subject)
    subject.respond_to?(:id) ? "#{subject.class}##{subject.id}" : subject.to_s
  end

  def pretty_user(user)
    return '<NULL>' if user.nil?

    "<#{user.class} id=#{user.id} username=#{user.username.inspect} roles=#{user.roles.join(',').inspect}>"
  rescue StandardError => _e
    user.to_s
  end

  def authorized?(action, subject, invalid_action: nil)
    policy = retrieve_policy(subject)
    action = format_action(action, subject)

    unless policy.respond_to?(action)
      logger.warn { "[POLICY] invalid action #{action} for policy #{policy.class}" }
      invalid_action&.call("Invalid action #{action} for policy #{policy.class}")
      return false
    end

    policy.public_send(action)
  end
end
