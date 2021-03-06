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

# general class for the movement of pieces
module ValidMovesUtils
  def diagonal?(init_pos, final_pos)
    (init_pos[0] - final_pos[0]).abs == (init_pos[1] - final_pos[1]).abs
  end

  def line_movement?(init_pos, final_pos)
    row = (init_pos[0] - final_pos[0]).abs.positive? && init_pos[1] == final_pos[1]
    col = (init_pos[1] - final_pos[1]).abs.positive? && init_pos[0] == final_pos[0]
    row || col
  end

  def diag_step_move(init_pos, final_pos)
    step = [nil, nil]
    step[0] = final_pos[0] > init_pos[0] ? 1 : -1
    step[1] = final_pos[1] > init_pos[1] ? 1 : -1
    step
  end

  def line_step_move(init_pos, final_pos)
    step = [nil, nil]
    step[0] = (final_pos[0] - init_pos[0]) <=> 0
    step[1] = (final_pos[1] - init_pos[1]) <=> 0
    step
  end

  def diag_valid_path?(init_pos, final_pos, sign)
    step = diag_step_move(init_pos, final_pos)
    same_pieces = sign == 1 ? @white_pieces : @black_pieces
    n_steps = (init_pos[0] - final_pos[0]).abs
    check_valid_path?(init_pos, same_pieces, step, n_steps)
  end

  def line_valid_path?(init_pos, final_pos, sign)
    step = line_step_move(init_pos, final_pos)
    same_pieces = sign == 1 ? @white_pieces : @black_pieces
    n_steps = (init_pos[0] - final_pos[0]).abs + (init_pos[1] - final_pos[1]).abs
    check_valid_path?(init_pos, same_pieces, step, n_steps)
  end

  def check_valid_path?(init_pos, same_pieces, step, n_steps)
    # check free path
    actual_pos = init_pos
    (n_steps - 1).times do |_|
      actual_pos = actual_pos.sum_array(step)
      watch_piece = piece_in_pos(actual_pos)
      return false if watch_piece != ' '
    end
    # check last is free or that it can be eaten
    actual_pos = actual_pos.sum_array(step)
    watch_piece = piece_in_pos(actual_pos)
    same_pieces.include?(watch_piece) ? false : true
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

  def pawn_diagonal?(init_pos, final_pos, sign)
    (final_pos[0] - init_pos[0]) == 1 * sign && (final_pos[1] - init_pos[1]).abs == 1
  end

  def valid_pawn_diagonal_move?(init_pos, final_pos, sign)
    diagonal = pawn_diagonal?(init_pos, final_pos, sign)
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

  def valid_en_passant_move?(init_pos, final_pos)
    diagonal = diagonal?(init_pos, final_pos)
    passant = passant_move?(final_pos)
    diagonal && passant
  end

  def pawn_movement_valid?(init_pos, final_pos, sign)
    move1_state = valid_pawn_forward_move?(init_pos, final_pos, sign)
    move2_state = valid_pawn_diagonal_move?(init_pos, final_pos, sign)
    move3_state = valid_en_passant_move?(init_pos, final_pos)
    move1_state || move2_state || move3_state
  end
end

# implement all valid moves for bishop
module BishopValidMoves
  include ValidMovesUtils

  def bishop_movement_valid?(init_pos, final_pos, sign)
    diagonal = diagonal?(init_pos, final_pos)
    valid_path = diagonal ? diag_valid_path?(init_pos, final_pos, sign) : false
    diagonal && valid_path
  end
end

# implement all valid moves for rook
module RookValidMoves
  include ValidMovesUtils

  def rook_movement_valid?(init_pos, final_pos, sign)
    line_move = line_movement?(init_pos, final_pos)
    valid_path = line_move ? line_valid_path?(init_pos, final_pos, sign) : false
    line_move && valid_path
  end
end

# implement all valid moves for queen
module QueenValidMoves
  include BishopValidMoves
  include RookValidMoves

  def queen_movement_valid?(init_pos, final_pos, sign)
    rook_movement_valid?(init_pos, final_pos, sign) || bishop_movement_valid?(init_pos, final_pos, sign)
  end
end

# implement all valid moves for king
module KingValidMoves
  def king_movement_valid?(init_pos, final_pos, sign)
    x0 = (init_pos[0] - final_pos[0]).abs
    x1 = (init_pos[1] - final_pos[1]).abs
    distance = x0 + x1
    diag1 = x0 == 1 && x1 == 1
    same_pieces = sign == 1 ? @white_pieces : @black_pieces
    castling = castling?(init_pos, final_pos, sign)
    # Note that check after move is checked independently
    (distance == 1 || diag1) && !same_pieces.include?(get_pos(final_pos)) || castling
  end

  def castling_is_first_moved?(init_pos, final_pos, sign)
    row_to_check, color = sign == 1 ? [0, 'white'] : [7, 'black']
    if init_pos == [row_to_check, 4] && final_pos == [row_to_check, 2]
      return @castling_is_first_move["#{color}-left"]
    elsif init_pos == [row_to_check, 4] && final_pos == [row_to_check, 6]
      return @castling_is_first_move["#{color}-right"]
    end
    false
  end

  def direction_to_check(final_pos, row_to_check)
    case final_pos
    when [row_to_check, 6] then 1
    when [row_to_check, 2] then -1
    else 0
    end
  end

  def castling_free_path?(init_pos, final_pos, sign)
    row_to_check = sign == 1 ? 0 : 7
    step = direction_to_check(final_pos, row_to_check)
    return false if step.zero?

    actual_pos = init_pos
    2.times do |_|
      actual_pos = actual_pos.sum_array([0, step])
      return false if piece_in_pos(actual_pos) != ' '
    end
    true
  end

  def castling_not_check?(init_pos, final_pos, sign)
    row_to_check = sign == 1 ? 0 : 7
    step = direction_to_check(final_pos, row_to_check)
    return false if step.zero?

    3.times do |index|
      actual_pos = init_pos.sum_array([0, step * index])
      return false if piece_can_be_eaten?(actual_pos, sign)
    end
    true
  end

  def update_castling_rook(init_pos, final_pos, sign)
    row_to_check = sign == 1 ? 0 : 7
    if init_pos == [row_to_check, 4] && final_pos == [row_to_check, 2]
      draw_moved_piece([row_to_check, 0], [row_to_check, 3])
    elsif init_pos == [row_to_check, 4] && final_pos == [row_to_check, 6]
      draw_moved_piece([row_to_check, 7], [row_to_check, 5])
    end
    false
  end

  def castling?(init_pos, final_pos, sign)
    castling_is_first_moved = castling_is_first_moved?(init_pos, final_pos, sign)
    castling_free_path = castling_free_path?(init_pos, final_pos, sign)
    castling_not_check = castling_not_check?(init_pos, final_pos, sign)
    castling_condition = castling_is_first_moved && castling_free_path && castling_not_check
    update_castling_rook(init_pos, final_pos, sign) if castling_condition
    castling_condition
  end
end

# implement all valid moves for knight
module KnightValidMoves
  def knight_movement_valid?(init_pos, final_pos, sign)
    x0 = (init_pos[0] - final_pos[0]).abs
    x1 = (init_pos[1] - final_pos[1]).abs
    same_pieces = sign == 1 ? @white_pieces : @black_pieces
    l_move = (x0 == 2 && x1 == 1) || (x0 == 1 && x1 == 2)
    l_move && valid_pos?(final_pos) && !same_pieces.include?(get_pos(final_pos))
  end
end
