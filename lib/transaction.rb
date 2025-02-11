class Transaction
  attr_reader :amount, :timestamp, :transaction_id, :user_id

  def initialize(timestamp, transaction_id, user_id, amount)
    @timestamp = timestamp
    @transaction_id = transaction_id
    @user_id = user_id
    @amount = amount
  end

  def to_s
    "#{@timestamp},#{@transaction_id},#{@user_id},#{@amount}"
  end

  # <timestamp>,<transaction_id>,<user_id>,<amount>
  def self.build_from_string(line)
    timestamp, transaction_id, user_id, amount = line.strip.split(',')
    Transaction.new(timestamp, transaction_id, user_id, amount.to_f)
  end
end