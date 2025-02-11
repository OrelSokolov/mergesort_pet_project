require 'spec_helper'

describe TransactionSorter do

  subject { TransactionSorter.new("tmp/transactions_fixture", "tmp/output", 100) }
  let(:result_transactions) { File.readlines("tmp/output").map{ |line| Transaction.build_from_string(line) } }

  before do
    File.open("tmp/transactions_fixture", "w") do |f|
      1000.times do |i|
        f.puts Transaction.new(Time.now, 1, 1, i)
      end
    end

    subject.process!
  end

  it "expect transactions were sorted correctly" do
    expect(result_transactions.first.amount).to eq(999.0)
    expect(result_transactions.last.amount).to eq(0.0)
  end
end
