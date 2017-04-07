class EventController < ApplicationController

  def submission
    logger.debug "received submission event: #{request.env}"
  end

end