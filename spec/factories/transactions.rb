FactoryGirl.define do
  factory :transaction do
    income        { false }
    date          { Faker::Date.backward(1) }
    amount        { Faker::Number.decimal(1) }
    description   { Faker::Lorem.paragraph }
    category_name { Faker::Commerce.department(1) }
    category
  end

end
