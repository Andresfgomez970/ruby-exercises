require_relative '../connect_four'


describe ConnectFourTable do
  subject(:table) { described_class.new }

  describe '#initialize' do 
    it 'sends right calls' do
      expect(table).to receive(:default_initialize)
      table.send(:initialize)
    end
  end

  describe '#default_initialize' do
    it 'initialize correctly' do
      chip_spaces = table.instance_variable_get(:@chip_spaces)
      chip_spaces_res = Array.new(6) { Array.new(7, ' ') }
      expect(chip_spaces).to eq(chip_spaces_res)
      table.default_initialize
    end
  end

  describe '#one_level_row' do
    it 'initialze correctly in blank' do
      output = "|      \t|      \t|      \t|      \t|      \t|      \t|      \t|"
      expect(table.one_level_row).to eq(output)
    end

    it 'initialize correctly with values' do
      output = "|   1  \t|   2  \t|   3  \t|   4  \t|   5  \t|   6  \t|   7  \t|"
      expect(table.one_level_row(('1'..'7').to_a)).to eq(output)
    end
  end

  describe '#reverse_index' do
    it 'reverse index 1 in [1, 2, 3, 4, 5]' do
      arr = (1..5).to_a
      index = 1
      expect(table.reverse_index(arr, index)).to eq(3)
    end
  end

  describe '#draw_color_table' do
    it 'correct calls and loop count' do
      expect(table).to receive(:draw_choose_column).once
      expect(table).to receive(:draw_row).exactly(6).times
      expect(table).to receive(:draw_line).once
      table.draw_color_table
    end
  end

  describe '#select_column_to_throw + #valid_column' do
    it 'correct selection at once' do
      allow(table).to receive(:choose_option).and_return('1')
      expect(table).to receive(:choose_option).once
      table.select_column_to_throw('name of user playing')
    end

    it 'select correctly after several tries' do
      allow(table).to receive(:choose_option).and_return('asdf', 's', '20', '1')
      expect(table).to receive(:choose_option).exactly(4).times
      expect(table).to receive(:select_column_to_throw).exactly(4).times.and_call_original
      table.select_column_to_throw('name of user playing')
    end
  end

  describe '#valid_column?' do
    it 'column is full' do
      board = table.instance_variable_get(:@chip_spaces)
      column = '0'
      board[0][board[0].length - 1] = 'f'
      expect(table.valid_column?(column)).to eq(true)
    end
  end

  describe '#throw_to_column' do
    it 'adds to a void column' do
      board = table.instance_variable_get(:@chip_spaces)
      table.throw_to_column('0', 'x')
      expect(board[0][0]).to eq('x')
    end

    it 'adds to almost full column' do
      board = table.instance_variable_get(:@chip_spaces)
      5.times { |i| board[i][0] = 'x' }
      table.throw_to_column('0', 'o')
      expect(board[5][0]).to eq('o')
    end
  end

  describe '#full?' do
    it 'when board is full' do
      table.instance_variable_set(:@chip_spaces, Array.new(6) { Array.new(7, 'f') })
      expect(table.full?).to be(true)
    end

    it 'when board is almost full' do
      almost_full_board = Array.new(6) { Array.new(7, 'f') }
      almost_full_board[0][0] = ' '
      table.instance_variable_set(:@chip_spaces, almost_full_board)
      expect(table.full?).to be(false)
    end

    it 'when board is empty' do
      expect(table.full?).to be(false)
    end
  end

  describe '#four_connected?' do
    it 'when four connected along a diagonal possibility 1' do
      diag_board = Array.new(6) { Array.new(7, ' ') }
      4.times { |i| diag_board[0 + i][0 + i] = 'x' }
      table.instance_variable_set(:@chip_spaces, diag_board)
      expect(table.four_connected?).to eq(true)
    end

    it 'when four connected along a diagonal possibility 2' do
      diag_board = Array.new(6) { Array.new(7, ' ') }
      4.times { |i| diag_board[5 - i][2 + i] = 'x' }
      table.instance_variable_set(:@chip_spaces, diag_board)
      expect(table.four_connected?).to eq(true)
    end

    it 'when four connected along a diagonal possibility 3' do
      diag_board = Array.new(6) { Array.new(7, ' ') }
      4.times { |i| diag_board[1 + i][5 - i] = 'x' }
      table.instance_variable_set(:@chip_spaces, diag_board)
      expect(table.four_connected?).to eq(true)
    end

    it 'when four connected along a diagonal possibility 4' do
      diag_board = Array.new(6) { Array.new(7, ' ') }
      4.times { |i| diag_board[5 - i][4 - i] = 'x' }
      table.instance_variable_set(:@chip_spaces, diag_board)
      expect(table.four_connected?).to eq(true)
    end

    it 'when four connected along a line possibility 1' do
      line_board = Array.new(6) { Array.new(7, ' ') }
      4.times { |i| line_board[0 + i][6] = 'x' }
      table.instance_variable_set(:@chip_spaces, line_board)
      expect(table.four_connected?).to eq(true)
    end

    it 'when four connected along a line possibility 2' do
      line_board = Array.new(6) { Array.new(7, ' ') }
      4.times { |i| line_board[5 - i][6] = 'x' }
      table.instance_variable_set(:@chip_spaces, line_board)
      expect(table.four_connected?).to eq(true)
    end

    it 'when four connected along a line possibility 3' do
      line_board = Array.new(6) { Array.new(7, ' ') }
      4.times { |i| line_board[0][6 - i] = 'x' }
      table.instance_variable_set(:@chip_spaces, line_board)
      expect(table.four_connected?).to eq(true)
    end

    it 'when four connected along a line possibility 4' do
      line_board = Array.new(6) { Array.new(7, ' ') }
      4.times { |i| line_board[0][2 + i] = 'x' }
      table.instance_variable_set(:@chip_spaces, line_board)
      expect(table.four_connected?).to eq(true)
    end

    it 'when is not filled' do
      expect(table.four_connected?).to eq(false)
    end
  end
end

describe ConnectFourGame do
  subject(:game) {described_class.new}

  describe '#valid_yn_answer?' do
    it 'valid answer' do
      expect(game.valid_yn_answer?('y')).to eq(true)
      expect(game.valid_yn_answer?('n')).to eq(true)
    end

    it 'invalid answer' do
      expect(game.valid_yn_answer?('YESS')).to eq(false)
      expect(game.valid_yn_answer?('haha')).to eq(false)
    end
  end

  describe '#exit_game?' do
    it 'good answer in first try' do
      allow(game).to receive(:gets_message).and_return('y')
      expect(game).to receive(:gets_message).with('Do you want to finish the game? (y/n)').once
      expect(game.exit_game?).to eq(true)
    end

    it 'good answer in fifth try' do
      values = %w[no yes NO haha y]
      allow(game).to receive(:gets_message).and_return(*values)
      expect(game).to receive(:gets_message).with('Do you want to finish the game? (y/n)').once
      expect(game).to receive(:gets_message).with('please enter a valid option: (y/n)').exactly(4).times
      expect(game.exit_game?).to eq(true)
    end
  end

  describe '#play_game' do
    it 'checks correct calls' do
      expect(game).to receive(:prepare_game)
      expect(game).to receive(:play_recursive)
      game.play_game
    end
  end

  describe '#choose_option' do
    it 'obtain valid option in array of options at once' do
      allow(game).to receive(:gets_message).and_return('3')
      expect(game).to receive(:gets_message).once
      expect(game.choose_option('enter option', %w[1 2 3 4 5 6])).to eq('3')
    end

    it 'keeps asking until valid option in array of options' do
      allow(game).to receive(:gets_message).and_return('an', '45', '9', '3')
      expect(game).to receive(:gets_message).exactly(4).times
      expect(game.choose_option('enter option', %w[1 2 3 4 5 6])).to eq('3')
    end
  end

  describe '#create_players' do
    it 'when player vs computer' do
      game.instance_variable_set(:@play_mode, '1')
      allow(game).to receive(:gets_message).and_return('andres')
      game.create_players
      expect(game.instance_variable_get(:@player1).name).to eq('andres')
      expect(game.instance_variable_get(:@player2).name).to eq('computer')
    end

    it 'when player vs player' do
      game.instance_variable_set(:@play_mode, '2')
      allow(game).to receive(:gets_message).and_return('andres', 'juan')
      game.create_players
      expect(game.instance_variable_get(:@player1).name).to eq('andres')
      expect(game.instance_variable_get(:@player2).name).to eq('juan')
    end
  end

  describe '#play_recursive' do
    before do
      allow(game).to receive(:play_round).and_return(nil)
    end

    it 'ends the game' do
      allow(game).to receive(:exit_game?).and_return(true)
      expect(game).to receive(:end_game).once
      game.play_recursive
    end

    it 'does not end the game playing again' do
      allow(game).to receive(:exit_game?).and_return(false, true)
      expect(game).to receive(:reset_for_new_game).once
      expect(game).to receive(:end_game).once
      expect(game).to receive(:play_recursive).twice.and_call_original
      game.play_recursive
    end

    it 'does not end the game playing again several times' do
      playing_decisions = [false, false, false, false, true]
      allow(game).to receive(:exit_game?).and_return(*playing_decisions)
      expect(game).to receive(:reset_for_new_game).exactly(4).times
      expect(game).to receive(:end_game).once
      expect(game).to receive(:play_recursive).exactly(5).times.and_call_original
      game.play_recursive
    end
  end

  describe '#game_ends?' do
    it 'receive both conditions to end game' do
      allow(game.instance_variable_get(:@table)).to receive(:full?)
      allow(game).to receive(:someone_won?)
      expect(game.instance_variable_get(:@table)).to receive(:full?).once
      expect(game).to receive(:someone_won?).once
      game.game_ends?
    end
  end

  describe '#someone_one?' do
    it 'calls table.four_connected?' do
      allow(game.instance_variable_get(:@table)).to receive(:four_connected?)
      expect(game.instance_variable_get(:@table)).to receive(:four_connected?).once
      game.someone_won?
    end
  end

  describe '#change_players' do
    it 'change them player 1 by 2 and vice versa' do
      player1 = game.instance_variable_get(:@player1)
      player2 = game.instance_variable_get(:@player2)
      expect(game.change_players(player1)).to eq(player2)
      expect(game.change_players(player2)).to eq(player1)
    end
  end

  describe '#play_round' do
    it 'correct calls' do
      table = game.instance_variable_get(:@table)
      allow(table).to receive(:draw_table)
      allow(game).to receive(:game_ends?).and_return(false, true)
      allow(game).to receive(:play_turn)
      allow(game).to receive(:change_players)
      allow(game).to receive(:update_scores)
      expect(game).to receive(:play_turn).once
      expect(game).to receive(:change_players).once
      expect(game).to receive(:update_scores).once
      game.play_round
    end

    it 'correct calls going over several times' do
      table = game.instance_variable_get(:@table)
      allow(table).to receive(:draw_table)
      times = Array.new(6, false) + [true]
      allow(game).to receive(:game_ends?).and_return(*times)
      allow(game).to receive(:play_turn)
      allow(game).to receive(:change_players)
      allow(game).to receive(:update_scores)
      expect(game).to receive(:play_turn).exactly(6).times
      expect(game).to receive(:change_players).exactly(6).times
      expect(game).to receive(:update_scores).once
      game.play_round
    end

    describe '#play_turn' do
      context 'when an user takes its turn' do
        let(:user1) { ConnectFourUser.new }
        it 'tmakes the correct calls' do
          table = game.instance_variable_get(:@table)
          allow(table).to receive(:select_column_to_throw)
          allow(table).to receive(:throw_to_column)
          allow(table).to receive(:draw_table)
          expect(table).to receive(:select_column_to_throw).once
          expect(table).to receive(:throw_to_column).once
          expect(table).to receive(:draw_table).once
          game.play_turn(user1)
        end
      end
    end
  end

  describe '#winner_user' do
    context 'when game is finish with someone winning' do
      let(:user1) { ConnectFourUser.new({ name: 'user1', mark: 'x', score: 0 }) }
      let(:user2) { ConnectFourUser.new({ name: 'user2', mark: 'o', score: 2 }) }
      subject(:game_with_winner) { described_class.new(user1, user2) }
      it 'user with higher score wins' do
        expect(game_with_winner.winner_user).to eq('user2')
      end
    end

    context 'when game is finish in tie' do
      let(:user1) { ConnectFourUser.new({ name: 'user1', mark: 'x', score: 0 }) }
      let(:user2) { ConnectFourUser.new({ name: 'user2', mark: 'o', score: 0 }) }
      subject(:game_with_winner) { described_class.new(user1, user2) }
      it 'winner user is nil' do
        expect(game_with_winner.winner_user).to eq(nil)
      end
    end
  end

  describe '#win_message' do
    it 'when there is a tie' do
      allow(game).to receive(:winner_user).and_return(nil)
      expect(game.win_message).to eq("Wow! That's a tie")
    end

    it 'when someone wins' do
      allow(game).to receive(:winner_user).and_return('andrew_the_winner')
      expect(game.win_message).to eq('The winner is andrew_the_winner; congrats!!!')
    end
  end

  describe '#final_message' do
    it 'calls both player names' do
      player1 = game.instance_variable_get(:@player1)
      player2 = game.instance_variable_get(:@player2)
      allow(game).to receive(:puts)
      expect(player1).to receive(:name)
      expect(player2).to receive(:name)
      game.final_message
    end
  end

  describe '#update_scores' do
    it 'increase other when lost user is passed' do 
      game.instance_variable_set(:@someone_won_state, true)
      lost_user = game.instance_variable_get(:@player1)
      win_user = game.instance_variable_get(:@player2)
      expect { game.update_scores(lost_user) }.to change { win_user.score }.by(1)
    end

    it 'left score untouched when tie' do 
      lost_user = game.instance_variable_get(:@player1)
      win_user = game.instance_variable_get(:@player2)
      expect(win_user.score).to eq(lost_user.score)
    end
  end
end
