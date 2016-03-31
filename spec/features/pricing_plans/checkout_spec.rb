require 'features/acceptance_helper'

feature '#Pricing plans page:' do
  describe "payment with stripe" do
    given(:stripe_helper) { StripeMock.create_test_helper }
    background {
      @user = create(:user)
      login(@user)
      @standard_plan = create(:standard_plan)
      create(:plus_plan)
      create(:premium_plan)
      StripeMock.start
      Stripe.api_key = Figaro.env.stripe_api_key
    }
    after :each do
      StripeMock.stop
    end

    scenario 'user should pay and ugrade pricing_plan successfully ', js: true do
      visit '/pricing_plans'
      expect(page).to have_content 'Pick your plan'
      find('.standard').first(:link, "Buy now").click
      expect(page).to have_content "Pricing plan #{@standard_plan.name.capitalize}"
      expect(page).to have_content "Select payment method"
      find('#stripe_form').first(:button).click
      sleep 1

      Capybara.within_frame 'stripe_checkout_app' do
        4.times {find('#card_number').send_keys('4242')}

        page.driver.browser.find_element(:id, 'cc-exp').send_keys '5'
        page.driver.browser.find_element(:id, 'cc-exp').send_keys '20'

        page.driver.browser.find_element(:id, 'cc-csc').send_keys '123'
        find('button[type="submit"]').click
        sleep 3
      end
      expect(page).to have_content "You Pricing plan was successfully upgrated. Congrates with #{ @standard_plan.name.capitalize } pricing plan!"
    end

    scenario 'user should pay and ugrade pricing_plan successfully via another design', js: true do
      visit '/pricing_plans'
      expect(page).to have_content 'Pick your plan'
      find('.another-design').click
      find('.another-standard').first(:link, "Buy now").click
      expect(page).to have_content "Pricing plan #{@standard_plan.name.capitalize}"
      expect(page).to have_content "Select payment method"
      find('#stripe_form').first(:button).click

      Capybara.within_frame 'stripe_checkout_app' do
        4.times {find('#card_number').send_keys('4242')}

        page.driver.browser.find_element(:id, 'cc-exp').send_keys '5'
        page.driver.browser.find_element(:id, 'cc-exp').send_keys '20'

        page.driver.browser.find_element(:id, 'cc-csc').send_keys '123'
        find('button[type="submit"]').click
        sleep 3
      end
      expect(page).to have_content "You Pricing plan was successfully upgrated. Congrates with #{ @standard_plan.name.capitalize } pricing plan!"
    end
  end

  describe "successfully downgrade " do
    background {
      standard_plan = create(:standard_plan)
      create(:plus_plan)
      create(:mini_plan)
      create(:premium_plan)
      @user = create(:user, pricing_plan: standard_plan)
      login(@user)
    }

    scenario 'user should downgrade pricing_plan successfully' do
      visit '/pricing_plans'
      expect(page).to have_content 'Pick your plan'
      find('.mini').first(:link, "Downgrade").click

      expect(page).to have_content "You Pricing plan was successfully downgrated to Mini pricing plan!"
    end
  end
end
