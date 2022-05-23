# frozen_string_literal: true

require_relative '../table'

describe Table do
  subject(:table) { described_class.new }

  describe '#initialize' do
    it 'sends right calls' do
      expect(table).to receive(:default_initialize)
      table.send(:initialize)
    end

    it 'init defaults correctly' do
      expect(table.instance_variable_get(:@n_rows)).to eq(0)
      expect(table.instance_variable_get(:@n_columns)).to eq(0)
      table.send(:initialize)
    end

    context 'when defaults are different' do
      subject(:table_diff) { described_class.new({ n_rows: 8, n_columns: 8 }) }
      it 'init correctly' do
        expect(table_diff.instance_variable_get(:@n_rows)).to eq(8)
        expect(table_diff.instance_variable_get(:@n_columns)).to eq(8)
        table_diff.send(:initialize)
      end
    end
  end

  describe '#default_initialize' do
    it 'initialize correctly' do
      pieces_spaces = table.instance_variable_get(:@pieces_spaces)
      pieces_spaces_res = Array.new(0) { Array.new(0, ' ') }
      expect(pieces_spaces).to eq(pieces_spaces_res)
      table.default_initialize
    end
  end

  describe '#one_level_row' do
    it 'initialze correctly in blank' do
      output = '   |'
      expect(table.one_level_row).to eq(output)
    end

    it 'initialize correctly with values' do
      output = '   |   1   |   2   |   3   |   4   |   5   |   6   |   7   |'
      expect(table.one_level_row(('1'..'7').to_a)).to eq(output)
    end
  end
end
