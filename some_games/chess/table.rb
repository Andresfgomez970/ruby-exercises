# frozen_string_literal: true
require_relative 'utils'

class Table
  include BasicUtils

  def initialize
    default_initialize
  end

  def default_initialize; end
end


class ChessTable < Table
end
