class AddColunmToLinks < ActiveRecord::Migration[7.0]
  def change
    add_column :links, :last_scraped, :datetime
  end
end
