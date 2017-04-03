class AddSettingsToAssignment < ActiveRecord::Migration[5.0]
  def change
    add_column :assignments, :settings, :hstore
  end
end
