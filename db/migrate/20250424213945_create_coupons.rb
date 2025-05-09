class CreateCoupons < ActiveRecord::Migration[7.0]
  def change
    create_table :coupons do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :discount_type, null: false
      t.decimal :discount_amount, precision: 10, scale: 2, null: false
      t.string :status, default: 'active'
      t.references :merchant, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :coupons, :code, unique: true
  end
end