module RegistrationHelper
  def registration_request
    @_registration_request ||= begin
      reg_request = IMS::LTI::Models::Messages::RegistrationRequest.new(params)
      reg_request.launch_url = "http://www.test.com" # why am I setting this?
      reg_request
    end
  end

  def api_service
    @_api_service ||= begin
      api_service = IMS::LTI::Services::ApiService.new(iss: request.domain)
      authentication_service = IMS::LTI::Services::AuthenticationService.new(
        iss: request.base_url,
        aud: registration_request.oauth2_access_token_url,
        sub: '10000000000003',
        secret: 'BXfJR44Ng3czXFt02UZwrzMSFn1GcT8KjY6wUL0RJSVIv271eCoa4KLzwciSg4fD'
      )
      authentication_service.additional_params[:code] = params[:reg_key]
      api_service.authentication_service = authentication_service
      api_service
    end
  end

  def tool_proxy_registration_service
    @_tool_proxy_registration_service ||= begin
      api_service.tp_registration_service(registration_request: registration_request)
    end
  end

  def create_tool_proxy(tool_proxy)
    if tp_response = tool_proxy_registration_service.register_tool_proxy(tool_proxy.to_ims_tool_proxy)
      shared_secret = tp_response.tc_half_shared_secret + tool_proxy.tp_half_shared_secret
      return tool_proxy.update_attributes(guid: tp_response.tool_proxy_guid, shared_secret: shared_secret)
    end
    false
  end

  def registration_success_url(tp_guid)
    "#{registration_request.launch_presentation_return_url}?status=sucess&tool_proxy_guid=#{tp_guid}"
  end

  def registration_failure_url(message)
    "#{registration_request.launch_presentation_return_url}?status=failure&lti_errormsg=#{URI.encode(message)}"
  end
end
