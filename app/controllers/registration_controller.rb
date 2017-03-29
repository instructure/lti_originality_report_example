class RegistrationController < ApplicationController
  include RegistrationHelper
  def register
    # Fetch the a custom tool consumer profile
    tcp = tool_consumer_profile(jwt_access_token)

    # Do failure redirect to tool consumer if missing required
    registration_failure_redirect unless supports_required_capabilities?(tcp)

    # Create a new tool proxy
    tool_proxy = ToolProxy.new(tcp_url: tcp_url,
                               base_url: request.domain)
    tp_response = register_tool_proxy(tool_proxy, tp_service_url(tcp), jwt_access_token)
  end
end
