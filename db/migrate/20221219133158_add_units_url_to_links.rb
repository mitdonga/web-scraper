class AddUnitsUrlToLinks < ActiveRecord::Migration[7.0]
  def change
    add_column :links, :units_url, :string
    add_column :links, :success, :boolean
    add_column :links, :notes, :string
  end
end
