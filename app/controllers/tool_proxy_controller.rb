class ToolProxyController < ApplicationController
  include OriginalityReportsHelper
  # obtain_guid_by_id
  #
  # Returns the guid of the tool proxy identified by the specified
  # id.
  #
  # proxy_id - The id of the proxy to be found.
  def obtain_guid_by_id
    tp = ToolProxy.find(params[:proxy_id])
  rescue ActiveRecord::RecordNotFound
    head :not_found and return
  else
    render json: tp.guid, status: :ok
  end

  # obtain_guid_by_assignment_id
  #
  # Returns the guid of the first tool proxy associated with the given
  # assignment.
  #
  #
  def obtain_guid_by_assignment_tc_id
    tp = tool_proxy_from_assignment
    head :not_found and return unless tp.present?
    render json: tp.guid, status: :ok
  end
end
