class ToolProxyController < ApplicationController
  include OriginalityReportsHelper
  # obtain_guid_by_id
  #
  # Returns the guid of the tool proxy identified by the specified
  # id.
  #
  # proxy_id - The id of the proxy to be found.
  def show_guid_by_id
    tp = ToolProxy.where(id: params[:proxy_id]).first
    head :not_found and return unless tp.present?
    render json: tp.guid, status: :ok
  end

  # obtain_guid_by_assignment_id
  #
  # Returns the guid of the first tool proxy associated with the given
  # assignment.
  #
  #
  def show_guid_by_assignment_tc_id
    tp = tool_proxy_from_assignment
    head :not_found and return unless tp.present?
    render json: tp.guid, status: :ok
  end
end
