# RegistrationController
#
# Handles incoming registration requests from tool
# consumers. For a more explicit example of LTI 2
# registration please see
# https://github.com/instructure/lti2_reference_tool_provider
class RegistrationController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :register
  include RegistrationHelper

  # register
  #
  # handles incoming registration requests from the
  # tool consumer, fetches a custom tool consumer profile
  # from Canvas, and registers a tool proxy
  def register
    tcp = tool_proxy_registration_service.tool_consumer_profile

    logger.debug(tcp.as_json)

    unless tcp.supports_capabilities?(*ToolProxy::REQUIRED_CAPABILITIES)
      redirect_to registration_failure_url('Missing required capabilities') and return
    end

    tool_proxy = ToolProxy.new(tcp_url: registration_request.tc_profile_url,
                               base_url: request.base_url,
                               authorization_url: authorization_service.endpoint,
                               report_service_url: originality_report_service.endpoint,
                               submission_service_url: submission_service.endpoint)

    redirect_to registration_success_url(tool_proxy.guid) and return if create_tool_proxy(tool_proxy)
    redirect_to registration_failure_url('Error received from tool consumer') and return
  end
end
