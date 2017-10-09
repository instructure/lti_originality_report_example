# frozen_string_literal: true

module LtiAuthorizationHelper
  # access_token
  #
  # Returns an access token used for making calls
  # to LTI 2 endpoints in Canvas.
  def access_token
    puts "---------- Access Token -------------"
    puts authentication_service.access_token
    puts "-------------------------------------"
    authentication_service.access_token
  end

  # authentication_service
  #
  # Builds a service for retrieving access tokens
  # from Canvas.
  def authentication_service
    tool_proxy = tool_proxy_from_guid || tool_proxy_from_assignment
    @_authentication_service ||= IMS::LTI::Services::AuthenticationService.new(
      iss: request.base_url,
      aud: tool_proxy.authorization_url,
      sub: tool_proxy.guid,
      secret: tool_proxy.shared_secret
    )
  end

  # tool_proxy
  #
  # Returns the ToolProxy specified in the request
  def tool_proxy_from_guid
    @_tool_proxy_from_guid ||= ToolProxy.find_by(guid: params[:tool_proxy_guid])
  end

  def tool_proxy_from_assignment
    assignment&.tool_proxy
  end

  # authorization_header
  #
  # Returns the ToolProxy specified in the request
  def authorization_header
    { 'Authorization' => "Bearer #{access_token}" }
  end
end
