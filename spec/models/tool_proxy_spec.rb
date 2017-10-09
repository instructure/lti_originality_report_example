require 'rails_helper'
require 'lti_spec_helper'

RSpec.describe ToolProxy, type: :model do
  include_context 'lti_spec_helper'

  describe 'as_json' do
    let(:guid) { '12abc-12abc-12abc-12abc-12abc' }
    let(:tcp_url) { 'http://www.test.com/tcp' }
    let(:request) { double(base_url: 'http://www.test.com') }
    let(:tp_json) { ToolProxy.new(guid: guid, tcp_url: tcp_url, base_url: request.base_url).to_json }

    it "includes a valid '@context'" do
      expect(JSON.parse(tp_json)['@context']).to eq ['http://purl.imsglobal.org/ctx/lti/v2/ToolProxy']
    end

    it "sets 'lti_version' to LTI-2p0" do
      expect(JSON.parse(tp_json)['lti_version']).to eq 'LTI-2p0'
    end

    it "includes a valid 'tool_consumer_profile" do
      expect(JSON.parse(tp_json)['tool_consumer_profile']).to eq tcp_url
    end

    it "includes a valid 'enabled_capability'" do
      expect(JSON.parse(tp_json)['enabled_capability']).not_to be_nil
    end

    context 'tool_profile' do
      let(:tool_profile) { JSON.parse(tp_json)['tool_profile'] }

      it "includes 'lti_version'" do
        expect(tool_profile['lti_version']).to eq 'LTI-2p0'
      end

      it "includes a valid'product_instance'" do
        expected_keys = %w(guid product_info)
        product_instance_keys = tool_profile['product_instance'].keys
        expect(product_instance_keys).to match_array(expected_keys)
      end

      it "includes a valid 'base_url_choice'" do
        expected_keys = %w(default_base_url selector)
        base_url_keys = tool_profile['base_url_choice'].first.keys
        expect(base_url_keys).to match_array(expected_keys)
      end

      it "sets 'default_base_url' to the request base url" do
        default_base_url = tool_profile['base_url_choice'].first['default_base_url']
        expect(default_base_url).to eq request.base_url
      end

      it "includes a valid 'resource_handler'" do
        expected_keys = %w(resource_type resource_name message)
        resource_handler_keys = tool_profile['resource_handler'].first.keys
        expect(resource_handler_keys).to match_array(expected_keys)
      end

      it "includes 'resource_handler' with a valid 'message'" do
        expected_keys = %w(message_type path enabled_capability parameter)
        message_keys = tool_profile['resource_handler'].first['message'].first.keys
        expect(message_keys).to match_array(expected_keys)
      end

      it "includes 'vnd.Canvas.SubmissionEvent' service" do
        service = tool_profile['service_offered'].first
        expect(service['@id'].split('#').last).to eq 'vnd.Canvas.SubmissionEvent'
      end

      it "correctly sets the 'vnd.Canvas.SubmissionEvent' service endpoint" do
        service = tool_profile['service_offered'].first
        expect(service['endpoint']).to eq 'http://www.test.com/event/submission'
      end
    end

    context 'security_contract' do
      let(:security_contract) { JSON.parse(tp_json)['security_contract'] }

      it "includes 'tp_half_shared_secret' of length 128" do
        expect(security_contract['tp_half_shared_secret'].length).to eq 128
      end

      it "includes 'vnd.Canvas.OriginalityReport' service" do
        service = security_contract['tool_service'].find do |s|
          s['service'].include? 'vnd.Canvas.OriginalityReport'
        end
        expect(service).not_to be_nil
      end
    end
  end
end
