class Loan < ActiveRecord::Base
  has_many :payments

  validates :funded_amount, :presence => true, :numericality => { greater_than_or_equal_to: 0 }
  before_create :set_initial_balance

  def process_payment(payment)
    update_balance(payment.amount) if payments.include?(payment)
  end

  private
  def set_initial_balance
    self.balance ||= funded_amount
  end

  def update_balance(amount)
    if balance - amount > 0
      self.balance -= amount
      self.save
    else
      errors.add(:loan, "payment would result in negative loan balance")
    end
  end
end
