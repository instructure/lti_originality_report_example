require 'rails_helper'
require 'lti_spec_helper'

RSpec.describe RegistrationController, type: :controller do
  include_context 'lti_spec_helper'

  describe 'POST #register' do
    it 'registers a tool proxy' do
      post :register, params: registration_message
      expect(response).to redirect_to "http://canvas.docker/courses/2/lti/registration_return?tool_proxy_guid=#{tool_proxy_guid}&status=success"
    end

    it 'persists a ToolProxy' do
      prev_count = ToolProxy.count
      post :register, params: registration_message
      expect(ToolProxy.count).to eq prev_count + 1
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

    it 'redirects with status set to failure if status of tp create response is not 201' do
      post :register, params: registration_message
      expect(response).to redirect_to 'http://canvas.docker/courses/2/lti/registration_return?status=failure&lti_errormsg=Error%20received%20from%20tool%20consumer'
    end
  end
end
