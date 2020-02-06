# frozen_string_literal: true

require 'rails_helper'

# RSpec tests for User actions
RSpec.describe Api::V1::UsersController, type: :controller do
  let(:user_params) do
    { email: 'test1@email.com', password: 'password', password_confirmation: 'password', \
      first_name: 'John', last_name: 'Doe', timezone: 'Eastern Time (US & Canada)' }
  end

  let(:non_unique) do
    { email: 'test@gmail.com', password: 'password', password_confirmation: 'password', \
      first_name: 'John', last_name: 'Doe', timezone: 'Eastern Time (US & Canada)' }
  end

  let(:missing_pw_conf) do
    { email: 'test@gmail.com', password: 'password', password_confirmation: nil, \
      first_name: 'John', last_name: 'Doe', timezone: 'Eastern Time (US & Canada)' }
  end

  let(:missing_last_name) do
    { email: 'test@gmail.com', password: 'password', password_confirmation: 'password', \
      first_name: 'John', last_name: nil, timezone: 'Eastern Time (US & Canada)' }
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'returns http success' do
        post :create, params: { user: user_params }
        expect(response).to be_successful
        expect(response_json.keys).to eq ['data']
      end

      it 'creates a new user' do
        expect do
          post :create, params: { user: user_params }
        end.to change(User, :count).by(1)
      end
    end

    context 'with non-unique email' do
      it 'renders a JSON response with errors' do
        # seed a user to DB for non-unique test
        FactoryBot.create(:user)
        post :create, params: { user: non_unique }
        expect(response).to have_http_status(:bad_request)
        expect(response.content_type).to include('application/json')
        expect(response_json.keys).to eq ['error']
      end

      it 'does not create a new user' do
        # seed a user to DB for non-unique test
        FactoryBot.create(:user)
        expect do
          post :create, params: { user: non_unique }
        end.to change(User, :count).by(0)
      end
    end

    context 'with missing password_confirmation' do
      it 'renders a JSON response with errors' do
        post :create, params: { user: missing_pw_conf }
        expect(response).to have_http_status(:bad_request)
        expect(response.content_type).to include('application/json')
        expect(response_json.keys).to eq ['error']
      end

      it 'does not create a new user' do
        expect do
          post :create, params: { user: missing_pw_conf }
        end.to change(User, :count).by(0)
      end
    end

    context 'with missing last_name' do
      it 'renders a JSON response with errors' do
        post :create, params: { user: missing_last_name }
        expect(response).to have_http_status(:bad_request)
        expect(response.content_type).to include('application/json')
        expect(response_json.keys).to eq ['error']
      end

      it 'does not create a new user' do
        expect do
          post :create, params: { user: missing_last_name }
        end.to change(User, :count).by(0)
      end
    end
  end

  describe 'GET #show' do
    context 'user is logged in' do
      include_context 'logged in user'

      before { get :show }

      it 'returns a success response' do
        expect(response).to have_http_status(:ok)
      end

      it 'renders a JSON response with the user' do
        expect(response_json).not_to be_empty
        expect(response_json['data']['id']).to eq user.id.to_s
      end
    end

    context 'user is not logged in' do
      before { get :show }

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

  describe 'PUT #update' do
    context 'user is logged in' do
      include_context 'logged in user'

      before { put :update, params: { user: { first_name: 'Kevin' } } }

      it 'returns a success response' do
        expect(response).to have_http_status(:ok)
      end

      it 'renders a JSON response with the updated user first_name' do
        expect(response_json).not_to be_empty
        expect(response_json['data']['attributes']['first_name']).to eq user.first_name
      end
    end

    context 'user is not logged in' do
      before { put :update, params: { user: { first_name: 'Kevin' } } }

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

  describe 'DELETE #destroy' do
    context 'user is logged in' do
      include_context 'logged in user'

      it 'returns a no_content response' do
        delete :destroy
        expect(response).to have_http_status(:no_content)
      end

      it 'removes the user' do
        expect do
          delete :destroy
        end.to change(User, :count).by(-1)
      end
    end

    context 'user is not logged in' do
      before { delete :destroy }

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
