class ToolProxy < ActiveRecord::Base
  validates :guid, :shared_secret, :tcp_url, :base_url, :tp_half_shared_secret, presence: true

  TOOL_PROXY_FORMAT = 'application/vnd.ims.lti.v2.toolproxy+json'.freeze
  ENABLED_CAPABILITY = %w(Security.splitSecret).freeze
  REQUIRED_CAPABILITIES = %w(Canvas.placements.similarityDetection).freeze

  # to_json
  #
  # Returns a tool proxy as JSON ready to be sent in the
  # tool proxy post request to the tool provider (See section 6.1.3)
  def to_json
    as_json.to_json
  end

  # to_json
  #
  # Returns a tool proxy as a hash
  def as_json
    tool_proxy_hash = super()
    tool_proxy_hash.merge(
      '@context' => 'http://purl.imsglobal.org/ctx/lti/v2/ToolProxy',
      lti_version: 'LTI-2p0', # LTI-2p0 should be used for all LTI 2.x tools
      tool_consumer_profile: tcp_url,
      tool_profile: tool_profile,
      security_contract: security_contract,
      enabled_capability: ENABLED_CAPABILITY # (Section 5.3)
    )
  end

  # tp_half_shared_secret
  #
  # Generates a 128 hexadecimal character string for the Tool Provider's
  # half of the shared secret (See section 5.6).
  def tp_half_shared_secret
    @_tp_half_shared_secret ||= SecureRandom.hex(64)
  end

  private

  # tool_profile
  #
  # Returns a tool profile for use in the tool proxy (See section 5.4).
  def tool_profile
    {
      'lti_version' => 'LTI-2p0',
      'product_instance' => {
        'guid' => 'be42ae52-23fe-48f5-a783-40ecc7ef6d5c',
        'product_info' => product_info
      },
      'base_url_choice' => base_url_choice,
      'resource_handler' => resource_handler,
      'services_offered' => services_offered
    }
  end

  # security_contract
  #
  # Returns the security contract for use in the tool proxy (See section 5.6)
  # TODO include the originality report service
  def security_contract
    {
      tp_half_shared_secret: tp_half_shared_secret,
      tool_service: [{
        '@type' => 'RestServiceProfile',
        'service' => 'vnd.Canvas.webhooksSubscription',
        'action' => ['POST', 'GET', 'PUT', 'DELETE']
      }]
    }
  end

  # product_info
  #
  # Returns the product info to be used in the tool profile (See section 5.1.2)
  def product_info
    {
      'product_name' => {
        'default_value' => 'similarity detection reference tool'
      },
      'product_version' => '1.0',
      'description' => {
        'default_value' => 'LTI 2.1 tool provider reference implementation'
      },
      'product_family' => {
        'code' => 'similarity detection reference tool',
        'vendor' => {
          'code' => 'Instructure.com',
          'vendor_name' => {
            'default_value' => 'Instructure'
          },
          'description' => {
            'default_value' => 'Canvas Learning Management System'
          }
        }
      }
    }
  end

  # base_url_choice
  #
  # Returns the product info to be used in the tool profile (See section 5.4.5)
  def base_url_choice
    [{
      'default_base_url' => base_url,
      'selector' => {
        'applies_to' => ['MessageHandler']
      }
    }]
  end

  # services_offered
  #
  # Returns a list of services offered by the tool provider.
  def services_offered
    [{
        "id": "http://sdrt.Instructure.com#vnd.Canvas.SubmissionEvent",
        "action": ["POST"],
        "endpoint": "http://www.sdrt.com/handler"
    }]
  end

  # resource_handler
  #
  # Returns the resource handler to be used in the tool profile (See section 5.4.2)
  def resource_handler
    [{
      'resource_type' => {
        'code' => 'similarity detection reference tool'
      },
      'resource_name' => {
        'default_value' => 'similarity detection reference tool'
      },
      'message' => [{
        'message_type' => 'basic-lti-launch-request',
        'path' => '/assignment-configuration',
        'enabled_capability' => ["Canvas.placements.similarityDetection"]
      }]
    }]
  end
end
