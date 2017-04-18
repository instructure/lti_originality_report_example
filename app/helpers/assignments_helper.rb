module AssignmentsHelper
  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  # lti_authentication
  #
  # Verifies that the signature of the incoming request is valid and that
  # the request is not expired.
  def lti_authentication
    if shared_secret.present?
      authenticator = IMS::LTI::Services::OAuth1MessageAuthenticator.new(message, shared_secret)
      return true if authenticator.valid_signature? && not_expired?
    end
    head :unauthorized and return
  end

  # messsage
  #
  # Returns the incoming basic lti launch request model
  def message
    message = IMS::LTI::Models::Messages::BasicLTILaunchRequest.new(request.request_parameters)
    message.launch_url = request.url
    message
  end

  # shared_secret
  #
  # Returns the shared secret of the tool proxy
  def shared_secret
    tool_proxy.shared_secret
  end

  # not_expired?
  #
  # Returns true if the request is not expired
  def not_expired?
    timestamp = params['oauth_timestamp'].to_i
    allowed_future_skew = 60.seconds
    timestamp.between?(5.minutes.ago.to_i, (Time.now + allowed_future_skew).to_i)
  end

  # tool_proxy
  #
  # Returns the tool proxy associated with the incoming basic lti launch
  # request
  def tool_proxy
    @_tool_proxy ||= ToolProxy.find_by(guid: params['oauth_consumer_key'])
  end

  # existing_assignment
  #
  # Attempts to find and return an assignment that already has been
  # configured and saved
  def existing_assignment
    @_existing_assignment ||= Assignment.find_by(lti_assignment_id: params['ext_lti_assignment_id'])
  end

  # edit_assignment?
  #
  # Returns true if the assignment being configured has already been configured
  # and saved previously
  def edit_assignment?
    existing_assignment.present?
  end

  # find_or_create_assignment
  #
  # Attempts to find and return an assignment that was previously configured
  # and returns a new assignment if none is found
  def find_or_create_assignment
    @_assignment ||= begin
      return existing_assignment if existing_assignment.present?
      Assignment.create!(lti_assignment_id: params['ext_lti_assignment_id'],
                         tool_proxy: tool_proxy)
    end
  end
end
