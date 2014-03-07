class CreateCartItems < ActiveRecord::Migration
  def change
    create_table :cart_items do |t|
      t.string :itemType
      t.string :guid
      t.references :cart, index: true

      t.timestamps
    end
  end
end
