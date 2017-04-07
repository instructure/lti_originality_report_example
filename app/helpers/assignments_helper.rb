module AssignmentsHelper
  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  def lti_authentication
    if shared_secret.present?
      authenticator = IMS::LTI::Services::OAuth1MessageAuthenticator.new(message, shared_secret)
      return true if authenticator.valid_signature? && not_expired?
    end
    head :unauthorized and return
  end

  def message
    message = IMS::LTI::Models::Messages::BasicLTILaunchRequest.new(request.request_parameters)
    message.launch_url = request.url
    message
  end

  def shared_secret
    tool_proxy.shared_secret
  end

  def not_expired?
    timestamp = params['oauth_timestamp'].to_i
    allowed_future_skew = 60.seconds
    timestamp.between?(5.minutes.ago.to_i, (Time.now + allowed_future_skew).to_i)
  end

  def tool_proxy
    @_tool_proxy ||= ToolProxy.find_by(guid: params['oauth_consumer_key'])
  end

  def edit_assignment?
    existing_assignment.present?
  end

  def existing_assignment
    @_existing_assignment ||= Assignment.find_by(lti_assignment_id: params['ext_lti_assignment_id'])
  end

  def find_or_create_assignment
    @_assignment ||= begin
      return existing_assignment if existing_assignment.present?
      Assignment.create(lti_assignment_id: params['ext_lti_assignment_id'],
                        tool_proxy: tool_proxy)
    end
  end
end
