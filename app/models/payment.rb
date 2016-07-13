class Payment < ActiveRecord::Base
  belongs_to :loan

  validates_presence_of :loan, message: 'not_found'
  validates :amount, :presence => true, :numericality => { greater_than: 0 }
  validate :positive_loan_balance
  after_create :update_loan_balance

  private
  def positive_loan_balance
    if loan.balance - amount < 0
      errors.add(:amount, "payment would result in negative loan balance")
    end
  end

  def update_loan_balance
    loan.process_payment(self)
  end
end
