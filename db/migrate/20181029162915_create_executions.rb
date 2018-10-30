class CreateExecutions < ActiveRecord::Migration[5.2]
  def change
    create_table :executions do |t|
      t.integer :user_id, null: false
      t.string :user_name
      t.string :command, null: false
      t.string :response_url, null: false

      t.timestamps
    end
  end
end
