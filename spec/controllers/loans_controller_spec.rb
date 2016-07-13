require 'rails_helper'

RSpec.describe LoansController, type: :controller do
  describe '#index' do

    it 'responds with a 200' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'responds with data for all loans' do
      Loan.create!(funded_amount: 100.0)
      Loan.create!(funded_amount: 200.0)

      get :index
        data = JSON.parse(response.body)
        expect(data.length).to eq(2)
        expect(data[0]['funded_amount']).to eq('100.0')
        expect(data[1]['funded_amount']).to eq('200.0')
      end
  end

  describe '#show' do
    let(:loan) { Loan.create!(funded_amount: 300.0) }

    context 'if the loan is found' do
      it 'responds with a 200' do
        get :show, id: loan.id
        expect(response).to have_http_status(:ok)
      end

      it 'responds with the loan\'s data, including the balance' do
        get :show, id: loan.id
        data = JSON.parse(response.body)
        expect(data['funded_amount']).to eq('300.0')
        expect(data['balance']).to eq('300.0')
      end
    end

    context 'if the loan is not found' do
      it 'responds with a 404' do
        get :show, id: 10000
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
