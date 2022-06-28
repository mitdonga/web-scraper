class CreateScrapes < ActiveRecord::Migration[7.0]
  def change
    create_table :scrapes do |t|
      t.string :name
      t.datetime :scheduled_at
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :status
      t.integer :retries

      t.timestamps
    end
  end
end
