# frozen_string_literal: true

# Basic utils module
module BasicUtils
  def gets_message(message)
    puts message
    gets.chomp
  end

  def choose_option(message, options)
    option = gets_message(message) until options.include?(option)
    option
  end

  def valid_yn_answer?(answer)
    %w[y n].include?(answer)
  end

  def exit_game?
    answer = gets_message('Do you want to finish the game? (y/n)')
    answer = gets_message('please enter a valid option: (y/n)') until valid_yn_answer?(answer)
    answer == 'y'
  end
end

# add functionatalities to the array class
class Array
  def sum_array(array)
    each_with_index.map { |elem, i| elem + array[i] } if length == array.length
  end
end

# functionalities to check for check in chess game
module ChessCheckFunctionalities
  ########
  # Pawns
  def check_of_pawns?(king_pos, sign)
    return false if king_pos[0] == 7 && sign == 1
    return false if king_pos[0].zero? && sign == -1

    menacing_piece = { 1 => BLACK_PAWN, -1 => WHITE_PAWN }[sign]
    pos1_check = king_pos.sum_array([1 * sign, 1])
    pos2_check = king_pos.sum_array([1 * sign, -1])
    piece_in_pos(pos1_check) == menacing_piece || piece_in_pos(pos2_check) == menacing_piece
  end

  ########
  # Rooks and queen in movements like a rook
  def check_of_rooks_or_queen?(king_pos, sign)
    menacing_pieces = { 1 => [BLACK_ROOK, BLACK_QUEEN], -1 => [WHITE_ROOK, WHITE_QUEEN] }[sign]
    same_pieces = sign == 1 ? @white_pieces : @black_pieces
    rows = check_rq_rows?(king_pos, menacing_pieces, same_pieces)
    cols = check_rq_cols?(king_pos, menacing_pieces, same_pieces)
    rows || cols
  end

  def check_rq_rows?(king_pos, menacing_pieces, same_pieces)
    upp_row = check_along?(king_pos, menacing_pieces, same_pieces, 7 - king_pos[0], [1, 0])
    down_row = check_along?(king_pos, menacing_pieces, same_pieces, king_pos[0], [-1, 0])
    upp_row || down_row
  end

  def check_rq_cols?(king_pos, menacing_pieces, same_pieces)
    right_col = check_along?(king_pos, menacing_pieces, same_pieces, 7 - king_pos[1], [0, 1])
    left_col = check_along?(king_pos, menacing_pieces, same_pieces, king_pos[1], [0, -1])
    left_col || right_col
  end

  ########
  # Rooks and queen in movements like a bishop
  def check_of_bishops_or_queen?(king_pos, sign)
    menacing_pieces = { 1 => [BLACK_BISHOP, BLACK_QUEEN], -1 => [WHITE_BISHOP, WHITE_QUEEN] }[sign]
    same_pieces = sign == 1 ? @white_pieces : @black_pieces
    dgright = check_bq_dgright?(king_pos, menacing_pieces, same_pieces)
    dgleft = check_bq_dgleft?(king_pos, menacing_pieces, same_pieces)
    dgright || dgleft
  end

  def check_bq_dgright?(king_pos, menacing_pieces, same_pieces)
    up_diag_steps = [7 - king_pos[0], king_pos[1]].min # up, right min
    up_part = check_along?(king_pos, menacing_pieces, same_pieces, up_diag_steps, [1, 1])
    down_diag_steps = [king_pos[0], 7 - king_pos[1]].min # down, left min
    down_part = check_along?(king_pos, menacing_pieces, same_pieces, down_diag_steps, [-1, -1])
    up_part || down_part
  end

  def check_bq_dgleft?(king_pos, menacing_pieces, same_pieces)
    up_diag_steps = [7 - king_pos[0], 7 - king_pos[1]].min # up, left min
    up_part = check_along?(king_pos, menacing_pieces, same_pieces, up_diag_steps, [1, -1])
    down_diag_steps = [king_pos[0], king_pos[1]].min # down, right min
    down_part = check_along?(king_pos, menacing_pieces, same_pieces, down_diag_steps, [-1, 1])
    up_part || down_part
  end

  ########
  # Knights
  def check_of_knights?(king_pos, sign)
    steps = [[2, 1], [2, -1], [1, 2], [1, -2], [-2, 1], [-2, -1], [-1, 2], [-1, -2]]

    menacing_piece = { 1 => BLACK_KNIGHT, -1 => WHITE_KNIGHT }[sign]
    steps.each do |step|
      check_pos = king_pos.sum_array(step)
      return true if valid_pos?(check_pos) && menacing_piece == piece_in_pos(check_pos)
    end
    false
  end

  ########
  # General checker that goes over the indicated path
  def check_along?(king_pos, menacing_pieces, same_pieces, n_steps, step)
    actual_pos = king_pos
    n_steps.times do |_|
      actual_pos = actual_pos.sum_array(step)
      watch_piece = piece_in_pos(actual_pos)
      break if same_pieces.include?(watch_piece)
      return true if menacing_pieces.include?(watch_piece)
    end
    false
  end
end
