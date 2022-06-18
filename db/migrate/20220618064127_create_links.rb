class CreateLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :links do |t|
      t.string :name
      t.string :url
      t.integer :s_id
      t.references :city, null: false, foreign_key: true
      t.references :algo, null: false, foreign_key: true

      t.timestamps
    end
  end
end
