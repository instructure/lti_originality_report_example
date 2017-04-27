module RegistrationHelper
  # tool_consumer_profile
  #
  # Returns the tool consumer profile
  def tool_consumer_profile
    @_tool_consumer_profile ||= tool_proxy_registration_service.tool_consumer_profile
  end

  # registration_request
  #
  # Returns a model representing the incoming registration
  # request
  def registration_request
    @_registration_request ||= begin
      reg_request = IMS::LTI::Models::Messages::RegistrationRequest.new(request.request_parameters)
      reg_request.launch_url = request.url
      reg_request
    end
  end

  # registration_services
  #
  # Returns a registration service object to aid
  # in the registration process
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

  # tool_proxy_registration_service
  #
  # Returns the registration service to aid in
  # registering a tool proxy with Canvas
  def tool_proxy_registration_service
    @_tool_proxy_registration_service ||= begin
      registration_services.registration_service
    end
  end

  # create_tool_proxy
  #
  # Attempts to create the tool proxy in Canvas.
  # If successful the tool consumer's half of the shared
  # secret is prepended to the tool provider's half and
  # saved.
  #
  # The tool proxy guid is also retrieved from the response
  # and saved.
  def create_tool_proxy(tool_proxy)
    tp_response = tool_proxy_registration_service.register_tool_proxy(tool_proxy.to_ims_tool_proxy)
    if tp_response
      shared_secret = tp_response.tc_half_shared_secret + tool_proxy.tp_half_shared_secret
      return tool_proxy.update_attributes(guid: tp_response.tool_proxy_guid, shared_secret: shared_secret)
    end
    false
  end

  # authorization_service
  #
  # Returns the service used to retrieve access
  # tokens from Canvas
  def authorization_service
    find_service('#vnd.Canvas.authorization')
  end

  # originality_report_service
  #
  # Returns the service used to CRUD
  # originality reports in Canvas
  def originality_report_service
    find_service('#vnd.Canvas.OriginalityReport')
  end

  # submission_service
  #
  # returns the service used to CRUD
  # submissions in Canvas
  def submission_service
    find_service('#vnd.Canvas.submission')
  end

  # find_service
  #
  # searches the tool consumer profile's
  # "service_offered" for a service with an id
  # that ends in the specified string
  def find_service(service_id)
    tool_consumer_profile.services_offered.find { |s| s.id.end_with? service_id }
  end

  # registration_success_url
  #
  # returns the url to redirect to if registering
  # the tool proxy is successful
  def registration_success_url(tp_guid)
    "#{registration_request.launch_presentation_return_url}?status=success&tool_proxy_guid=#{tp_guid}"
  end

  # registration_failure_url
  #
  # returns the url to redirect to if registering the
  # tool proxy fails
  def registration_failure_url(message)
    "#{registration_request.launch_presentation_return_url}?status=failure&lti_errormsg=#{URI.encode(message)}"
  end
end
