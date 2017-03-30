# Registration::ToolProxyResponse
#
# Represents the tool proxy creation response from the
# tool consumer.
module Registration
  class ToolProxyResponse
    attr_reader :tp_response, :redirect_url, :tp_parsed_response

    def initialize(tp_response, redirect_url)
      @tp_response = tp_response
      @tp_parsed_response = JSON.parse(tp_response.body)
      @redirect_url = redirect_url
    end

    # registration_success_url
    #
    # Returns the URL to redirect to upon successfuly tool
    # proxy creation.
    def registration_success_url
       "#{redirect_url}?tool_proxy_guid=#{tool_proxy_guid}&status=success"
    end

    # tool_proxy_guid
    #
    # Returns the tool proxy guid
    def tool_proxy_guid
      tp_parsed_response['tool_proxy_guid']
    end

    # tc_half_shared_secret
    #
    # Returns the tool consumer's half of the
    # shared secret
    def tc_half_shared_secret
      tp_parsed_response['tc_half_shared_secret']
    end

    # success?
    #
    # Returns true of the tool proxy was successfully created
    # in the tool consumer
    def success?
      tp_response.code == 201
    end
  end
end
