# frozen_string_literal: true

require 'rails_helper'

module Api
  module V1
    RSpec.describe AccountsController, type: :controller do
      let(:user) { FactoryBot.create(:user) }

      let(:valid_attributes) do
        {
          name: 'PNC Bank Account',
          starting_balance: 1000,
          last_four: 1234,
          active: true
        }
      end

      let(:invalid_attributes) do
        {
          name: nil,
          starting_balance: 1000,
          last_four: 12_345
        }
      end

      context 'user is logged in' do
        include_context 'logged in user'

        describe 'GET #index' do
          let!(:account) { FactoryBot.create(:account, user: user) }

          context 'users own accounts' do
            before { get :index }

            it 'returns a success response' do
              expect(response).to be_successful
            end

            it 'returns a JSON response of active accounts' do
              expect(response_json.size).to eq 1
              expect(response_json['data'].first['id']).to eq account.id.to_s
            end
          end

          context 'other users accounts' do
            let!(:user2) { FactoryBot.create(:user, email: 'newuser@gmail.com') }
            let!(:account_user2) { FactoryBot.create(:account, name: 'User 2 account', user: user2) }
            before { get :index }

            it 'excludes other users accounts' do
              expect(response_json['data'].detect { |e| e['name'] == account_user2.name }).to be_nil
            end
          end
        end

        describe 'GET #inactive' do
          let!(:account) { FactoryBot.create(:account, user: user) }
          before { post :deactivate, params: { id: account.id } }
          before { get :inactive }

          it 'returns a success response' do
            expect(response).to be_successful
          end

          it 'returns a JSON response of inactive accounts' do
            expect(response_json.size).to eq 1
            expect(response_json['data'].first['id']).to eq account.id.to_s
          end
        end

        describe 'GET #show' do
          let!(:account) { FactoryBot.create(:account, user: user) }
          let(:account_id) { account.id }
          before { get :show, params: { id: account_id } }

          context 'when the record exists' do
            it 'returns a success response' do
              expect(response).to have_http_status(:ok)
            end

            it 'returns the account' do
              expect(response_json).not_to be_empty
              expect(response_json['data']['id']).to eq(account.id.to_s)
            end
          end

          context 'when the record does not exist' do
            let(:account_id) { 100 }

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
              post :create, params: { account: valid_attributes }
              expect(response).to have_http_status(:created)
            end

            it 'creates a new account' do
              expect do
                post :create, params: { account: valid_attributes }
              end.to change(Account, :count).by(1)
            end

            it 'renders a JSON response with the new account' do
              post :create, params: { account: valid_attributes }
              expect(response.content_type).to include('application/json')
              expect(response.location).to eq(account_url(Account.last))
              expect(response_json['data']['id']).to eq(Account.last.id.to_s)
            end
          end

          context 'when the request is invalid' do
            it 'returns an error message' do
              post :create, params: { account: invalid_attributes }
              expect(response_json.keys).to eq ['error']
            end

            it 'returns an unprocessable_entity response' do
              post :create, params: { account: invalid_attributes }
              expect(response).to have_http_status(:unprocessable_entity)
            end
          end
        end

        describe 'PUT #update' do
          let!(:account) { FactoryBot.create(:account, user: user) }

          context 'when the request is valid' do
            let(:new_attributes) do
              { name: 'Super secret account name' }
            end
            before { put :update, params: { id: account.to_param, account: new_attributes } }

            it 'returns a success response' do
              expect(response).to have_http_status(:ok)
            end

            it 'updates the requested account' do
              account.reload
              expect(account.name).to eq new_attributes[:name]
            end

            it 'returns a JSON response with the updated account' do
              account.reload
              expect(response.content_type).to include('application/json')
              expect(response_json['data']['attributes']['name']).to eq new_attributes[:name]
            end
          end

          context 'when the request is invalid' do
            let(:new_attributes) do
              { name: nil }
            end
            before { put :update, params: { id: account.to_param, account: new_attributes } }

            it 'returns an unprocessable_entity response' do
              expect(response).to have_http_status(:unprocessable_entity)
            end

            it 'returns an error message' do
              expect(response_json.keys).to eq ['error']
            end
          end

          context 'when the account does not exist' do
            let(:new_attributes) do
              { name: 'This will fail' }
            end
            before { put :update, params: { id: 500, account: new_attributes } }

            it 'returns a not found response' do
              expect(response).to have_http_status(:not_found)
            end

            it 'returns an error message' do
              expect(response_json.keys).to eq ['error']
            end
          end
        end

        describe 'DELETE #destroy' do
          let!(:account) { FactoryBot.create(:account, user: user) }

          context 'when the request is valid' do
            it 'returns a success response' do
              delete :destroy, params: { id: account.id }
              expect(response).to have_http_status(:no_content)
            end

            it 'destroys the requested account' do
              expect do
                delete :destroy, params: { id: account.id }
              end.to change(Account, :count).by(-1)
            end
          end

          context 'when the account does not exist' do
            before { delete :destroy, params: { id: 500 } }

            it 'returns a not found response' do
              expect(response).to have_http_status(:not_found)
            end

            it 'returns an error message' do
              expect(response_json.keys).to eq ['error']
            end
          end
        end

        describe 'POST #deactivate' do
          let!(:account) { FactoryBot.create(:account, user: user) }

          context 'when the request is valid' do
            before { post :deactivate, params: { id: account.id } }

            it 'returns a success response' do
              expect(response).to have_http_status(:ok)
            end

            it 'changes the account active status' do
              account.reload
              expect(account.active).to eq(false)
            end
          end

          context 'when the account does not exist' do
            before { post :deactivate, params: { id: 500 } }

            it 'returns a not found response' do
              expect(response).to have_http_status(:not_found)
            end

            it 'returns an error message' do
              expect(response_json.keys).to eq ['error']
            end
          end
        end

        describe 'POST #activate' do
          let!(:account) { FactoryBot.create(:account, user: user) }
          before { post :deactivate, params: { id: account.id } }

          context 'when the request is valid' do
            before { post :activate, params: { id: account.id } }

            it 'returns a success response' do
              expect(response).to have_http_status(:ok)
            end

            it 'changes the account active status' do
              account.reload
              expect(account.active).to eq(true)
            end
          end

          context 'when the account does not exist' do
            before { post :activate, params: { id: 500 } }

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
          let!(:account) { FactoryBot.create(:account, user: user) }
          before { get :index }

          it 'returns an unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'returns a JSON response with error' do
            expect(response.content_type).to include('application/json')
            expect(response_json.keys).to eq ['error']
            expect(response.body).to match(/Not Authorized/)
          end
        end

        describe 'GET #inactive' do
          let!(:account) { FactoryBot.create(:account, user: user) }
          before { post :deactivate, params: { id: account.id } }
          before { get :inactive }

          it 'returns an unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'returns a JSON response with error' do
            expect(response.content_type).to include('application/json')
            expect(response_json.keys).to eq ['error']
            expect(response.body).to match(/Not Authorized/)
          end
        end

        describe 'GET #show' do
          let!(:account) { FactoryBot.create(:account, user: user) }
          before { get :show, params: { id: account.id } }

          it 'returns an unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'returns a JSON response with error' do
            expect(response.content_type).to include('application/json')
            expect(response_json.keys).to eq ['error']
            expect(response.body).to match(/Not Authorized/)
          end
        end

        describe 'POST #create' do
          before { post :create, params: { account: valid_attributes } }

          it 'returns an unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'returns a JSON response with error' do
            expect(response.content_type).to include('application/json')
            expect(response_json.keys).to eq ['error']
            expect(response.body).to match(/Not Authorized/)
          end
        end

        describe 'PUT #update' do
          let!(:account) { FactoryBot.create(:account, user: user) }
          let(:new_attributes) do
            { name: 'Super secret account name' }
          end
          before { put :update, params: { id: account.id, account: new_attributes } }

          it 'returns an unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'returns a JSON response with error' do
            expect(response.content_type).to include('application/json')
            expect(response_json.keys).to eq ['error']
            expect(response.body).to match(/Not Authorized/)
          end
        end

        describe 'DELETE #destroy' do
          let!(:account) { FactoryBot.create(:account, user: user) }
          before { delete :destroy, params: { id: account.id } }

          it 'returns an unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'returns a JSON response with error' do
            expect(response.content_type).to include('application/json')
            expect(response_json.keys).to eq ['error']
            expect(response.body).to match(/Not Authorized/)
          end
        end

        describe 'POST #deactivate' do
          let!(:account) { FactoryBot.create(:account, user: user) }
          before { post :deactivate, params: { id: account.id } }

          it 'returns an unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'returns a JSON response with error' do
            expect(response.content_type).to include('application/json')
            expect(response_json.keys).to eq ['error']
            expect(response.body).to match(/Not Authorized/)
          end
        end

        describe 'POST #activate' do
          let!(:account) { FactoryBot.create(:account, user: user) }
          before { post :activate, params: { id: account.id } }

          it 'returns an unauthorized response' do
            expect(response).to have_http_status(:unauthorized)
          end

          it 'returns a JSON response with error' do
            expect(response.content_type).to include('application/json')
            expect(response_json.keys).to eq ['error']
            expect(response.body).to match(/Not Authorized/)
          end
        end
      end
    end
  end
end
