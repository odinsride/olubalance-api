# frozen_string_literal: true

require 'rails_helper'

module Api
  module V1
    RSpec.describe TransactionsController, type: :controller do
      let(:user) { FactoryBot.create(:user) }
      let(:account) { FactoryBot.create(:account, user: user) }

      let(:valid_attributes) do
        {
          trx_date: '2018-12-31',
          description: 'Transaction API Test Transaction',
          amount: 100,
          trx_type: 'debit',
          memo: 'Sample Memo'
        }
      end

      let(:invalid_attributes) do
        {
          trx_date: '2018-12-31',
          description: nil,
          amount: 100,
          trx_type: 'debit',
          memo: 'Sample Memo'
        }
      end

      context 'user is logged in' do
        include_context 'logged in user'

        describe 'GET #index' do
          let!(:transaction) { FactoryBot.create(:transaction, account: account) }

          context 'users own transactions' do
            before { get :index, params: { account_id: account.id } }

            it 'returns a success response' do
              expect(response).to be_successful
            end

            it 'returns a JSON response of transactions' do
              expect(response_json['data'].size).to eq 2 # includes Starting Balance transaction
              expect(response_json['data'].first['id']).to eq transaction.id.to_s
              expect(response_json['data'].first['attributes']['description']).to eq transaction.description
            end
          end

          context 'other users transactions' do
            let!(:user2) { FactoryBot.create(:user, email: 'newuser@gmail.com') }
            let!(:account_user2) { FactoryBot.create(:account, name: 'User 2 account', user: user2) }
            let!(:transaction_user2) { FactoryBot.create(:transaction, account: account_user2) }

            before { get :index, params: { account_id: account_user2.id } }

            it 'excludes other users transactions' do
              expect(response_json['data']).to be_nil
            end
          end
        end

        describe 'GET #show' do
          let!(:transaction) { FactoryBot.create(:transaction, account: account) }
          let(:transaction_id) { transaction.id }

          before { get :show, params: { account_id: account.id, id: transaction_id } }

          context 'when the record exists' do
            it 'returns a success response' do
              expect(response).to have_http_status(:ok)
            end

            it 'returns the transaction' do
              expect(response_json).not_to be_empty
              expect(response_json['data']['id']).to eq(transaction_id.to_s)
            end
          end

          context 'when the record does not exist' do
            let(:transaction_id) { 9999 }

            it 'returns HTTP status 404' do
              expect(response).to have_http_status(:not_found)
            end

            it 'returns a not found message' do
              expect(response.body).to match(/Not found/)
            end
          end
        end

        describe 'POST #create' do
          context 'when the request is valid' do
            it 'returns status created' do
              post :create, params: { account_id: account.id, transaction: valid_attributes }
              expect(response).to have_http_status(:created)
            end

            it 'creates a new transaction' do
              expect do
                post :create, params: { account_id: account.id, transaction: valid_attributes }
              end.to change(Transaction, :count).by(2) # account for starting balance record
            end

            it 'renders a JSON response with the new transaction' do
              post :create, params: { account_id: account.id, transaction: valid_attributes }
              expect(response.content_type).to eq('application/json')
              expect(response.location).to eq(account_transaction_url(id: Transaction.last.id))
              expect(response_json['data']['id']).to eq(Transaction.last.id.to_s)
            end
          end

          context 'when the request is invalid' do
            it 'returns an error message' do
              post :create, params: { account_id: account.id, transaction: invalid_attributes }
              expect(response_json.keys).to eq ['error']
            end

            it 'returns an unprocessable_entity response' do
              post :create, params: { account_id: account.id, transaction: invalid_attributes }
              expect(response).to have_http_status(:unprocessable_entity)
            end
          end
        end

        describe 'PUT #update' do
          let!(:transaction) { FactoryBot.create(:transaction, account: account) }

          context 'when the request is valid' do
            let(:new_attributes) do
              { trx_type: 'debit',
                amount: 50,
                description: 'Updated Transaction Description' }
            end

            before do
              put :update, params: { id: transaction.id,
                                     account_id: account.id,
                                     transaction: new_attributes }
            end

            it 'returns a success response' do
              expect(response).to have_http_status(:ok)
            end

            it 'updates the requested transaction' do
              transaction.reload
              expect(transaction.description).to eq new_attributes[:description]
            end

            it 'returns a JSON response with the updated transaction' do
              transaction.reload
              expect(response.content_type).to eq('application/json')
              expect(response_json['data']['attributes']['description']).to eq new_attributes[:description]
            end
          end

          context 'when the request is invalid' do
            let(:new_attributes) do
              { trx_type: nil }
            end
            before do
              put :update, params: { account_id: account.id,
                                     id: transaction.to_param,
                                     transaction: new_attributes }
            end

            it 'returns an unprocessable_entity response' do
              expect(response).to have_http_status(:unprocessable_entity)
            end

            it 'returns an error message' do
              expect(response_json.keys).to eq ['error']
            end
          end

          context 'when the transaction does not exist' do
            let(:new_attributes) do
              { description: 'This will fail' }
            end

            before { put :update, params: { account_id: account.id, id: 9999, transaction: new_attributes } }

            it 'returns a not found response' do
              expect(response).to have_http_status(:not_found)
            end

            it 'returns an error message' do
              expect(response_json.keys).to eq ['error']
            end
          end
        end

        describe 'DELETE #destroy' do
          let!(:transaction) { FactoryBot.create(:transaction, account: account) }

          context 'when the request is valid' do
            it 'returns a success response' do
              delete :destroy, params: { id: transaction.id, account_id: account.id }
              expect(response).to have_http_status(:no_content)
            end

            it 'destroys the requested transaction' do
              expect do
                delete :destroy, params: { id: transaction.id, account_id: account.id }
              end.to change(Transaction, :count).by(-1)
            end
          end

          context 'when the transaction does not exist' do
            before { delete :destroy, params: { id: 9999, account_id: account.id } }

            it 'returns a not found response' do
              expect(response).to have_http_status(:not_found)
            end

            it 'returns an error message' do
              expect(response_json.keys).to eq ['error']
            end
          end
        end
      end

      context 'user is not logged in' do
        describe 'GET #index' do
          let!(:transaction) { FactoryBot.create(:transaction, account: account) }
          before { get :index, params: { account_id: account.id } }

          it 'returns an unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'returns a JSON response with error' do
            expect(response.content_type).to eq('application/json')
            expect(response_json.keys).to eq ['error']
            expect(response.body).to match(/Not Authorized/)
          end
        end

        describe 'GET #show' do
          let!(:transaction) { FactoryBot.create(:transaction, account: account) }
          before { get :show, params: { id: transaction.id, account_id: account.id } }

          it 'returns an unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'returns a JSON response with error' do
            expect(response.content_type).to eq('application/json')
            expect(response_json.keys).to eq ['error']
            expect(response.body).to match(/Not Authorized/)
          end
        end

        describe 'POST #create' do
          before { post :create, params: { account_id: account.id, transaction: valid_attributes } }

          it 'returns an unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'returns a JSON response with error' do
            expect(response.content_type).to eq('application/json')
            expect(response_json.keys).to eq ['error']
            expect(response.body).to match(/Not Authorized/)
          end
        end

        describe 'PUT #update' do
          let!(:transaction) { FactoryBot.create(:transaction, account: account) }
          let(:new_attributes) do
            { trx_type: 'debit',
              amount: 50,
              description: 'New Transaction Description' }
          end

          before do
            put :update, params: { id: transaction.id,
                                   account_id: account.id,
                                   transaction: new_attributes }
          end

          it 'returns an unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'returns a JSON response with error' do
            expect(response.content_type).to eq('application/json')
            expect(response_json.keys).to eq ['error']
            expect(response.body).to match(/Not Authorized/)
          end
        end

        describe 'DELETE #destroy' do
          let!(:transaction) { FactoryBot.create(:transaction, account: account) }
          before { delete :destroy, params: { id: transaction.id, account_id: account.id } }

          it 'returns an unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'returns a JSON response with error' do
            expect(response.content_type).to eq('application/json')
            expect(response_json.keys).to eq ['error']
            expect(response.body).to match(/Not Authorized/)
          end
        end
      end
    end
  end
end
