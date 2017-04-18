# frozen_string_literal: true

module LtiAuthorizationHelper
  # access_token
  #
  # Returns an access token used for making calls
  # to LTI 2 endpoints in Canvas.
  def access_token
    authentication_service.access_token
  end

  # authentication_service
  #
  # Builds a service for retrieving access tokens
  # from Canvas.
  def authentication_service
    @_authentication_service ||= IMS::LTI::Services::AuthenticationService.new(
      iss: request.base_url,
      aud: tool_proxy_from_params.authorization_url,
      sub: tool_proxy_from_params.guid,
      secret: tool_proxy_from_params.shared_secret
    )
  end

  # tool_proxy
  #
  # Returns the ToolProxy specified in the request
  def tool_proxy_from_params
    @_tool_proxy_from_params ||= ToolProxy.find_by(guid: params[:tool_proxy_guid])
  end
end
