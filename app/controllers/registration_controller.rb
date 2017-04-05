# RegistrationController
#
# Handles incoming registration requests from tool
# consumers.
class RegistrationController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :register
  include RegistrationHelper

  def register
    # Fetch the a custom tool consumer profile
    tcp_helper = ToolConsumerProfile.new(URI.parse(params[:tc_profile_url]), jwt_access_token)

    # Do failure redirect to tool consumer if missing required
    redirect_to registration_failure_url('Missing required capabilities') and return unless tcp_helper.supports_required_capabilities?

    # Create a new tool proxy
    tool_proxy = ToolProxy.new(tcp_url: tcp_helper.tcp_url, base_url: request.base_url)
    tp_response = register_tool_proxy(tool_proxy, tcp_helper.tp_service_url, jwt_access_token)
    tp_response_helper = ToolProxyResponse.new(tp_response, registration_redirect_url)

    # Persist tool proxy and redirect if no errors
    if tp_response_helper.success?
      shared_secret = tp_response_helper.tc_half_shared_secret + tool_proxy.tp_half_shared_secret
      tool_proxy.update_attributes(guid: tp_response_helper.tool_proxy_guid, shared_secret: shared_secret)
      redirect_to tp_response_helper.registration_success_url
    else
      redirect_to registration_failure_url('Error received from tool consumer')
    end
  end
end
