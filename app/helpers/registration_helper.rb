module RegistrationHelper
  def registration_failure_url
    "#{registration_redirect_url}?status=failure"
  end

  def registration_redirect_url
    params[:launch_presentation_return_url]
  end

  def register_tool_proxy(tool_proxy, tp_service_url, access_token)
    request = {
      body: tool_proxy.to_json,
      headers: {
        'Content-Type' => 'application/vnd.ims.lti.v2.toolproxy+json',
        'Authorization' => "Bearer #{access_token}"
      }
    }
    HTTParty.post(tp_service_url, request)
  end

  def jwt_access_token
    @_jwt_access_token ||= begin
      get_jwt_access_token(
        url: params[:oauth2_access_token_url],
        sub: '10000000000003', # Developer key global id
        secret: 'BXfJR44Ng3czXFt02UZwrzMSFn1GcT8KjY6wUL0RJSVIv271eCoa4KLzwciSg4fD', # Developer key api key. Don't store this here ;)
        code: params[:reg_key])
    end
  end

  def get_jwt_access_token(url:, sub:, secret:, code: nil)
    assertion = JSON::JWT.new({
      sub: sub,
      aud: url,
      exp: 1.minute.from_now,
      iat: Time.now.to_i,
      jti: SecureRandom.uuid
    })
    assertion = assertion.sign(secret, :HS256).to_s

    request = {
      body: {
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: assertion
      }
    }

    # If using a developer key as the subject
    if code.present?
      request = {
        body: {
          grant_type: 'authorization_code',
          code: code,
          assertion: assertion
        }
      }
    end

    response = HTTParty.post(url, request)
    response.parsed_response['access_token']
  end
end
