FactoryGirl.define do
  factory :mini_plan, class: PricingPlan do
    name                     "mini"
    price                    0.0
    quantity_of_categories   5
    quantity_of_transactions 30
  end

  factory :standard_plan, class: PricingPlan do
    name                     "standard"
    price                    20.0
    quantity_of_categories   10
    quantity_of_transactions 500
  end

  factory :plus_plan, class: PricingPlan do
    name                     "plus"
    price                    30.0
    quantity_of_categories   100
    quantity_of_transactions 1000
  end

  factory :premium_plan, class: PricingPlan do
    name                     "premium"
    price                    35.0
    quantity_of_categories   1000000
    quantity_of_transactions 1000000
  end
end
