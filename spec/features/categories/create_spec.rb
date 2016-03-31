require 'features/acceptance_helper'

feature '#new/#create' do
  background {
    @user = create(:user)
    login(@user)
  }

  scenario 'User cannot create categories more than on his pricing plan' do
    @user.pricing_plan.quantity_of_categories.times do |c|
      create(:category, name: "Category#{c}", user_id: @user.id)
    end
    visit categories_path
    page.should have_content("You cann't create more then #{@user.pricing_plan.quantity_of_categories} categories on #{@user.pricing_plan.name.capitalize} pricing plan. Please upgrade your Pricing plan")
    page.should_not have_content("New Category")
  end
end
