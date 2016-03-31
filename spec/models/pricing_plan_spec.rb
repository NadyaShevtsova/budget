require 'rails_helper'

describe PricingPlan do
  it { should have_many(:users) }

  context 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:price) }
    it { should validate_presence_of(:quantity_of_categories) }
    it { should validate_presence_of(:quantity_of_transactions) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0.0) }
    it { should validate_numericality_of(:quantity_of_categories).is_greater_than(0) }
    it { should validate_numericality_of(:quantity_of_transactions).is_greater_than(0) }
    it { should validate_length_of(:name).is_at_most(255) }
  end

 context '#Methods' do
   context '#method_missing' do
     let(:user) {create(:user)}

     it "should set defualt plan for user" do
       user.pricing_plan.mini?.should be true
     end

     it "should raise error" do
       expect {user.pricing_plan.plus?}.to raise_error { |error| expect(error).to be_a(NameError)}
     end

     it "should_not raise error" do
       pricing_plan = create(:standard_plan)
       user = create(:user, pricing_plan: pricing_plan)
       expect {user.pricing_plan.standard?}.not_to raise_error
       user.pricing_plan.standard?.should be true
     end
   end
 end
end
