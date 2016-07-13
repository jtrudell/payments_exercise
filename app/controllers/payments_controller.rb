class PaymentsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: 'not_found', status: :not_found
  end

  def index
    @payments = Loan.find(params[:loan_id]).payments
    if @payments
      render json: @payments.present? ? @payments : {}
    else
      render json: 'not_found', status: :not_found
    end
  end

  def show
    @payment = Payment.find_by(loan_id: params[:loan_id], id: params[:id])
    if @payment.present?
      render json: @payment
    else
      render json: 'not_found', status: :not_found
    end
  end

  def create
    loan = Loan.find(params[:loan_id])
    @payment = loan.payments.new(payment_params)
    if @payment.save && loan.save
      render json: @payment, status: :created
    else
      render json: @payment.errors, status: :bad_request
    end
  end

  private
  def payment_params
    params.permit(:amount, :loan_id)
  end
end
