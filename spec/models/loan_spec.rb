require 'rails_helper'

RSpec.describe Loan, type: :model do

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(Loan.create!(funded_amount: 100)).to be_valid
    end

    it 'raises and error with an amount less than 0' do
      expect { Loan.create!(funded_amount: -100) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#before_create' do
    let(:loan) { Loan.create!(funded_amount: 200) }

    it 'sets the loan balance to the funded amount' do
      expect(loan.balance.to_f).to eq(200)
    end
  end

  describe '#process_payment' do
    let(:loan) { Loan.create!(funded_amount: 500) }
    let(:another_loan) { Loan.create!(funded_amount: 600) }

    it 'processes the payment if the payment is associated with the loan' do
      payment = Payment.create!(amount: 200, loan_id: loan.id)
      loan.process_payment(payment)
      expect(loan.balance.to_f).to eq(300.0)
    end

    it 'does not process the payment if the payment is not associated with the loan' do
      payment = Payment.create!(amount: 200, loan_id: another_loan.id)
      loan.process_payment(payment)
      expect(loan.balance.to_f).to eq(500.0)
    end
  end

  describe '#update_balance' do
    let(:loan) { Loan.create!(funded_amount: 500) }

    it 'reduces the loan balance by a valid payment amount' do
      loan.send(:update_balance, 100)
      expect(loan.balance.to_f).to eq(400.0)
    end

    it 'does not reduce the loan balance by an invalid payment amount' do
      loan.send(:update_balance, 60000)
      expect(loan.balance.to_f).to eq(500)
    end
  end

end