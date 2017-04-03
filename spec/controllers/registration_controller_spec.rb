require 'rails_helper'
require 'lti_spec_helper'

RSpec.describe RegistrationController, type: :controller do
  include_context 'lti_spec_helper'
  let(:http_party) { class_double(HTTParty).as_stubbed_const }
  let(:authorization_response) { double(parsed_response: { 'access_token' => access_token }, body: {}) }
  let(:tool_proxy_response) { double(parsed_response: tp_response, body: tp_response, code: 201) }

  before do
    allow(http_party).to receive_messages(get: tool_consumer_profile)
    allow(http_party).to receive_messages(post: tool_proxy_response)
  end

  describe 'POST #register' do
    it 'registers a tool proxy' do
      post :register, registration_message
      expect(response).to redirect_to "http://canvas.docker/courses/2/lti/registration_return?tool_proxy_guid=#{tool_proxy_guid}&status=success"
    end

    it 'persists a ToolProxy' do
      prev_count = ToolProxy.count
      post :register, registration_message
      expect(ToolProxy.count).to eq prev_count + 1
    end

    it 'assembles both halves of the shared secret' do
      post :register, registration_message
      tp = ToolProxy.last
      expect(tp.shared_secret).to include tc_half_shared_secret
    end

    it 'redirects with status set to failure if required capabilities are missing' do
      prev_capabilities = ToolProxy::REQUIRED_CAPABILITIES
      ToolProxy::REQUIRED_CAPABILITIES = %w(Capaability.not.Offered).freeze
      post :register, registration_message
      expect(response).to redirect_to  'http://canvas.docker/courses/2/lti/registration_return?status=failure&lti_errormsg=Missing%20required%20capabilities'
      ToolProxy::REQUIRED_CAPABILITIES = prev_capabilities
    end

    it 'redirects with status set to failure if status of tp create response is not 201' do
      tool_proxy_response = double(parsed_response: tp_response, body: tp_response, code: 401)
      allow(http_party).to receive_messages(post: tool_proxy_response)

      post :register, registration_message
      expect(response).to redirect_to  'http://canvas.docker/courses/2/lti/registration_return?status=failure&lti_errormsg=Error%20received%20from%20tool%20consumer'
    end
  end
end
