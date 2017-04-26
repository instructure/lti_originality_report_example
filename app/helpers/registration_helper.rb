module RegistrationHelper
  def tool_consumer_profile
    @_tool_consumer_profile ||= tool_proxy_registration_service.tool_consumer_profile
  end

  def registration_request
    @_registration_request ||= begin
      reg_request = IMS::LTI::Models::Messages::RegistrationRequest.new(request.request_parameters)
      reg_request.launch_url = request.url
      reg_request
    end
  end

  def registration_services
    @_registration_services ||= begin
      registration_services = IMS::LTI::Services::RegistrationServices.new(
        iss: request.domain,
        message: registration_request,
        consumer_secret: Rails.configuration.canvas_creds['developer_secret'],
        consumer_key: Rails.configuration.canvas_creds['developer_key']
      )
      registration_services.authentication_service.additional_params[:code] = params[:reg_key]
      registration_services
    end
  end

  def tool_proxy_registration_service
    @_tool_proxy_registration_service ||= begin
      registration_services.registration_service
    end
  end

  def create_tool_proxy(tool_proxy)
    tp_response = tool_proxy_registration_service.register_tool_proxy(tool_proxy.to_ims_tool_proxy)
    if tp_response
      shared_secret = tp_response.tc_half_shared_secret + tool_proxy.tp_half_shared_secret
      return tool_proxy.update_attributes(guid: tp_response.tool_proxy_guid, shared_secret: shared_secret)
    end
    false
  end

  def authorization_service
    find_service('#vnd.Canvas.authorization')
  end

  def originality_report_service
    find_service('#vnd.Canvas.OriginalityReport')
  end

  def submission_service
    find_service('#vnd.Canvas.submission')
  end

  def find_service(service_id)
    tool_consumer_profile.services_offered.find { |s| s.id.end_with? service_id }
  end

  def registration_success_url(tp_guid)
    "#{registration_request.launch_presentation_return_url}?status=success&tool_proxy_guid=#{tp_guid}"
  end

  def registration_failure_url(message)
    "#{registration_request.launch_presentation_return_url}?status=failure&lti_errormsg=#{URI.encode(message)}"
  end
end
