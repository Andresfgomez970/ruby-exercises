# frozen_string_literal: true

require './calculator'

describe Calculator do
  calculator = Calculator.new
  describe '#add' do
    it 'two numbers' do
      expect(calculator.add(2, 3)).to eql(5)
    end

    it 'n-th numbers' do
      expect(calculator.add(2, 2, 3)).to eql(7)
    end

    it 'number and array' do
      expect(calculator.add(2, [2, 3])).to eql(7)
    end

    it 'array and numbers' do
      expect(calculator.add([1, 2], 3, 1)).to eql(7)
    end

    it 'arrays' do
      expect(calculator.add([1, 2], [3, 1])).to eql(7)
    end

    it 'single array' do
      expect(calculator.add([5, 2])).to eql(7)
    end
  end
  describe '#multiply' do
    it 'two numbers' do
      expect(calculator.multiply(2, 5)).to eql(10)
    end

    it 'n-th numbers' do
      expect(calculator.multiply(2, 5, 10, 3)).to eql(300)
    end
  end
end
