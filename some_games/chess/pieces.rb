# frozen_string_literal: true

# Constants for initialization of pieces
WHITE_KING = "\u265A"
WHITE_QUEEN = "\u265B"
WHITE_ROOK = "\u265C"
WHITE_BISHOP = "\u265D"
WHITE_KNIGHT = "\u265E"
WHITE_PAWN = "\u265F"

BLACK_KING = "\u2654"
BLACK_QUEEN = "\u2655"
BLACK_ROOK = "\u2656"
BLACK_BISHOP = "\u2657"
BLACK_KNIGHT = "\u2658"
BLACK_PAWN = "\u2659"

# class like this?
class Piece
  def initialize(initial = nil, symbol = nil)
    @initial = initial
    @symbol = symbol
  end
end

# module for valid moves of pawns
module PawnValidMoves
  def one_step?(init_pos, final_pos, sign)
    init_pos[1] == final_pos[1] && (final_pos[0] - init_pos[0]) == 1 * sign && free_pos?(final_pos)
  end

  def two_setps?(init_pos, final_pos, sign)
    (final_pos[0] - init_pos[0]) == 2 * sign && free_pos?(final_pos)
  end

  def correct_initial_pos?(init_pos, sign)
    (init_pos[0] == 1 && sign == 1) || (init_pos[0] == 6 && sign == -1)
  end

  def valid_pawn_forward_move?(init_pos, final_pos, sign)
    one_step = one_step?(init_pos, final_pos, sign)
    two_setps = two_setps?(init_pos, final_pos, sign)
    correct_initial_pos = correct_initial_pos?(init_pos, sign)
    one_step || (two_setps && correct_initial_pos)
  end

  def diagonal?(init_pos, final_pos, sign)
    (final_pos[0] - init_pos[0]) == 1 * sign && (final_pos[1] - init_pos[1]).abs == 1
  end

  def valid_pawn_diagonal_move?(init_pos, final_pos, sign)
    diagonal = diagonal?(init_pos, final_pos, sign)
    pieces_to_check = sign == 1 ? @black_pieces : @white_pieces
    eat = pieces_to_check.include?(@pieces_spaces[final_pos[0]][final_pos[1]])
    diagonal && eat
  end

  def passant_move?(final_pos)
    return false if @last_piece_moved.nil?

    pos_last_piece = @last_piece_moved[:final_pos]
    # condition for passant to work
    if @last_piece_moved[:forward_distance] == 2 && @pieces_spaces[pos_last_piece[0]][pos_last_piece[1]] == BLACK_PAWN
      passant = @pieces_spaces[final_pos[0] - 1][final_pos[1]] == BLACK_PAWN
    elsif @last_piece_moved[:forward_distance] == 2 && @pieces_spaces[pos_last_piece[0]][pos_last_piece[1]] == WHITE_PAWN
      passant = @pieces_spaces[final_pos[0] + 1][final_pos[1]] == WHITE_PAWN
    else
      passant = false
    end
    @pieces_spaces[pos_last_piece[0]][pos_last_piece[1]] = ' ' if passant
    passant
  end

  def valid_en_passant_move?(init_pos, final_pos, sign)
    diagonal = diagonal?(init_pos, final_pos, sign)
    passant = passant_move?(final_pos)
    diagonal && passant
  end

  def pawn_movement_valid?(init_pos, final_pos, sign)
    move1_state = valid_pawn_forward_move?(init_pos, final_pos, sign)
    move2_state = valid_pawn_diagonal_move?(init_pos, final_pos, sign)
    move3_state = valid_en_passant_move?(init_pos, final_pos, sign)
    move1_state || move2_state || move3_state
  end
end


module BishopValidMoves
  def bishop_movement_valid?(init_pos, final_pos)
  end

  def rook_movement_valid?(init_pos, final_pos)
  end

  def queen_movement_valid?(init_pos, final_pos)
  end

  def king_movement_valid?(init_pos, final_pos)
  end

  def knight_movement_valid?(init_pos, final_pos)
  end

end