# frozen_string_literal: true

class SipOptionsProberDecorator < ApplicationDecorator
  def self.object_class_namespace
    'RealtimeData'
  end

  RealtimeData::SipOptionsProber.association_types.each do |name, foreign_key:, **_|
    define_method("#{name}_link") do
      record = model.public_send(name)
      record ? h.auto_link(record) : model.public_send(foreign_key)
    end

    def id_link
      computed_id = "#{model.node.id}*#{model.id}"
      h.link_to model.id, sip_options_prober_path(computed_id)
    end

    def equipment_sip_options_prober_link
      h.link_to model.name, equipment_sip_options_prober_path(model.id)
    end
  end
end
