# frozen_string_literal: true

# The table for the given game
class Table
  ##
  # Table define a class that constains the data which is drawn in the
  #   tictactoe game

  def initialize
    @symbols = init_symbols
  end

  def init_symbols
    (1..9).to_a
  end

  def draw_row(col1, col2, col3)
    puts "\t\t . \t ."
    puts "\t    #{col1} \t .   #{col2} \t .   #{col3}"
    puts "\t\t . \t ."
  end

  def draw_line
    puts "\t. . . . . . . . . . . . . ."
  end

  def draw_table
    puts "\n\n"
    draw_row(@symbols[0], @symbols[1], @symbols[2])
    draw_line
    draw_row(@symbols[3], @symbols[4], @symbols[5])
    draw_line
    draw_row(@symbols[6], @symbols[7], @symbols[8])
    puts "\n\n"
  end

  def update_symbols(index, symbol)
    @symbols[index] = symbol
  end

  def get_symbol(index)
    @symbols[index]
  end

  def get_symbols
    @symbols
  end

  def coincide_symbols(indexes)
    @symbols[indexes[0]] == @symbols[indexes[1]] &&
      @symbols[indexes[0]] == @symbols[indexes[2]]
  end
end