class EventController < ApplicationController

  def submission
    logger.debug "received submission event: #{request.env}"
    render status: 200
  end

end