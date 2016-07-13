require 'rails_helper'

RSpec.describe Payment, type: :model do

  describe 'validations' do
    let(:loan) { Loan.create!(funded_amount: 2100.0) }

    it 'is valid with valid attributes' do
      expect(Payment.create!(amount: 500, loan_id: loan.id)).to be_valid
    end

    it 'is not valid with an amount less than 0' do
      expect { Payment.create!(amount: -500, loan_id: loan.id) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'is not valid with an amount that exceeds the loan balance' do
      expect { Payment.create!(amount: 50000, loan_id: loan.id) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#after_create' do
    let(:loan) { Loan.create!(funded_amount: 333.0) }

    it 'results in an updated loan balance if payment amount is valid' do
      loan.payments.create!(amount: 111.0)
      expect(loan.balance.to_f).to eq(222.0)
    end

    it 'does not result in an updated loan balance if payment amount is invalid' do
      expect { loan.payments.create!(amount: 10000000) }.to raise_error(ActiveRecord::RecordInvalid)
      expect(loan.balance.to_f).to eq(333.0)
    end
  end

end
