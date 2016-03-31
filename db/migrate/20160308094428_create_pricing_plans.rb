class CreatePricingPlans < ActiveRecord::Migration
  def change
    create_table :pricing_plans do |t|
      t.string :name, nil: false
      t.decimal :price, precision: 11, scale: 2
      t.integer :quantity_of_categories, nil: false
      t.integer :quantity_of_transactions, nil: false

      t.timestamps null: false
    end
  end
end
