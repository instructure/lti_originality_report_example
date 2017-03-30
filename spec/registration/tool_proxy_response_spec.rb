require 'rails_helper'
require 'lti_spec_helper'

RSpec.describe Registration::ToolProxyResponse do
  include_context 'lti_spec_helper'

  let(:parsed_body) do
    {
      '@context' => 'http =>//purl.imsglobal.org/ctx/lti/v2/ToolProxyId',
      '@type' => 'ToolProxy',
      'tool_proxy_guid' => tool_proxy_guid,
      'tc_half_shared_secret' => tc_half_shared_secret
    }.to_json
  end
  let(:http_party_response) { instance_double(HTTParty::Response) }
  let(:redirect_url) { 'http://tool.consumer.com/redirect' }
  let(:tp_response_helper) { Registration::ToolProxyResponse.new(http_party_response, redirect_url) }
  let(:tool_proxy_guid) { '00d97c7d-f163-44aa-9921-c7c186a5e809' }
  let(:tc_half_shared_secret) { '0e5de8345149b53c28e49f1da467f077b6ecf8fd1e29cff9d2bea693105ac353e4742b168ca594f2d0346ebc968454ce57f0a84017b6f4b2d279f08797d66928' }

  before do
    allow(http_party_response).to receive_messages(body: parsed_body)
    allow(http_party_response).to receive_messages(code: 201)
  end

  describe '#registration_success_url' do
    it 'includes the tool proxy guid' do
      uri = URI.parse(tp_response_helper.registration_success_url)
      expect(URI::decode_www_form(uri.query).to_h['tool_proxy_guid']).to eq tool_proxy_guid
    end

    it "sets the status param to 'success'" do
      uri = URI.parse(tp_response_helper.registration_success_url)
      expect(URI::decode_www_form(uri.query).to_h['status']).to eq 'success'
    end
  end

  describe '#tool_proxy_guid' do
    it 'returns the tool proxy guid' do
      expect(tp_response_helper.tool_proxy_guid).to eq tool_proxy_guid
    end
  end

  describe '#tc_half_shared_secret' do
    it "returns the tool consumer's half of the shared secret" do
      expect(tp_response_helper.tc_half_shared_secret).to eq tc_half_shared_secret
    end
  end

  describe '#success?' do
    it 'returns true if the response is 201' do
      expect(tp_response_helper.success?).to be_truthy
    end

    it 'returns false if the resposne is not 201' do
      allow(http_party_response).to receive_messages(code: 400)
      expect(tp_response_helper.success?).to be_falsey
    end
  end
end
