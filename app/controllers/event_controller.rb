class EventController < ApplicationController
  skip_before_action :verify_authenticity_token

  def submission
    logger.debug "received submission event: #{request.env}"
    render status: 200
  end

end