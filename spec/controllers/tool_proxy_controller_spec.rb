require 'rails_helper'

RSpec.describe ToolProxyController, type: :controller do
  let(:shared_secret) { 'e5bf61debb355e4552732a943c74801ee02bc24ef1d6a077c6e68363fb9dcc4dceab75e6ae4f1e6ae9df5a6892ebbabe49feecc67f00f7e447b43f270e115c590533cd9a176a23eaba334834180da227521884bb49fae1993ca15d52c077b7d37d2ab6fd924a86a285f438f2fc161f63806468d1b977ff120635aa70f9d1d7a5' }
  let(:tool_proxy) { ToolProxy.create!(shared_secret: shared_secret, guid: SecureRandom.uuid, tcp_url: 'test.com', base_url: 'base.com') }
  let(:lti_assignment_id) { SecureRandom.uuid }
  let(:assignment) { tool_proxy.assignments.create!(lti_assignment_id: lti_assignment_id, tc_id: SecureRandom.random_number) }

  describe 'GET #obtain_guid_by_id' do
    it 'returns the guid for a valid proxy id' do
      get :obtain_guid_by_id, params: { proxy_id: tool_proxy.id }
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq(tool_proxy.guid)
    end

    it 'returns a 404 for an invalid proxy id' do
      get :obtain_guid_by_id, params: { proxy_id: 55_041 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET #obtain_guid_by_assignment_tc_id' do
    it 'returns the correct proxy guid for a valid assignment tool consumer id' do
      get :obtain_guid_by_assignment_tc_id, params: { assignment_tc_id: assignment.tc_id }
      expect(response.body).to eq(tool_proxy.guid)
    end

    it 'returns a 404 for an invalid assignment tool consumer id' do
      get :obtain_guid_by_assignment_tc_id, params: { assignment_tc_id: 5_050_457 }
    end
  end
end
