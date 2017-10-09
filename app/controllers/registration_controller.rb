# RegistrationController
#
# Handles incoming registration requests from tool
# consumers. For a more explicit example of LTI 2
# registration please see
# https://github.com/instructure/lti2_reference_tool_provider
class RegistrationController < ApplicationController
  include RegistrationHelper
  include LtiHelper

  skip_before_action :verify_authenticity_token, only: :register
  before_action :allow_iframe

  # register
  #
  # handles incoming registration requests from the
  # tool consumer, fetches a custom tool consumer profile
  # from Canvas, and registers a tool proxy
  def register
    tcp = tool_proxy_registration_service.tool_consumer_profile
    unless tcp.supports_capabilities?(*ToolProxy::REQUIRED_CAPABILITIES)
      redirect_to registration_failure_url('Missing required capabilities') and return
    end

    tool_proxy = ToolProxy.new(tcp_url: registration_request.tc_profile_url,
                               base_url: request.base_url,
                               authorization_url: authorization_service.endpoint,
                               report_service_url: originality_report_service.endpoint,
                               submission_service_url: submission_service.endpoint)
    redirect_to registration_failure_url('Error received from tool consumer') unless create_tool_proxy(tool_proxy)
    @success_url = registration_success_url(tool_proxy.guid)
  rescue IMS::LTI::Errors::AuthenticationFailedError => e
    logger.debug("---- registration errors ----\n")
    logger.debug(e.assertion)
    logger.debug(e.grant_type)
    logger.debug("-----------------------------\n")
    raise e
  end

  def tool_product_profile
    raw_profile = JSON::JWT.new(
      sub: ENV['CANVAS_DEV_KEY'],
      'com.instructure.canvas' => { registration_url: registration_url }
    )
    @product_profile = raw_profile.sign(ENV['CANVAS_DEV_SECRET'], :HS256).to_s
  end
end
