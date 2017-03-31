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
    "#{registration_redirect_url}?status=failure&lti_errormsg=#{message}"
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
      get_jwt_access_token(
        url: params[:oauth2_access_token_url],
        sub: '10000000000003', # Developer key global id
        secret: 'BXfJR44Ng3czXFt02UZwrzMSFn1GcT8KjY6wUL0RJSVIv271eCoa4KLzwciSg4fD', # Developer key api key. Don't store this here ;)
        code: params[:reg_key])
    end
  end

  def get_jwt_access_token(url:, sub:, secret:, code: nil)
    assertion = JSON::JWT.new({
      sub: sub,
      aud: url,
      exp: 1.minute.from_now,
      iat: Time.now.to_i,
      jti: SecureRandom.uuid
    })
    assertion = assertion.sign(secret, :HS256).to_s

    request = {
      body: {
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: assertion
      }
    }

    # If using a developer key as the subject
    if code.present?
      request = {
        body: {
          grant_type: 'authorization_code',
          code: code,
          assertion: assertion
        }
      }
    end

    response = HTTParty.post(url, request)
    response.parsed_response['access_token']
  end
end
