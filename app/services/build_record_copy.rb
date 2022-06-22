# frozen_string_literal: true

class BuildRecordCopy < ApplicationService
  parameter :from, required: true
  # The links assign associations from original record to a copy.
  # Usage: has_and_belongs_to_many associations.
  parameter :links, default: []
  # The duplicates creates copies of associations from original record to a copy.
  # Usage: has_many, has_one associations.
  parameter :duplicates, default: []

  def call
    attributes = build_attributes
    links.each { |name| attributes[name] = build_assoc_link(name) }
    duplicates.each { |name| attributes[name] = build_assoc_dup(name) }
    from.class.new(attributes)
  end

  private

  def build_attributes
    from.dup.attributes
  rescue StandardError
    {}
  end

  def build_assoc_link(name)
    from.public_send(name).to_a
  end

  def build_assoc_dup(name)
    assoc = from.public_send(name)
    assoc.respond_to?(:to_a) ? assoc.to_a.map(&:dup) : assoc.dup
  end
end
