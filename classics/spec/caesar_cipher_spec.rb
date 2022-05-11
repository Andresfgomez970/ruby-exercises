require './caesar_cipher'

describe '#caesar_cipher' do
  it 'simple shift' do
    expect(caesar_cipher('abcAB', 1)).to eq('bcdBC')
  end

  it 'module shift' do
    expect(caesar_cipher('ZAm', 4)).to eq('DEq')
  end

  it 'ignore special characters' do
    expect(caesar_cipher('¿Z,A!m#', 4)).to eq('¿D,E!q#')
  end
end