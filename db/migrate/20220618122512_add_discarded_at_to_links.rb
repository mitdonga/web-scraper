class AddDiscardedAtToLinks < ActiveRecord::Migration[7.0]
  def change
    add_column :links, :discarded_at, :datetime
    add_index :links, :discarded_at
  end
end
