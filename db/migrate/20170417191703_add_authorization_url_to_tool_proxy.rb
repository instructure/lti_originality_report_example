class AddAuthorizationUrlToToolProxy < ActiveRecord::Migration[5.0]
  def change
    add_column :tool_proxies, :authorization_url, :string
  end
end
