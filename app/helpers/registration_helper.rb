module RegistrationHelper
  # ToolConsumerProfile
  #
  # Helps with retrieving and using custom tool consumer profiles
  # during registration.
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

  # Registration::ToolConsumerProfile
  #
  # Represents the response to the tool proxy
  # creation request.
  class ToolProxyResponse
    attr_reader :tp_response, :redirect_url, :tp_parsed_response

    def initialize(tp_response, redirect_url)
      @tp_response = tp_response
      @tp_parsed_response = JSON.parse(tp_response.body)
      @redirect_url = redirect_url
    end

    # registration_success_url
    #
    # Returns the URL to redirect to upon successfuly tool
    # proxy creation.
    def registration_success_url
      "#{redirect_url}?tool_proxy_guid=#{tool_proxy_guid}&status=success"
    end

    # tool_proxy_guid
    #
    # Returns the tool proxy guid
    def tool_proxy_guid
      tp_parsed_response['tool_proxy_guid']
    end

    # tc_half_shared_secret
    #
    # Returns the tool consumer's half of the
    # shared secret
    def tc_half_shared_secret
      tp_parsed_response['tc_half_shared_secret']
    end

    # success?
    #
    # Returns true of the tool proxy was successfully created
    # in the tool consumer
    def success?
      tp_response.code == 201
    end
  end

  def registration_failure_url(message)
    "#{registration_redirect_url}?status=failure&lti_errormsg=#{URI.encode(message)}"
  end

  def registration_redirect_url
    params[:launch_presentation_return_url]
  end

  def register_tool_proxy(tool_proxy, tp_service_url, access_token)
    request = {
      body: tool_proxy.to_json,
      headers: {
        'Content-Type' => 'application/vnd.ims.lti.v2.toolproxy+json',
        'Authorization' => "Bearer #{access_token}"
      }
    }
    HTTParty.post(tp_service_url, request)
  end

  def jwt_access_token
    @_jwt_access_token ||= begin
      IMS::LTI::Services::AuthenticationService.new(
        iss: '',
        aud: params[:oauth2_access_token_url],
        sub: '10000000000003',
        secret: 'BXfJR44Ng3czXFt02UZwrzMSFn1GcT8KjY6wUL0RJSVIv271eCoa4KLzwciSg4fD',
        additional_claims: { code: params[:reg_key] }
      ).access_token
    end
  end

end
