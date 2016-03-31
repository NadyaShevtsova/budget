require 'rails_helper'

describe Transaction do
  it { should belong_to(:category) }

  context 'Validations' do
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:category_name) }
    it { should validate_length_of(:description).is_at_most(65536) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should allow_value( Date.today ).for(:date) }
    it { should validate_timeliness_of :date }
  end

 context '#Scopes' do
  context "#this_month" do
    before { @user = create(:user)
             @transaction1 = create(:transaction, user_id: @user.id)
             @transaction2 = create(:transaction, user_id: @user.id, date: Date.today.beginning_of_month)
             create(:transaction, user_id: @user.id, date: (Date.today - 1.month))
    }
    it "should return transactions created only for this month" do
      @user.transactions.count.should eq(3)
      @user.transactions.this_month.should eq([@transaction1, @transaction2])
    end
  end
 end
end
