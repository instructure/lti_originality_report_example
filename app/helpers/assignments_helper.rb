module AssignmentsHelper
  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  def lti_authentication
    if shared_secret.present?
      authenticator = IMS::LTI::Services::MessageAuthenticator.new(request.url, request.request_parameters, shared_secret)
      return true if authenticator.valid_signature? && not_expired?
    end
    head :unauthorized and return
  end

  def shared_secret
    @_shared_secret ||= ToolProxy.find_by(guid: params['oauth_consumer_key']).shared_secret
  end

  def not_expired?
    timestamp = params['oauth_timestamp'].to_i
    allowed_future_skew = 60.seconds
    timestamp.between?(5.minutes.ago.to_i, (Time.now + allowed_future_skew).to_i)
  end
end
