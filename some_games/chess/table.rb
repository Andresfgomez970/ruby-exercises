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

  def draw_moved_piece(init_pos, final_pos)
    @pieces_spaces[final_pos[0]][final_pos[1]] = @pieces_spaces[init_pos[0]][init_pos[1]]
    @pieces_spaces[init_pos[0]][init_pos[1]] = ' '
  end

  def free_pos?(final_pos)
    @pieces_spaces[final_pos[0]][final_pos[1]] == ' '
  end

  def piece_in_pos(pos)
    @pieces_spaces[pos[0]][pos[1]]    
  end
end

class Array
  def sum_array(array)
    self.each_with_index { |elem, i| elem + array[i] } if self.length == array.length
  end
end

# Class for the chess table and the changes that are done to it.
class ChessTable < Table
  include PawnValidMoves
  include BishopValidMoves

  def initialize
    super({ n_rows: 8, n_columns: 8 })
    initialize_pieces_spaces
    initialize_pieces_arrays
    init_last_piece
    init_king_positions
  end

  def initialize_pieces_arrays
    @white_pieces = [WHITE_PAWN, WHITE_BISHOP, WHITE_ROOK, WHITE_KNIGHT, WHITE_QUEEN, WHITE_KING]
    @black_pieces = [BLACK_PAWN, BLACK_BISHOP, BLACK_ROOK, BLACK_KNIGHT, BLACK_QUEEN, BLACK_KING]
  end

  def initialize_pieces_spaces
    @pieces_spaces[0] = [WHITE_ROOK, WHITE_KNIGHT, WHITE_BISHOP, WHITE_QUEEN, WHITE_KING, WHITE_BISHOP, WHITE_KNIGHT, WHITE_ROOK]
    @pieces_spaces[1] = [WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN]
    @pieces_spaces[6] = [BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN]
    @pieces_spaces[7] = [BLACK_ROOK, BLACK_KNIGHT, BLACK_BISHOP, BLACK_QUEEN, BLACK_KING, BLACK_BISHOP, BLACK_KNIGHT, BLACK_ROOK]
  end

  def init_king_positions
    @white_king_position = [0, 4]
    @black_king_position = [7, 4]
  end

  def draw_board
    row_names = ('1'..'8').to_a
    super(row_names)
    # add column names
    puts one_level_row(('a'..'h').to_a, ' ')
    # add space for aesthetic purposes
    puts "\n"
  end

  def init_last_piece
    @last_piece_moved = nil
  end

  def get_pos(movement, from = 0)
    initial_col = movement[0 + from].ord - 'a'.ord
    initial_row = movement[1 + from].to_i - 1
    [initial_row, initial_col]
  end

  def move_piece(movement)
    # movement is a string with the algebraic notation of chess
    # for example: 'e2e4'
    # first two characters are the initial position
    # last two characters are the final position
    init_pos  = get_pos(movement)
    final_pos = get_pos(movement, 2)
    draw_moved_piece(init_pos, final_pos)
    @last_piece_moved = { 'final_pos': final_pos, 'forward_distance': (init_pos[0] - final_pos[0]).abs }
  end

  def check_white_pieces(piece, init_pos, final_pos)
    case piece
    when WHITE_PAWN then pawn_movement_valid?(init_pos, final_pos, 1)
    when WHITE_BISHOP then bishop_movement_valid?(init_pos, final_pos)
    when WHITE_ROOK then rook_movement_valid?(init_pos, final_pos)
    when WHITE_KNIGHT then knight_movement_valid?(init_pos, final_pos)
    when WHITE_QUEEN then queen_movement_valid?(init_pos, final_pos)
    when WHITE_KING then king_movement_valid?(init_pos, final_pos)
    end
  end

  def check_black_pieces(piece, init_pos, final_pos)
    case piece
    when BLACK_PAWN then pawn_movement_valid?(init_pos, final_pos, -1)
    when BLACK_BISHOP then bishop_movement_valid?(init_pos, final_pos)
    when BLACK_ROOK then rook_movement_valid?(init_pos, final_pos)
    when BLACK_KNIGHT then knight_movement_valid?(init_pos, final_pos)
    when BLACK_QUEEN then queen_movement_valid?(init_pos, final_pos)
    when BLACK_KING then king_movement_valid?(init_pos, final_pos)
    end
  end

  def some_piece_move?(piece, init_pos, final_pos)
    check_white_pieces(piece, init_pos, final_pos) || check_black_pieces(piece, init_pos, final_pos)
  end

  def correct_color_piece?(piece, player)
    player.color == 'white' ? @white_pieces.include?(piece) : @black_pieces.include?(piece)
  end

  def movement_variables(movement)
    init_pos  = get_pos(movement)
    final_pos = get_pos(movement, 2)
    piece = @pieces_spaces[init_pos[0]][init_pos[1]]
    [init_pos, final_pos, piece]
  end

  def check_of_pawns?(king_pos, sign)
    return false if king_pos[0] == 7 && sign == 1
    return false if king_pos[0].zero? && sign == -1

    contrary = { 1 => BLACK_PAWN, -1 => WHITE_PAWN }
    pos1_check = king_pos.sum_array([1 * sign, 1])
    pos2_check = king_pos.sum_array([1 * sign, -1])
    piece_in_pos(pos1_check) == contrary[sign] && piece || piece_in_pos(pos2_check) == contrary[sign]
  end

  def check?(player)
    king_pos, sign = player.chess_color == 'white' ? [@white_king_position, 1] : [@black_king_position, -1]    
    check_of_pawns?(king_pos, sign)
    # check_for_pawn(king_pos, sign)
    # check_for_bishops(king_pos)
    # check_for_rooks(king_pos)
    # check_for_knights(king_pos)
    # check_for_queens(king_pos)
    # check_for_kings(king_pos)
    # false
  end

  def check_afet_move?(init_pos, final_pos, player)
    false
  end

  def movement_valid?(movement, player)
    init_pos, final_pos, piece = movement_variables(movement)
    color = correct_color_piece?(piece, player)
    check_afer_move = check_afer_move?(init_pos, final_pos, player)
    move = some_piece_move?(piece, init_pos, final_pos)
    color && move && !check_afer_move
  end
end

require_relative 'user'

if __FILE__ == $PROGRAM_NAME
  table = ChessTable.new
  table.draw_board
  table.move_piece('f2f7')
  p table.check?(ChessGameUser.new({ chess_color: 'black' }))
  table.draw_board
end
