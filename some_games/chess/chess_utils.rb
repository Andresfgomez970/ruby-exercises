# frozen_string_literal: true

require_relative 'utils'

# define some basic chess utils useful for the rest of utils
module BasicChessUtils
  def actual_king_pos(player)
    player.chess_color == 'white' ? @white_king_position : @black_king_position
  end

  def possible_king_steps
    [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]
  end

  def allied_pieces(player)
    player.chess_color == 'white' ? @white_pieces : @black_pieces
  end

  def acronym_to_piece
    { 'bB' => BLACK_BISHOP, 'bK' => BLACK_KING, 'bQ' => BLACK_QUEEN,
      'bR' => BLACK_ROOK, 'be' => BLACK_PAWN, 'bN' => BLACK_KNIGHT,
      'wB' => WHITE_BISHOP, 'wK' => WHITE_KING, 'wQ' => WHITE_QUEEN,
      'wR' => WHITE_ROOK, 'we' => WHITE_PAWN, 'wN' => WHITE_KNIGHT,
      'b' => BLACK_PAWN, 'w' => BLACK_PAWN
    }
  end
end

# functionalities to check for check in chess game
module ChessCheckFunctionalities
  include BasicChessUtils

  ########
  # Pawns
  def check_of_pawns?(pos, sign, return_pos = false)
    return false if (pos[0] == 7 && sign == 1) || (pos[0].zero? && sign == -1)

    menacing_piece = { 1 => BLACK_PAWN, -1 => WHITE_PAWN }[sign]
    pos_pawn1, pos_pawn2 = possible_menacing_pawns_pos(pos, sign)
    menacing_pawn1, menacing_pawn2 = pawn_menacing_states(pos_pawn1, pos_pawn2, menacing_piece)
    return menacing_pawn(pos_pawn1, pos_pawn2, menacing_pawn1, menacing_pawn2) if return_pos

    menacing_pawn1 || menacing_pawn2
  end

  def possible_menacing_pawns_pos(pos, sign)
    [1, -1].each.map { |val| pos.sum_array([1 * sign, val]) }
  end

  def pawn_menacing_states(pos_pawn1, pos_pawn2, menacing_piece)
    [pos_pawn1, pos_pawn2].each.map { |pos| piece_in_pos(pos) == menacing_piece }
  end

  def menacing_pawn(pos_p1, pos_p2, state1, state2)
    return pos_p1 if state1
    return pos_p2 if state2
  end

  ########
  # Function to find alllied and menacing pieces searching for check in rooks, queen and bishop like moevments
  def menacing_and_allied_pieces(sign, check_type)
    case check_type
    when 'rq' then menacing_pieces = { 1 => [BLACK_ROOK, BLACK_QUEEN], -1 => [WHITE_ROOK, WHITE_QUEEN] }[sign]
    when 'bq' then menacing_pieces = { 1 => [BLACK_BISHOP, BLACK_QUEEN], -1 => [WHITE_BISHOP, WHITE_QUEEN] }[sign]
    end
    same_pieces = sign == 1 ? @white_pieces : @black_pieces
    [menacing_pieces, same_pieces]
  end

  ########
  # Rooks and queen in movements like a rook
  def check_of_rooks_or_queen?(pos, sign, return_pos = false)
    menacing_pieces, same_pieces = menacing_and_allied_pieces(sign, 'rq')
    check_states = [[1, 0], [-1, 0], [0, 1], [0, -1]].each.map do |step|
      n_steps = 7 * heaviside(step.sum) - pos[step.find_index(step.sum)] * step.sum
      check_along?(pos, menacing_pieces, same_pieces, n_steps, step)
    end
    return check_states.reduce(true) { |_, el| el != true ? el : true } if return_pos

    check_states.all?
  end

  ########
  # Rooks and queen in movements like a bishop
  def check_of_bishops_or_queen?(pos, sign, return_pos = false)
    menacing_pieces, same_pieces = menacing_and_allied_pieces(sign, 'bq')
    check_states = [[1, 1], [-1, -1], [1, - 1], [-1, 1]].each.map do |s|
      n_steps = 2.times.map { |i| 7 * heaviside(s[i]) - pos[i] * s[i] }.min
      check_along?(pos, menacing_pieces, same_pieces, n_steps, s, return_pos)
    end
    return check_states.reduce(true) { |_, el| el != true ? el : true } if return_pos

    check_states.all?
  end

  ########
  # Knights
  def check_of_knights?(pos, sign, return_pos = false)
    steps = [[2, 1], [2, -1], [1, 2], [1, -2], [-2, 1], [-2, -1], [-1, 2], [-1, -2]]

    menacing_piece = { 1 => BLACK_KNIGHT, -1 => WHITE_KNIGHT }[sign]
    steps.each do |step|
      check_pos = pos.sum_array(step)
      check_state = valid_pos?(check_pos) && menacing_piece == piece_in_pos(check_pos)
      return check_pos if check_state && return_pos
      return true if check_state
    end
    false
  end

  ########
  # General checker that goes over the indicated path
  def check_along?(pos, menacing_pieces, same_pieces, n_steps, step, return_pos = false)
    actual_pos = pos
    n_steps.times do |_|
      actual_pos = actual_pos.sum_array(step)
      watch_piece = piece_in_pos(actual_pos)
      break if same_pieces.include?(watch_piece)
      return actual_pos if return_pos && menacing_pieces.include?(watch_piece)
      return true if menacing_pieces.include?(watch_piece)
    end
    false
  end

  def piece_can_be_eaten?(pos, sign)
    pawns = check_of_pawns?(pos, sign)
    rq_lines = check_of_rooks_or_queen?(pos, sign)
    bq_diagnals = check_of_bishops_or_queen?(pos, sign)
    knights = check_of_knights?(pos, sign)
    pawns || rq_lines || bq_diagnals || knights
  end

  # check function for a given player
  def check?(player)
    king_pos, sign = player.chess_color == 'white' ? [@white_king_position, 1] : [@black_king_position, -1]
    piece_can_be_eaten?(king_pos, sign)
  end

  def find_menacing_piece_pos(player)
    king_pos, sign = player.chess_color == 'white' ? [@white_king_position, 1] : [@black_king_position, -1]
    possibilities = { 'pawns'=> check_of_pawns?(king_pos, sign, true),
                      'rooks_or_queen' => check_of_rooks_or_queen?(king_pos, sign, true),
                      'bishop_or_queen' => check_of_bishops_or_queen?(king_pos, sign, true),
                      'knights' => check_of_knights?(king_pos, sign, true) }
    # avoid false values
    possible_positions = possibilities.values.map { |pos| pos == false ? nil : pos }.compact
    possible_positions.length.positive? ? possible_positions[0] : nil
  end

  def menace_can_be_eaten?(player)
    pos_piece = find_menacing_piece_pos(player)
    sign = player.chess_color == 'white' ? -1 : 1
    piece_can_be_eaten?(pos_piece, sign)
  end

  def king_can_move?(same_pieces, next_pos)
    valid_pos?(next_pos) && !same_pieces.include?(piece_in_pos(next_pos))
  end

  def check_mate_for_any_move?(steps, actual_pos, same_pieces, player)
    steps.each do |step|
      next_pos = actual_pos.sum_array(step)
      # positions where the king can't move are skipped
      next unless king_can_move?(same_pieces, next_pos)
      # if the king can move we inspect if it ends up in check
      return false unless check_after_move?(actual_pos, next_pos, player)
    end
    # with no movements, we return false only if the piece can be eaten
    return false if menace_can_be_eaten?(player)

    check?(player)
  end

  # check mate function for a given player
  def check_mate?(player)
    steps = possible_king_steps
    actual_pos = actual_king_pos(player)
    same_pieces = allied_pieces(player)
    check_for_any_move = check_mate_for_any_move?(steps, actual_pos, same_pieces, player)
    check_for_any_move ? true : false
  end
end

# This module makes the correct reading of the strings that can be used in a chess game
module ReadingMovementFunctionalities
  include BasicChessUtils

  def movement_variables(movement, player)
    from_to_notation = /^[a-h][1-8][a-h][1-8]$/
    algebraic_notation = /((^(B|K|N|R|Q| ){1}[a-h][1-8]$)|(^(B|K|N|R|Q|e){1}x[a-h][1-8]$)|(O-O)|(O-O-O)){1}/

    if movement.match(from_to_notation)
      movement_variables_from_to_notation(movement)
    elsif movement.match(algebraic_notation)
      movement_variables_algebraic_notation(movement, player)
    end
  end

  def get_pos(movement, from = 0)
    initial_col = movement[0 + from].ord - 'a'.ord
    initial_row = movement[1 + from].to_i - 1
    [initial_row, initial_col]
  end

  def movement_variables_from_to_notation(movement)
    init_pos  = get_pos(movement)
    final_pos = get_pos(movement, 2)
    piece = @pieces_spaces[init_pos[0]][init_pos[1]]
    [init_pos, final_pos, piece]
  end

  def movement_variables_algebraic_notation(movement, player)
    # check for castlings
    # if the before cases did not return obtain the final position
    # now, based in the final position assign the initial position if it exist
    case movement
    when 'O-O' then player.chess_color == 'white' ? [[0, 4], [0, 6], WHITE_KING] : [[7, 4], [7, 6], BLACK_KING]
    when 'O-O-O' then player.chess_color == 'white' ? [[0, 4], [0, 2], WHITE_KING] : [[7, 4], [7, 2], BLACK_KING]
    else
      final_pos = get_pos(movement, movement.length - 2)
      piece = obtain_piece_from_movement(movement, player)
      init_pos = search_for_location_and_piece(movement, final_pos)
      [init_pos, final_pos, piece]
    end
  end

  def obtain_piece_from_movement(movement, player)
    movement = movement[0..-3]
    color = player.chess_color == 'white' ? 'w' : 'b'
    if movement.contains?('x')
      acronym_to_piece[color + movement[0]]
    else
      acronym_to_piece[color + movement]
    end
  end

  def search_for_possible_location(piece, final_pos)
    # check depending of the pirce the check_of_pawns etc ...
    nil
  end
end

# Has all functions that must be true for the next movement to be valid
module ChessCorrectMovementFunctionalities
  include ChessCheckFunctionalities
  include ReadingMovementFunctionalities

  def correct_color_piece?(piece, player)
    player.chess_color == 'white' ? @white_pieces.include?(piece) : @black_pieces.include?(piece)
  end

  def modify_king_position(init_pos, final_pos)
    case piece_in_pos(init_pos)
    when WHITE_KING
      @white_king_position = final_pos
      true
    when BLACK_KING
      @black_king_position = final_pos
      true
    else
      false
    end
  end

  def check_after_move?(init_pos, final_pos, player)
    # save pieces in initial and final position to restablish them
    saved_piece_init = piece_in_pos(init_pos)
    saved_piece_final = piece_in_pos(final_pos)
    # modify king position momentarily for the check to work correctly.
    was_king_modified = modify_king_position(init_pos, final_pos, player)

    # make the move
    draw_moved_piece(init_pos, final_pos)

    # check if the actual state is check
    check_after_move = check?(player)

    ## reestablish pieces to original position
    # reestablish king position if it was moved
    modify_king_position(final_pos, init_pos, player) if was_king_modified

    # reestablish pieces
    @pieces_spaces[init_pos[0]][init_pos[1]] = saved_piece_init
    @pieces_spaces[final_pos[0]][final_pos[1]] = saved_piece_final

    check_after_move
  end

  def check_white_pieces(piece, init_pos, final_pos)
    case piece
    when WHITE_PAWN then pawn_movement_valid?(init_pos, final_pos, 1)
    when WHITE_BISHOP then bishop_movement_valid?(init_pos, final_pos, 1)
    when WHITE_ROOK then rook_movement_valid?(init_pos, final_pos, 1)
    when WHITE_KNIGHT then knight_movement_valid?(init_pos, final_pos, 1)
    when WHITE_QUEEN then queen_movement_valid?(init_pos, final_pos, 1)
    when WHITE_KING then king_movement_valid?(init_pos, final_pos, 1)
    end
  end

  def check_black_pieces(piece, init_pos, final_pos)
    case piece
    when BLACK_PAWN then pawn_movement_valid?(init_pos, final_pos, -1)
    when BLACK_BISHOP then bishop_movement_valid?(init_pos, final_pos, -1)
    when BLACK_ROOK then rook_movement_valid?(init_pos, final_pos, -1)
    when BLACK_KNIGHT then knight_movement_valid?(init_pos, final_pos, -1)
    when BLACK_QUEEN then queen_movement_valid?(init_pos, final_pos, -1)
    when BLACK_KING then king_movement_valid?(init_pos, final_pos, -1)
    end
  end

  def some_piece_move?(piece, init_pos, final_pos)
    check_white_pieces(piece, init_pos, final_pos) || check_black_pieces(piece, init_pos, final_pos)
  end

  def movement_valid?(movement, player)
    init_pos, final_pos, piece = movement_variables(movement, player)
    return false if piece.nil?

    color = correct_color_piece?(piece, player)
    check_after_move = check_after_move?(init_pos, final_pos, player)
    move = some_piece_move?(piece, init_pos, final_pos)
    color && move && !check_after_move
  end
end
