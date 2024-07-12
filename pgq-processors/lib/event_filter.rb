# frozen_string_literal: true

class EventFilter
  OPERATORS = %i[
    eq not_eq
    start_with end_with contains
    gt lt gte lte
    in not_in
    null not_null
    true false
  ].freeze

  attr_reader :field, :op, :value

  def initialize(field:, op:, value:)
    @field = field.to_s
    @op = op.to_sym
    raise ArgumentError, "Invalid operator: #{@op}" unless OPERATORS.include?(@op)

    @value = value
  end

  def match?(event)
    send("match_#{op}?", event.transform_keys(&:to_s))
  end

  private

  def match_eq?(event)
    event[field] == value
  end

  def match_not_eq?(event)
    event[field] != value
  end

  def match_start_with?(event)
    event[field].to_s.start_with?(value.to_s)
  end

  def match_end_with?(event)
    event[field].to_s.end_with?(value.to_s)
  end

  def match_contains?(event)
    event[field].to_s.include?(value.to_s)
  end

  def match_gt?(event)
    !event[field].nil? && event[field] > value
  end

  def match_lt?(event)
    !event[field].nil? && event[field] < value
  end

  def match_gte?(event)
    !event[field].nil? && event[field] >= value
  end

  def match_lte?(event)
    !event[field].nil? && event[field] <= value
  end

  def match_in?(event)
    value.include?(event[field])
  end

  def match_not_in?(event)
    value.exclude?(event[field])
  end

  def match_null?(event)
    event[field].nil?
  end

  def match_not_null?(event)
    !event[field].nil?
  end

  def match_true?(event)
    event[field] == true
  end

  def match_false?(event)
    event[field] == false
  end
end
