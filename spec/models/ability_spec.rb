require 'rails_helper'
describe Ability do
  subject(:ability){ Ability.new(user) }
  let(:user){ create(:user) }

  context "with pricing plan" do
    context "for categories:" do
      it { should be_able_to(:create, Category) }

      it "should not be able to create Category" do
        user.pricing_plan.quantity_of_categories.times do |t|
          create(:category, name: "Category#{t}", user_id: user.id)
        end
        should_not be_able_to(:create, Category)
      end
    end

    context "for transactions:" do
      it { should be_able_to(:create, Transaction) }

      it "should not be able to create Transaction" do
        user.pricing_plan.quantity_of_transactions.times do |t|
          create(:transaction, category_name: "Food", user_id: user.id)
        end
        should_not be_able_to(:create, Transaction)
      end
    end
  end
end
