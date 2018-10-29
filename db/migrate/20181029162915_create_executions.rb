class CreateExecutions < ActiveRecord::Migration[5.2]
  def change
    create_table :executions do |t|
      t.string :user
      t.string :command
      t.string :response_url

      t.timestamps
    end
  end
end
