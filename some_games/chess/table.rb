# frozen_string_literal: true
require_relative 'utils'
require_relative 'pieces'


# Class that implements a basic table
class Table
  include BasicUtils

  def initialize(table_params = { n_rows: 0, n_columns: 0 })
    @n_rows = table_params.fetch(:n_rows, 0)
    @n_columns = table_params.fetch(:n_columns, 0)
    default_initialize
  end

  def default_initialize
    @pieces_spaces = default_pieces_spaces
  end

  def default_pieces_spaces
    Array.new(@n_rows) { Array.new(@n_columns, ' ') }
  end

  def one_level_row(symbols_of_row = Array.new(@n_columns, ' '), separator = '|')
    symbols_of_row.each.reduce("   #{separator}") { |sum, symbol| "#{sum}   #{symbol}   #{separator}" }
  end

  def line
    "   #{'-' * (@n_columns * 8 + 1).floor}  \n"
  end

  def row(symbols_of_row = Array.new(@n_columns, ' '), row_name = ' ')
    # Fist level
    row_res = line
    middle_line = one_level_row(symbols_of_row)
    middle_line[0] = row_name
    row_res += "#{one_level_row}\n#{middle_line}\n#{one_level_row}"
    # support above
    row_res
  end

  def reverse_index(array, index)
    array.length - index - 1
  end

  def draw_board(row_names = Array.new(@n_rows, ' '))
    @n_rows.times do |index|
      reverse_i = reverse_index(@pieces_spaces, index)
      puts row(@pieces_spaces[reverse_i], row_names[reverse_i])
    end
    # draw last support below
    puts line
  end
end

# Class for the chess table and the changes that are done to it.
class ChessTable < Table
  def initialize
    super({ n_rows: 8, n_columns: 8 })
    initialize_pieces_spaces
  end

  def draw_board
    row_names = ('1'..'8').to_a.reverse
    super(row_names)
    # add column names
    puts one_level_row(('a'..'h').to_a, ' ')
    # add space for aesthetic purposes
    puts "\n"
  end

  def initialize_pieces_spaces
    @pieces_spaces[0] = [WHITE_ROOK, WHITE_KNIGHT, WHITE_BISHOP, WHITE_QUEEN, WHITE_KING, WHITE_BISHOP, WHITE_KNIGHT, WHITE_ROOK]
    @pieces_spaces[1] = [WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN]
    @pieces_spaces[6] = [BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN]
    @pieces_spaces[7] = [BLACK_ROOK, BLACK_KNIGHT, BLACK_BISHOP, BLACK_QUEEN, BLACK_KING, BLACK_BISHOP, BLACK_KNIGHT, BLACK_ROOK]
  end

  def move_piece(movement)
    # movement is a string with the algebraic notation of chess
    # for example: 'e2e4'
    # first two characters are the initial position
    # last two characters are the final position
    initial_row = movement[1].to_i - 1
    initial_column = movement[0].ord - 'a'.ord
    final_row = movement[3].to_i - 1
    final_column = movement[2].ord - 'a'.ord
    @pieces_spaces[final_row][final_column] = @pieces_spaces[initial_row][initial_column]
    @pieces_spaces[initial_row][initial_column] = ' '
  end
end

table = ChessTable.new
table.draw_board
table.move_piece('e2e4')
table.draw_board