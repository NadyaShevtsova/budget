class AddPricingPlanToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :pricing_plan, index: true, foreign_key: true
  end
end
