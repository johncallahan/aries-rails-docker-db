class CreateIdentifiers < ActiveRecord::Migration[5.2]
  def change
    create_table :identifiers do |t|
      t.string :did
      t.string :verkey

      t.timestamps
    end
  end
end
