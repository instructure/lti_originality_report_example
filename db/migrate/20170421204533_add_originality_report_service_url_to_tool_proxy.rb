class AddOriginalityReportServiceUrlToToolProxy < ActiveRecord::Migration[5.0]
  def change
    add_column :tool_proxies, :report_service_url, :string
  end
end
