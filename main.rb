require_relative 'lib/transaction'
require_relative 'lib/transaction_sorter'

def bench(amount, &block)
  t1 = Time.now
  yield
  t2 = Time.now

  time = t2-t1
  puts "Time elapsed: #{time}"
  puts "Speed: ~#{(amount.to_f/time).ceil} transactions per second"
end

transactions_amount = `grep -c . transactions`.to_i

# Пример использования
bench(transactions_amount) do
  chunk_size = 10**5
  sorter = TransactionSorter.new('transactions', 'sorted_transactions', chunk_size)
  sorter.process!
end
