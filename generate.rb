require_relative 'lib/transaction'

n = 10**6

file = File.open('transactions', 'a')

n.times do |i|
  file << Transaction.new(Time.now, rand(100), rand(100), rand(10**9)).to_s + "\n"
end

file.close

