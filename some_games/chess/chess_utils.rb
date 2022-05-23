# frozen_string_literal: true

# functionalities to check for check in chess game
module ChessCheckFunctionalities
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
    poss_pawn1 = pos.sum_array([1 * sign, 1])
    poss_pawn2 = pos.sum_array([1 * sign, -1])
    [poss_pawn1, poss_pawn2]
  end

  def pawn_menacing_states(pos_pawn1, pos_pawn2, menacing_piece)
    menacing_pawn1 = piece_in_pos(pos_pawn1) == menacing_piece
    menacing_pawn2 = piece_in_pos(pos_pawn2) == menacing_piece
    [menacing_pawn1, menacing_pawn2]
  end

  def menacing_pawn(pos_p1, pos_p2, state1, state2)
    return pos_p1 if state1
    return pos_p2 if state2
  end

  ########
  # Rooks and queen in movements like a rook
  def check_of_rooks_or_queen?(pos, sign, return_pos = false)
    menacing_pieces = { 1 => [BLACK_ROOK, BLACK_QUEEN], -1 => [WHITE_ROOK, WHITE_QUEEN] }[sign]
    same_pieces = sign == 1 ? @white_pieces : @black_pieces
    rows = check_rq_rows?(pos, menacing_pieces, same_pieces, return_pos)
    cols = check_rq_cols?(pos, menacing_pieces, same_pieces, return_pos)
    rows || cols
  end

  def check_rq_rows?(pos, menacing_pieces, same_pieces, return_pos = false)
    upp_row = check_along?(pos, menacing_pieces, same_pieces, 7 - pos[0], [1, 0],return_pos)
    down_row = check_along?(pos, menacing_pieces, same_pieces, pos[0], [-1, 0], return_pos)
    upp_row || down_row
  end

  def check_rq_cols?(pos, menacing_pieces, same_pieces, return_pos = false)
    right_col = check_along?(pos, menacing_pieces, same_pieces, 7 - pos[1], [0, 1], return_pos)
    left_col = check_along?(pos, menacing_pieces, same_pieces, pos[1], [0, -1], return_pos)
    left_col || right_col
  end

  ########
  # Rooks and queen in movements like a bishop
  def check_of_bishops_or_queen?(pos, sign, return_pos = false)
    menacing_pieces = { 1 => [BLACK_BISHOP, BLACK_QUEEN], -1 => [WHITE_BISHOP, WHITE_QUEEN] }[sign]
    same_pieces = sign == 1 ? @white_pieces : @black_pieces
    dgright = check_bq_dgright?(pos, menacing_pieces, same_pieces, return_pos)
    dgleft = check_bq_dgleft?(pos, menacing_pieces, same_pieces, return_pos)
    dgright || dgleft
  end

  def check_bq_dgright?(pos, menacing_pieces, same_pieces, return_pos = false)
    up_diag_steps = [7 - pos[0], pos[1]].min # up, right min
    up_part = check_along?(pos, menacing_pieces, same_pieces, up_diag_steps, [1, 1], return_pos)
    down_diag_steps = [pos[0], pos[1]].min # down, left min
    down_part = check_along?(pos, menacing_pieces, same_pieces, down_diag_steps, [-1, -1], return_pos)
    up_part || down_part
  end

  def check_bq_dgleft?(pos, menacing_pieces, same_pieces, return_pos = false)
    up_diag_steps = [7 - pos[0], pos[1]].min # up, left min
    up_part = check_along?(pos, menacing_pieces, same_pieces, up_diag_steps, [1, -1], return_pos)
    down_diag_steps = [pos[0], 7 - pos[1]].min # down, right min
    down_part = check_along?(pos, menacing_pieces, same_pieces, down_diag_steps, [-1, 1], return_pos)
    up_part || down_part
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

  def modify_king_position(init_pos, final_pos, player)
    king_piece_to_watch = player.chess_color == 'white' ? WHITE_KING : BLACK_KING
    if king_piece_to_watch == piece_in_pos(init_pos) && king_piece_to_watch == WHITE_KING
      @white_king_position = final_pos
    elsif king_piece_to_watch == piece_in_pos(init_pos) && king_piece_to_watch == BLACK_KING
      @black_king_position = final_pos
    end
    king_piece_to_watch == piece_in_pos(init_pos)
  end

  def actual_king_pos(player)
    player.chess_color == 'white' ? @white_king_position : @black_king_position
  end

  def possible_king_steps
    [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]
  end

  def allied_pieces(player)
    player.chess_color == 'white' ? @white_pieces : @black_pieces
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
      next unless king_can_move?(same_pieces, next_pos)
      return false unless check_after_move?(actual_pos, next_pos, player)
    end
    return false if menace_can_be_eaten?(player)

    check?(player)
  end

  # check mate function for a given player
  def check_mate?(player)
    steps = possible_king_steps
    actual_pos = actual_king_pos(player)
    same_pieces = allied_pieces(player)
    return check_mate_for_any_move?(steps, actual_pos, same_pieces, player) if check?(player)

    false
  end
end

# Has all functions that must be true for the next movement to be valid
module ChessCorrectMovementFunctionalities
  include ChessCheckFunctionalities

  def correct_color_piece?(piece, player)
    player.chess_color == 'white' ? @white_pieces.include?(piece) : @black_pieces.include?(piece)
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
    init_pos, final_pos, piece = movement_variables(movement)
    color = correct_color_piece?(piece, player)
    check_after_move = check_after_move?(init_pos, final_pos, player)
    move = some_piece_move?(piece, init_pos, final_pos)
    color && move && !check_after_move
  end
end