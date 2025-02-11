require 'spec_helper'

describe Transaction do

  subject { Transaction.new(Time.now, 100, 12, 1.0) }

  context "fields" do
    it { expect(subject.amount).to eq(1.0)}
  end
end