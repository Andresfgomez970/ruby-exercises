require './caesar_cipher'

describe '#caesar_cipher' do
  it 'simple shift' do
    expect(caesar_cipher('abc', 1)).to eq('bcd')
  end
end