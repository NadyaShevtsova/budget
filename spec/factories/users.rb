FactoryGirl.define do
  factory :user do
    first_name            { Faker::Name.first_name }
    last_name             { Faker::Name.last_name }
    email                 { Faker::Internet.email }
    password              { "password" }
    confirmed_at          { Time.now }
    association :pricing_plan, factory: :mini_plan
  end

end
