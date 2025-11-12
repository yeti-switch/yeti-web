# frozen_string_literal: true

class Routing::RoutingTagMode
  MODE_OR = 0
  MODE_AND = 1
  MODE_IN = 2

  MODES = {
    MODE_OR => 'OR',
    MODE_AND => 'AND',
    MODE_IN => 'IN'
  }.freeze

  def self.separator(id)
    if id == MODE_OR
      ' <b>|</b> '
    elsif id == MODE_AND
      ' <b>&</b> '
    elsif id == MODE_IN
      '<b>, </b>'
    end
  end

  def and?
    id == CONST::AND
  end
end
