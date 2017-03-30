require 'rails_helper'
require 'lti_spec_helper'

RSpec.describe Registration::ToolConsumerProfile do
  include_context 'lti_spec_helper'

  let(:http_party) { class_double(HTTParty).as_stubbed_const }
  let(:access_token) { 'eya34a34.a4453ad.12323234a' }
  let(:tcp_helper) { Registration::ToolConsumerProfile.new('http://www.tcp.com', access_token) }

  before do
    allow(http_party).to receive_messages(get: tool_consumer_profile)
  end

  context 'fetch tool consumer profile' do
    it 'fetches the tool consumer profile' do
      expect(http_party).to receive(:get)
      Registration::ToolConsumerProfile.new('http://www.tcp.com', access_token)
    end
  end

  describe '#supports_required_capabilities?' do
    it 'returns true if the TCP supports all required capabilities' do
      expect(tcp_helper.supports_required_capabilities?).to be_truthy
    end

    it 'returns false if the TCP does not contain all required capabilities' do
      ToolProxy::REQUIRED_CAPABILITIES = ['Capaability.not.Offered']
      expect(tcp_helper.supports_required_capabilities?).to be_falsey
    end
  end

  describe '#tp_service_url' do
    it 'finds the tool proxy service endpoint'
end
