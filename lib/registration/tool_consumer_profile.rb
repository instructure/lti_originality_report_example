# Registration::ToolConsumerProfile
#
# Helps with retrieving and using custom tool consumer profiles
# during registration.
module Registration
  class ToolConsumerProfile
    attr_reader :tcp_url, :access_token, :tool_consumer_profile

    def initialize(tcp_url, access_token)
      @tcp_url = tcp_url
      @access_token = access_token
      @tool_consumer_profile = fetch_tool_consumer_profile
    end

    # supports_required_capabilities?
    #
    # Returns true if the tool consumer provides the needed
    # capabilities.
    def supports_required_capabilities?
      (ToolProxy::REQUIRED_CAPABILITIES - tool_consumer_profile.capabilities_offered).blank?
    end

    # tp_service_url
    #
    # Retrieves the tool proxy service endpoint
    def tp_service_url
      tp_service = tool_consumer_profile.services_offered.find do |s|
        s.formats == [ToolProxy::TOOL_PROXY_FORMAT]
      end

      # Retrieve and return the endpoint of the ToolProxy.collection service
      URI.parse(tp_service.endpoint) unless tp_service.blank?
    end

    private

    def fetch_tool_consumer_profile
      request = { headers: { 'Authorization' => "Bearer #{access_token}" } }
      IMS::LTI::Models::ToolConsumerProfile.from_json(JSON.parse(HTTParty.get(tcp_url, request)))
    end
  end
end
