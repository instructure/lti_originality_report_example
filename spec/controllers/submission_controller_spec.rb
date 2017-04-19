require 'rails_helper'

RSpec.describe SubmissionController, type: :controller do
  let(:rand_id) { SecureRandom.uuid }
  let(:shared_secret) { 'e5bf61debb355e4552732a943c74801ee02bc24ef1d6a077c6e68363fb9dcc4dceab75e6ae4f1e6ae9df5a6892ebbabe49feecc67f00f7e447b43f270e115c590533cd9a176a23eaba334834180da227521884bb49fae1993ca15d52c077b7d37d2ab6fd924a86a285f438f2fc161f63806468d1b977ff120635aa70f9d1d7a5' }
  let(:tool_proxy) { ToolProxy.create!(shared_secret: shared_secret, guid: SecureRandom.uuid, tcp_url: 'test.com', base_url: 'base.com') }
  let(:lti_assignment_id) { SecureRandom.uuid }
  let(:assignment) { tool_proxy.assignments.create!(lti_assignment_id: lti_assignment_id) }
  let(:submission_tc_id) { SecureRandom.uuid }
  let!(:submission) { assignment.submissions.create!(tc_id: submission_tc_id) }
  let(:params) do
    {
      oauth_consumer_key: tool_proxy.guid
    }
  end

  describe '#index' do
    it 'renders the submissions' do
      controller.class.skip_before_action :lti_authentication
      post :index, params: params
      expect(response).to have_http_status(:success)
    end
  end
end
