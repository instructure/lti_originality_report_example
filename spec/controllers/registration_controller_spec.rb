require 'rails_helper'
require 'lti_spec_helper'

RSpec.describe RegistrationController, type: :controller do
  include_context 'lti_spec_helper'

  let(:tc_half_shared_secret) { SecureRandom.uuid }
  let(:tool_proxy_guid) { SecureRandom.uuid }
  let(:ims_tool_proxy) { double(tc_half_shared_secret: tc_half_shared_secret, tool_proxy_guid: tool_proxy_guid) }
  let(:ims_tool_consumer_profile) { IMS::LTI::Models::ToolConsumerProfile.from_json(tool_consumer_profile) }
  let(:tool_proxy_registration_service) { double(tool_consumer_profile: ims_tool_consumer_profile) }
  let(:registration_services_instance) { double(tp_registration_service: tool_proxy_registration_service) }
  let(:authentication_service) { double(additional_params: {}) }

  before do
    allow(IMS::LTI::Services::RegistrationServices).to receive(:new) { registration_services_instance }
    allow(registration_services_instance).to receive(:authentication_service=)
    allow(tool_proxy_registration_service).to receive(:register_tool_proxy) { ims_tool_proxy }
    allow(registration_services_instance).to receive(:authentication_service) { authentication_service }
    allow(registration_services_instance).to receive(:registration_service) { tool_proxy_registration_service }
  end

  describe 'POST #register' do
    it 'registers a tool proxy' do
      post :register, params: registration_message
      expect(response).to redirect_to "http://canvas.docker/courses/2/lti/registration_return?status=success&tool_proxy_guid=#{tool_proxy_guid}"
    end

    it 'persists a ToolProxy' do
      prev_count = ToolProxy.count
      post :register, params: registration_message
      expect(ToolProxy.count).to eq prev_count + 1
    end

    it 'saves the authorization url' do
      post :register, params: registration_message
      expect(ToolProxy.last.authorization_url).to eq 'http://canvas.docker/api/lti/courses/2/authorize'
    end

    it 'saves the submission service url' do
      post :register, params: registration_message
      expect(ToolProxy.last.submission_service_url).to eq 'http://canvas.docker/api/lti/assignment/2/submissions'
    end

    it 'assembles both halves of the shared secret' do
      post :register, params: registration_message
      tp = ToolProxy.last
      expect(tp.shared_secret).to include tc_half_shared_secret
    end

    it 'redirects with status set to failure if required capabilities are missing' do
      prev_capabilities = ToolProxy::REQUIRED_CAPABILITIES
      ToolProxy::REQUIRED_CAPABILITIES = %w(Capaability.not.Offered).freeze
      post :register, params: registration_message
      expect(response).to redirect_to  'http://canvas.docker/courses/2/lti/registration_return?status=failure&lti_errormsg=Missing%20required%20capabilities'
      ToolProxy::REQUIRED_CAPABILITIES = prev_capabilities
    end

    it 'redirects with status set to failure if status of tp create response is not success' do
      allow(tool_proxy_registration_service).to receive(:register_tool_proxy) { false }
      post :register, params: registration_message
      expect(response).to redirect_to 'http://canvas.docker/courses/2/lti/registration_return?status=failure&lti_errormsg=Error%20received%20from%20tool%20consumer'
    end
  end
end
