class CreateAlgos < ActiveRecord::Migration[7.0]
  def change
    create_table :algos do |t|
      t.string :name

      t.timestamps
    end
  end
end
