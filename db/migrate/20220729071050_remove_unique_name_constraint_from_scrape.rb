class RemoveUniqueNameConstraintFromScrape < ActiveRecord::Migration[7.0]
  def change
    remove_index :scrapes, :name, unique: true
  end
end
