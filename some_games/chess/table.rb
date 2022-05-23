# frozen_string_literal: true
require_relative 'utils'
require_relative 'pieces'
require_relative 'chess_utils'
require_relative 'serialization_utils'

# Class that implements a basic table
class Table
  include BasicUtils
  include BasicSerializable

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

  def draw_board(row_names = Array.new(@n_rows, ' '))
    @n_rows.times do |index|
      # reverse index is used with the idea that the bottom would
      #   have the lower indexetion.
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

  def valid_pos?(pos)
    pos[0].between?(0, @n_rows - 1) && pos[1].between?(0, @n_columns - 1)
  end
end

# Class for the chess table and the changes that are done to it.
class ChessTable < Table
  include PawnValidMoves
  include BishopValidMoves
  include RookValidMoves
  include ChessCheckFunctionalities
  include QueenValidMoves
  include KingValidMoves
  include KnightValidMoves
  include ChessCorrectMovementFunctionalities

  def initialize
    super({ n_rows: 8, n_columns: 8 })
    default_initialize
  end

  def default_initialize
    super()
    initialize_pieces_spaces
    initialize_pieces_arrays
    init_last_piece
    init_king_positions
    init_castling_state
  end

  def initialize_pieces_spaces
    @pieces_spaces[0] = [WHITE_ROOK, WHITE_KNIGHT, WHITE_BISHOP, WHITE_QUEEN, WHITE_KING, WHITE_BISHOP, WHITE_KNIGHT, WHITE_ROOK]
    @pieces_spaces[1] = [WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN, WHITE_PAWN]
    @pieces_spaces[6] = [BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN, BLACK_PAWN]
    @pieces_spaces[7] = [BLACK_ROOK, BLACK_KNIGHT, BLACK_BISHOP, BLACK_QUEEN, BLACK_KING, BLACK_BISHOP, BLACK_KNIGHT, BLACK_ROOK]
  end

  def initialize_pieces_arrays
    @white_pieces = [WHITE_PAWN, WHITE_BISHOP, WHITE_ROOK, WHITE_KNIGHT, WHITE_QUEEN, WHITE_KING]
    @black_pieces = [BLACK_PAWN, BLACK_BISHOP, BLACK_ROOK, BLACK_KNIGHT, BLACK_QUEEN, BLACK_KING]
  end

  def init_last_piece
    @last_piece_moved = nil
  end

  def init_king_positions
    @white_king_position = [0, 4]
    @black_king_position = [7, 4]
  end

  def init_castling_state
    @castling_is_first_move = { 'white-right' => true, 'white-left' => true, 'black-right' => true,
                                'black-left' => true }
  end

  def draw_board
    # add correct row names
    row_names = ('1'..'8').to_a
    super(row_names)
    # add column names
    puts one_level_row(('a'..'h').to_a, ' ')
    # add space for aesthetic purposes
    puts "\n"
  end

  def get_pos(movement, from = 0)
    initial_col = movement[0 + from].ord - 'a'.ord
    initial_row = movement[1 + from].to_i - 1
    [initial_row, initial_col]
  end

  def update_king_positions(final_pos)
    @white_king_position = piece_in_pos(final_pos) == WHITE_KING ? final_pos : @white_king_position
    @black_king_position = piece_in_pos(final_pos) == BLACK_KING ? final_pos : @black_king_position
  end

  def update_castling_dictionary(pos, piece, king_moved, modify_key)
    @castling_is_first_move[modify_key] = false if piece_in_pos(pos) != piece || king_moved
  end

  def update_castling_state
    white_king_moved = @white_king_position != [0, 4]
    black_king_moved = @black_king_position != [7, 4]
    update_castling_dictionary([0, 7], WHITE_ROOK, white_king_moved, 'white-right')
    update_castling_dictionary([0, 0], WHITE_ROOK, white_king_moved, 'white-left')
    update_castling_dictionary([7, 7], BLACK_ROOK, black_king_moved, 'black-right')
    update_castling_dictionary([7, 0], BLACK_ROOK, black_king_moved, 'black-left')
  end

  def update_last_piece_moved(init_pos, final_pos)
    @last_piece_moved = { 'final_pos': final_pos, 'forward_distance': (init_pos[0] - final_pos[0]).abs }
  end

  def update_state_variables(movement)
    init_pos  = get_pos(movement)
    final_pos = get_pos(movement, 2)
    update_last_piece_moved(init_pos, final_pos)
    update_king_positions(final_pos)
    update_castling_state
  end

  def update_table_state(movement)
    move_piece(movement)
    update_state_variables(movement)
  end

  def move_piece(movement)
    # movement is a string with the algebraic notation of chess
    # for example: 'e2e4'
    # first two characters are the initial position
    # last two characters are the final position
    init_pos  = get_pos(movement)
    final_pos = get_pos(movement, 2)
    draw_moved_piece(init_pos, final_pos)
  end

  def movement_variables(movement)
    init_pos  = get_pos(movement)
    final_pos = get_pos(movement, 2)
    piece = @pieces_spaces[init_pos[0]][init_pos[1]]
    [init_pos, final_pos, piece]
  end

  def draw_game?
    false
  end
end

require_relative 'user'

if __FILE__ == $PROGRAM_NAME
  table = ChessTable.new
  p table.serialize
end