require 'rails_helper'
require 'lti_spec_helper'

RSpec.describe RegistrationHelper, type: :helper do
  include_context 'lti_spec_helper'

  let(:request_parameters) do
    {
      'lti_message_type' => 'ToolProxyRegistrationRequest',
      'lti_version' => 'LTI-2p0',
      'reg_key' => '026e4140-14a3-43f2-a37e-f79a93d41075',
      'reg_password' => '6969103a-b205-42a7-aa07-0304cc60c653',
      'tc_profile_url' => 'http://canvas.docker/api/lti/courses/2/tool_consumer_profile',
      'launch_presentation_return_url' => 'http://canvas.docker/courses/2/lti/registration_return',
      'launch_presentation_document_target' => 'iframe',
      'oauth2_access_token_url' => 'http://canvas.docker/api/lti/courses/2/authorize',
      'ext_tool_consumer_instance_guid' => 'edea7cb339bf18da4132895e1a44e4b8ee7bd8d9.canvas.docker',
      'ext_api_domain' => 'canvas.docker'
    }
  end
  let(:url) { 'http://www.url.com' }
  let(:domain) { 'test.host' }
  let(:request) { double(url: url, request_parameters: request_parameters, domain: domain) }

  describe '#registration_request' do
    it 'sets the launch url to the request url' do
      expect(helper.registration_request.launch_url).to eq 'http://test.host'
    end
  end

  describe '#registration_services' do
    it 'sets the iss to the request domain' do
      expect(helper.registration_services.iss).to eq domain
    end

    it 'sets the message to the registration request' do
      expect(helper.registration_services.message).to eq helper.registration_request
    end

    it 'sets the consumer secret to the developer secret' do
      expect(helper.registration_services.consumer_secret).to eq Rails.configuration.canvas_creds['developer_secret']
    end

    it 'sets the consumer key to the developer key' do
      expect(helper.registration_services.consumer_key).to eq Rails.configuration.canvas_creds['developer_key']
    end

    it "adds the 'code' param" do
      expect(helper.registration_services.authentication_service.additional_params.keys).to include :code
    end
  end

  describe '#tool_proxy_registration_service' do
    it 'returns the registration service' do
      expect(helper.tool_proxy_registration_service).to eq helper.registration_services.registration_service
    end
  end

  describe '#registration_success_url' do
    it 'sets the status param to success' do
      url = URI.parse(helper.registration_success_url('tp-guid'))
      expect(url.query).to include 'status=success'
    end

    it 'sets the tool proxy guid param' do
      url = URI.parse(helper.registration_success_url('tp-guid'))
      expect(url.query).to include 'tool_proxy_guid=tp-guid'
    end
  end

  describe '#registration_failure_url' do
    it 'sets the status to failure' do
      url = URI.parse(helper.registration_failure_url('this is a message'))
      expect(url.query).to include 'status=failure'
    end

    it 'sets the lti_errormsg' do
      url = URI.parse(helper.registration_failure_url('this is a message'))
      expect(url.query).to include "lti_errormsg=#{URI.encode('this is a message')}"
    end
  end
end
