class CreateAssignments < ActiveRecord::Migration[5.0]
  def change
    create_table :assignments do |t|
      t.string :lti_assignment_id, null: false
      t.integer :tool_proxy_id, null: false
      t.timestamps
    end

    add_foreign_key :assignments, :tool_proxies, column: :tool_proxy_id
    add_index :assignments, [:tool_proxy_id]
    add_index :assignments, [:lti_assignment_id]
  end
end
