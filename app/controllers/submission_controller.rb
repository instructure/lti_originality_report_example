class SubmissionController < ApplicationController
  include LtiHelper
  skip_before_filter :verify_authenticity_token, only: :index
  after_action :allow_iframe, only: :index
  before_action :lti_authentication, only: :index

  def index
    @submissions = tool_proxy.submissions
  end
end
