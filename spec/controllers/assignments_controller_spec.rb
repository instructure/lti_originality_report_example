require 'rails_helper'

RSpec.describe AssignmentsController, type: :controller do
  let(:rand_id) { SecureRandom.uuid }
  let(:shared_secret) { 'e5bf61debb355e4552732a943c74801ee02bc24ef1d6a077c6e68363fb9dcc4dceab75e6ae4f1e6ae9df5a6892ebbabe49feecc67f00f7e447b43f270e115c590533cd9a176a23eaba334834180da227521884bb49fae1993ca15d52c077b7d37d2ab6fd924a86a285f438f2fc161f63806468d1b977ff120635aa70f9d1d7a5' }
  let(:tool_proxy) { ToolProxy.create!(shared_secret: shared_secret, guid: SecureRandom.uuid, tcp_url: 'test.com', base_url: 'base.com') }
  let(:params) do
    {
      oauth_consumer_key: tool_proxy.guid,
      ext_lti_assignment_id: rand_id
    }
  end

  describe '#show_by_lti_id' do
    let!(:assignment) { tool_proxy.assignments.create!(lti_assignment_id: rand_id) }
    let(:params) { { lti_assignment_id: rand_id } }

    it 'returns the correct assignment if it exists' do
      get :show_by_lti_id, params: params
      expect(response).to have_http_status(:ok)

      actual = JSON.parse!(response.body, symbolize_names: true)
      expect(actual[:lti_assignment_id]).to eq(assignment.lti_assignment_id)
    end

    it 'returns a Not Found if no assignment matches' do
      params = { lti_assignment_id: SecureRandom.uuid }
      get :show_by_lti_id, params: params
      expect(response).to have_http_status(:not_found)
    end
  end

  describe '#configure' do
    it 'creates an assignment if one is not found' do
      controller.class.skip_before_action :lti_authentication
      post :configure, params: params
      expect(Assignment.find_by(lti_assignment_id: rand_id)).not_to be_nil
    end

    it 'uses existing assignments' do
      Assignment.create!(lti_assignment_id: rand_id, tool_proxy: tool_proxy)
      expect(Assignment.where(lti_assignment_id: rand_id).length).to eq 1
    end
  end

  describe '#update' do
    let(:setting_value) { 'test-setting-value' }

    before do
      Assignment.create!(lti_assignment_id: rand_id, tool_proxy: tool_proxy)
      request.host = nil
    end

    it 'rejects requests with a different origin domain than its own' do
      post :update, params: { settings: { some_setting: setting_value }, lti_assignment_id: rand_id }
      expect(response).to be_unauthorized
    end
  end
end
