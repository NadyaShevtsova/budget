[ FactoryGirl.attributes_for(:mini_plan),
  FactoryGirl.attributes_for(:standard_plan),
  FactoryGirl.attributes_for(:plus_plan),
  FactoryGirl.attributes_for(:premium_plan)].each do |attributes|

  pricing_plan = PricingPlan.where(attributes).first_or_create
  puts "Error creating pricing plan #{pricing_plan.name}: #{pricing_plan.errors.full_messages.join(", ")}" if pricing_plan.new_record?
end
User.find_each { |u| u.update_attribute(:pricing_plan, PricingPlan.first) if u.pricing_plan.blank? }

