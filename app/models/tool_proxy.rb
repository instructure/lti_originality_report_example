class ToolProxy < ActiveRecord::Base
  validates :guid, :shared_secret, :tcp_url, :base_url, :tp_half_shared_secret, presence: true
  has_many :assignments
  has_many :submissions, through: :assignments

  TOOL_PROXY_FORMAT = 'application/vnd.ims.lti.v2.toolproxy+json'.freeze
  ENABLED_CAPABILITY = %w(Security.splitSecret Canvas.placements.similarityDetection).freeze
  REQUIRED_CAPABILITIES = %w(Canvas.placements.similarityDetection).freeze

  # to_json
  #
  # Returns a tool proxy as a hash
  def as_json(*)
    to_ims_tool_proxy
  end

  # tp_half_shared_secret
  #
  # Generates a 128 hexadecimal character string for the Tool Provider's
  # half of the shared secret (See section 5.6).
  def tp_half_shared_secret
    @_tp_half_shared_secret ||= SecureRandom.hex(64)
  end

  # tool_profile
  #
  # Returns a IMS::LTI::Models::ToolProxy representation of a tool proxy
  def to_ims_tool_proxy
    IMS::LTI::Models::ToolProxy.new(
      id: "instructure.com/lti_originality_report_example:#{SecureRandom.uuid}",
      lti_version: 'LTI-2p0',
      security_contract: security_contract,
      tool_consumer_profile: tcp_url,
      tool_profile: tool_profile,
      enabled_capability: ENABLED_CAPABILITY
    )
  end

  private

  # tool_profile
  #
  # Returns a tool profile for use in the tool proxy (See section 5.4).
  def tool_profile
    IMS::LTI::Models::ToolProfile.new(
      lti_version: 'LTI-2p0',
      product_instance: product_instance,
      resource_handler: resource_handlers,
      base_url_choice: [base_url_choice],
      service_offered: service_offered
    )
  end

  # security_contract
  #
  # Returns the security contract for use in the tool proxy (See section 5.6)
  def security_contract
    IMS::LTI::Models::SecurityContract.new(
      tp_half_shared_secret: tp_half_shared_secret,
      tool_service: [
        IMS::LTI::Models::RestServiceProfile.new(
          type: 'RestServiceProfile',
          service: 'vnd.Canvas.submission',
          action: %w(GET)
        ),
        IMS::LTI::Models::RestServiceProfile.new(
          type: 'RestServiceProfile',
          service: 'vnd.Canvas.OriginalityReport',
          action: %w(GET POST PUT)
        )
      ]
    )
  end

  # product_instance
  #
  # Returns to tool proxy product instance
  def product_instance
    IMS::LTI::Models::ProductInstance.new.from_json(
      guid: 'be42ae52-23fe-48f5-a783-40ecc7ef6d5c',
      product_info: product_info
    )
  end

  # product_info
  #
  # Returns the product info to be used in the tool profile (See section 5.1.2)
  def product_info
    {
      product_name: {
        default_value: 'similarity detection reference tool'
      },
      product_version: '1.0',
      description: {
        default_value: 'LTI 2.1 tool provider reference implementation'
      },
      product_family: {
        code: 'similarity detection reference tool',
        vendor: {
          code: 'Instructure.com',
          vendor_name: {
            default_value: 'Instructure'
          },
          description: {
            default_value: 'Canvas Learning Management System'
          }
        }
      }
    }
  end

  # base_url_choice
  #
  # Returns the product info to be used in the tool profile (See section 5.4.5)
  def base_url_choice
    IMS::LTI::Models::BaseUrlChoice.new(
      default_base_url: base_url,
      selector: IMS::LTI::Models::BaseUrlSelector.new(
        applies_to: ['MessageHandler']
      )
    )
  end

  def basic_message(path:, capabilities:)
    IMS::LTI::Models::MessageHandler.new(
      message_type: 'basic-lti-launch-request',
      path: path,
      enabled_capability: capabilities
    )
  end

  # service_offered
  #
  # Returns a list of services offered by the tool provider.
  def service_offered
    [
      IMS::LTI::Models::RestService.new(
        id: "#{base_url}/lti/v2/services#vnd.Canvas.SubmissionEvent",
        action: %w(POST),
        endpoint: "#{base_url}/event/submission"
      )
    ]
  end

  # resource_handlers
  #
  # Returns the resource handler to be used in the tool profile (See section 5.4.2)
  def resource_handlers
    [
      IMS::LTI::Models::ResourceHandler.from_json(
        resource_type: { code: 'sumbissions' },
        resource_name: { default_value: 'Similarity Detection Tool', key: '' },
        message: [basic_message(
          path: '/submission/index',
          capabilities: %w(Canvas.placements.accountNavigation Canvas.placements.courseNavigation)
        )]
      ),
      IMS::LTI::Models::ResourceHandler.from_json(
        resource_type: { code: 'placements' },
        resource_name: { default_value: 'Similarity Detection Tool', key: '' },
        message: [basic_message(
          path: '/assignments/configure',
          capabilities: %w(Canvas.placements.similarityDetection)
        )]
      )
    ]
  end
end
