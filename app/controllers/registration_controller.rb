# RegistrationController
#
# Handles incoming registration requests from tool
# consumers.
class RegistrationController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :register
  include RegistrationHelper

  def register
    tcp = tool_proxy_registration_service.tool_consumer_profile
    logger.debug(tcp.as_json)

    unless tcp.supports_capabilities?(*ToolProxy::REQUIRED_CAPABILITIES)
      redirect_to registration_failure_url('Missing required capabilities') and return
    end

    tool_proxy = ToolProxy.new(tcp_url: registration_request.tc_profile_url, base_url: request.base_url)
    redirect_to registration_success_url(tool_proxy.guid) and return if create_tool_proxy(tool_proxy)
    redirect_to registration_failure_url('Error received from tool consumer') and return
  end
end
