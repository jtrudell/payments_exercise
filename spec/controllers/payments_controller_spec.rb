require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do

  describe '#index' do
    let(:loan) { Loan.create!(funded_amount: 2100.0) }

    context 'if the loan is found' do
      it 'responds with a 200' do
        get :index, loan_id: loan.id
        expect(response).to have_http_status(:ok)
      end

      it 'responds with the loan\'s payment data' do
        loan.payments.create!(amount: 50.0)
        loan.payments.create!(amount: 60.0)
        get :index, loan_id: loan.id

        data = JSON.parse(response.body)
        expect(data.length).to eq(2)
        expect(data[0]['amount']).to eq('50.0')
        expect(data[1]['amount']).to eq('60.0')
      end
    end

    context 'if the loan is not found' do
      it 'responds with a 404' do
        get :index, loan_id: 10000
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#show' do
    let(:loan) { Loan.create!(funded_amount: 100.0) }
    let(:payment) { loan.payments.create!(amount: 50.0) }
    let(:other_loan) { Loan.create!(funded_amount: 400.0) }

    context 'if the payment is found' do
      it 'responds with a 200' do
        get :show, loan_id: loan.id, id: payment.id
        expect(response).to have_http_status(:ok)
      end

      it 'responds with the payment data' do
        get :show, loan_id: loan.id, id: payment.id
        data = JSON.parse(response.body)
        expect(data['id']).to eq(payment.id)
        expect(data['loan_id']).to eq(loan.id)
        expect(data['amount'].to_f).to eq(payment.amount.to_f)
      end
    end

    context 'if the payment is not found' do
      it 'responds with a 404' do
        get :show, loan_id: loan.id, id: 10000
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'if the loan is not found' do
      it 'responds with a 404' do
        get :show, loan_id: 10000, id: payment.id
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'if the payment is not associated with the loan' do
      it 'responds with a 404' do
        get :show, loan_id: other_loan.id, id: payment.id
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#create' do
    let(:loan) { Loan.create!(funded_amount: 100.0) }

    context 'if the payment is successfully created' do
      it 'responds with a 201' do
        post :create, loan_id: loan.id, amount: 50.0
        expect(response).to have_http_status(:created)
      end

      it 'responds with the payment data' do
        post :create, loan_id: loan.id, amount: 70.0
        data = JSON.parse(response.body)
        current_payment = loan.payments.last
        expect(data['id']).to eq(current_payment.id)
        expect(data['loan_id']).to eq(loan.id)
        expect(data['amount'].to_f).to eq(current_payment.amount.to_f)
      end
    end

    context 'if the loan is not found' do
      it 'responds with a 404' do
        post :create, loan_id: 10000, amount: 50.0
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'if the payment amount is invalid' do
      it 'responds with a 400' do
        post :create, loan_id: loan.id, amount: -100.0
        expect(response).to have_http_status(:bad_request)
      end

      it 'responds with a descriptive error message' do
        post :create, loan_id: loan.id, amount: -100.0
        message = JSON.parse(response.body)['amount'][0]
        expect(message).to eq('must be greater than 0')
      end
    end

    context 'if the payment amount is greater than the loan balance' do
      it 'responds with a 400' do
        post :create, loan_id: loan.id, amount: 10000.0
        expect(response).to have_http_status(:bad_request)
      end

      it 'responds with a descriptive error message' do
        post :create, loan_id: loan.id, amount: 10000.0
        message = JSON.parse(response.body)['amount'][0]
        expect(message).to eq('payment would result in negative loan balance')
      end
    end
  end
end
