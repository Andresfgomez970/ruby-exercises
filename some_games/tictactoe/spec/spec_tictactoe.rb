require_relative '../tictactoe'
require_relative '../user'

describe Table do
  subject(:table) { described_class.new }

  describe '#update_symbols' do
    it 'update at index 2' do
      table.update_symbols(2, 'o')
      expect(table.instance_variable_get(:@symbols)[2]).to eq('o')
    end

    it 'update at last index' do
      last_index = table.instance_variable_get(:@symbols).length - 1
      table.update_symbols(last_index, 'o')
      expect(table.instance_variable_get(:@symbols)[last_index]).to eq('o')
    end
  end

  describe '#coincide_symbols' do
    it 'no items coincide' do
      expect(subject.coincide_symbols([1, 2, 3])).to be false
    end

    it 'items coincide' do
      table.update_symbols(1, 'o')
      table.update_symbols(4, 'o')
      table.update_symbols(8, 'o')
      expect(subject.coincide_symbols([1, 4, 8])).to be true
    end
  end

  describe '#init_symbols' do
    it '@symbols result' do
      expected = (1..9).to_a
      expect(subject.init_symbols).to eq(expected)
    end
  end
end

describe TicTacToe do
  subject(:game) { described_class.new }

  describe '#prepare_game' do
    it 'ask for names two times and welcome_mesage' do
      expect(game).to receive(:enter_name).with('x').once
      expect(game).to receive(:enter_name).with('o').once
      expect(game).to receive(:welcome_mesage).once
      game.prepare_game
    end
  end

  describe '#enter_name' do
    before do
      allow(game).to receive(:gets_message).and_return('name1')
    end

    it 'calls users push' do
      expect(game.instance_variable_get(:@users)).to receive(:push)
      game.enter_name('x')
    end

    it 'initialize user' do
      expect(TicTacToeUser).to receive(:new).with('name1', 'x').once
      game.enter_name('x')
    end

    it 'adds class for participant correctly' do
      expect(game).to receive(:gets_message).once
      expected_output = TicTacToeUser.new('name1', 'x')
      expect { game.enter_name('x') }.to change { game.instance_variable_get(:@users)[0] }.to eq(expected_output)
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

  describe '#play_round' do
    before do
      expect(game).to receive(:display_score).once
      expect(game).to receive(:update_scores).once
    end

    it 'no one wons' do
      allow(game).to receive(:someone_won).and_return(false)
      expect(game).to receive(:play_movement).exactly(9).times
      game.play_round
    end

    # not possible but testing correct behaviour
    it 'someone wins inmediately' do
      allow(game).to receive(:someone_won).and_return(true)
      expect(game).to receive(:play_movement).once
      game.play_round
    end

    it 'someone wins in the five turn' do
      someone_won_results = [false, false, false, false, true]
      allow(game).to receive(:someone_won).and_return(*someone_won_results)
      expect(game).to receive(:play_movement).exactly(5).times
      game.play_round
    end
  end

  describe '#play_movement' do
    it 'plays an even turn' do
      expect(game).to receive(:draw_movement).with('x').once
      game.play_movement(2)
    end

    it 'plays an odd turn' do
      expect(game).to receive(:draw_movement).with('o').once
      game.play_movement(1)
    end
  end

  describe '#draw_movement' do
    it 'makes the correct calls' do
      table = game.instance_variable_get(:@table)
      expect(table).to receive(:draw_table).twice
      expect(table).to receive(:update_symbols).once
      expect(game).to receive(:chosen_position).once
      game.draw_movement('x')
    end
  end

  describe '#chosen_position' do
    it 'chosen any available position initially' do
      ('1'..'9').each do |counter|
        allow(game).to receive(:gets_message).and_return(counter)
        expect(game.chosen_position).to eq(counter.to_i - 1)
      end
    end

    it 'table has filled positions or incorrect number' do
      allow(game).to receive(:gets_message).and_return('invalid')
      list_of_validity = Array.new(5, false) + [true]
      allow(game).to receive(:valid_position?).and_return(*list_of_validity)
      expect(game).to receive(:gets_message).with('Please enter a number').once
      expect(game).to receive(:gets_message).with('Please select a valid number').exactly(5)
      game.chosen_position
    end
  end

  describe '#valid_position' do
    it 'false when filled position in table' do
      table = game.instance_variable_get(:@table)
      table.update_symbols(2, 'o')
      expect(game.valid_position?('3')).to be false
    end

    it 'false with invalid characters' do
      expect(game.valid_position?('40')).to be false
    end

    it 'true with normal characters not in table' do
      expect(game.valid_position?('4')).to be true
    end
  end

  describe 'someone_won' do
    it 'returns correct symble in first check' do
      allow(game).to receive(:check_tictactoe).and_return(true)
      expect(game.someone_won).to eq(1)
    end

    it 'returns correct symbol in third check' do
      allow(game).to receive(:check_tictactoe).and_return(false, false, true)
      expect(game.someone_won).to eq(7)
    end

    it 'returns correct symbol in last check' do
      cheks = Array.new(7, false) + [true]
      allow(game).to receive(:check_tictactoe).and_return(*cheks)
      expect(game.someone_won).to eq(3)
    end
  end

  describe 'check_tictactoe' do
    it 'sends method for @table to check' do
      expect(game.instance_variable_get(:@table)).to receive(:coincide_symbols).with([0, 1, 2])
      game.check_tictactoe([0, 1, 2])
    end
  end

  describe '#update_scores' do
    context 'when user of a given mark wins' do
      let(:user1) { TicTacToeUser.new('user1', 'x') }
      let(:user2) { TicTacToeUser.new('user2', 'o') }
      subject(:game_up_score) { described_class.new([user1, user2]) }
      it 'for x player' do
        allow(game_up_score).to receive(:someone_won).and_return('x')
        x_user = game_up_score.instance_variable_get(:@users)[0]
        expect { game_up_score.update_scores }.to change { x_user.score }.by(1)
      end

      it 'for o player' do
        allow(game_up_score).to receive(:someone_won).and_return('o')
        o_user = game_up_score.instance_variable_get(:@users)[1]
        expect { game_up_score.update_scores }.to change { o_user.score }.by(1)
      end
    end
  end

  describe '#reset_for_new_game' do
    it 'send good calls' do
      expect(game.instance_variable_get(:@table)).to receive(:init_symbols)
      expect(game).to receive(:interchange_marks)
      allow(game).to receive(:puts)
      expect(game).to receive(:begin_user)
      game.reset_for_new_game
    end
  end

  describe '#interchange_marks' do
    context 'when new game begins'do
      let(:user1) { TicTacToeUser.new('user1', 'x') }
      let(:user2) { TicTacToeUser.new('user2', 'o') }
      subject(:game_new) { described_class.new([user1, user2]) }
      it 'x change by o' do
        x_user = game_new.instance_variable_get(:@users)[0]
        o_user = game_new.instance_variable_get(:@users)[0]
        expect { game_new.interchange_marks }.to change { x_user.mark }.to eq('o')
        expect { game_new.interchange_marks }.to change { o_user.mark }.to eq('x')
      end
    end
  end

  describe '#begin_user' do
    context 'when new game begins' do
      let(:user1) { TicTacToeUser.new('user1', 'x') }
      let(:user2) { TicTacToeUser.new('user2', 'o') }
      subject(:game_begin) { described_class.new([user1, user2]) }
      it 'user with mark x begins' do
        expect(game_begin.begin_user).to eq('user1')
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

  describe '#winner_user' do
    context 'when game is finish with someone winning' do
      let(:user1) { TicTacToeUser.new('user1', 'x', 0) }
      let(:user2) { TicTacToeUser.new('user2', 'o', 2) }
      subject(:game_with_winner) { described_class.new([user1, user2]) }
      it 'user with higher score wins' do
        expect(game_with_winner.winner_user).to eq('user2')
      end
    end

    context 'when game is finish in tie' do
      let(:user1) { TicTacToeUser.new('user1', 'x', 2) }
      let(:user2) { TicTacToeUser.new('user2', 'o', 2) }
      subject(:game_with_winner) { described_class.new([user1, user2]) }
      it 'winner user is nil' do
        expect(game_with_winner.winner_user).to eq(nil)
      end
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
end
