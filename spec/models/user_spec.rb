require 'rails_helper'

def tw_auth
  return @auth_twitter if @auth_twitter
  @auth_twitter = eval File.read("#{Rails.root}/spec/fixtures/auth_twitter.yml")
end

def fb_auth
  return @auth_facebook if @auth_facebook
  @auth_facebook = eval File.read("#{Rails.root}/spec/fixtures/auth_facebook.yml")
end

describe User do
  it { should have_many(:authorizations).dependent(:destroy) }
  it { should have_many(:categories).dependent(:destroy) }
  it { should have_many(:transactions).through(:categories) }
  it { should have_one(:photo).dependent(:destroy) }
  it { should belong_to(:pricing_plan) }
  it { should accept_nested_attributes_for(:photo).allow_destroy(true) }

 context 'Validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_length_of(:first_name).is_at_most(255) }
    it { should validate_length_of(:last_name).is_at_most(255) }
  end

 context '#Methods' do
    context '#from_omniauth' do
      before { create(:mini_plan) }
      context '#login via Twitter without current_user' do
        before { User.from_omniauth( set_omniauth( tw_auth ) ) }

        it 'should create user' do
          expect(User.count).to eq(1)
          expect(Authorization.count).to eq(1)
          expect(Authorization.first.provider).to eq("twitter")
          expect(Authorization.first.uid).to eq(@auth_twitter[:uid])
        end

        it 'should not create existent user' do
          expect{User.from_omniauth( set_omniauth( tw_auth ) )}.to_not change(User, :count)
          expect{User.from_omniauth( set_omniauth( tw_auth ) )}.to_not change(Authorization, :count)
        end
      end

      context '#login via Facebook without current_user' do
        before { User.from_omniauth( set_omniauth( fb_auth ) ) }

        it 'should create user' do
          expect(User.count).to eq(1)
          expect(Authorization.count).to eq(1)
          expect(Authorization.first.provider).to eq("facebook")
          expect(Authorization.first.uid).to eq(@auth_facebook[:uid])
        end

        it 'should not create existent user' do
          expect{User.from_omniauth( set_omniauth( fb_auth ) )}.to_not change(User, :count)
          expect{User.from_omniauth( set_omniauth( fb_auth ) )}.to_not change(Authorization, :count)
          expect("#{User.first.first_name} #{User.first.last_name}").to eq( @auth_facebook[:extra][:raw_info][:name] )
        end
      end

      context 'form Devise' do
        it 'should create new user' do
          current_user = create(:user)
          expect(User.count).to eq(1)
          expect(User.first.first_name).to eq( current_user.first_name )
        end
      end

      context '#login via Facebook with current_user' do
        before{ @current_user = create(:user) }

        it 'should create one more user' do
          expect{User.from_omniauth( set_omniauth( fb_auth ) )}.to change(User, :count)
        end

        it 'should not create existent user' do
          expect{User.from_omniauth( set_omniauth( fb_auth, { info: { email: @current_user.email }} ) )}.to_not change(User, :count)
          expect(User.first.first_name).to eq( @current_user.first_name )
        end
      end

      context '#login via Twitter with current_user' do
        before{ @current_user = create(:user) }

        it 'should create one more user' do
          expect{User.from_omniauth( set_omniauth( tw_auth ) )}.to change(User, :count)
        end

        it 'should not create existent user' do
          expect{User.from_omniauth( set_omniauth( tw_auth, { info: { email: @current_user.email }} ) )}.to_not change(User, :count)
          expect(User.first.first_name).to eq( @current_user.first_name )
        end
      end
    end

    context "#set_default_pricing_plan" do
      it "should set pricing_plan Free" do
        expect(create(:user).pricing_plan).to eq(PricingPlan.first)
      end

      it "should not update pricing_plan" do
        user = create(:user)
        user.update_attributes(pricing_plan: PricingPlan.last)
        user.pricing_plan.should eq( PricingPlan.last )
      end

    end

    context "Stripe" do
      let(:stripe_helper) { StripeMock.create_test_helper }
      before {
        @current_user = create(:user)
        StripeMock.start
        Stripe.api_key = Figaro.env.stripe_api_key.to_s
      }
      after { StripeMock.stop }

      context "#create_stripe_customer" do
        it "should add stripe_id to user" do
          expect{@current_user.create_stripe_customer(stripe_helper.generate_card_token)}.to change(@current_user, :stripe_id)
        end
      end

      context "#pay_via_stripe!" do
        it "should pay successfully" do
          standard_plan = create(:standard_plan)
          expect { @current_user.pay_via_stripe!(standard_plan)}.to change(@current_user, :pricing_plan_id)
        end

        it "should return declined card error" do
          standard_plan = create(:standard_plan)
          StripeMock.prepare_card_error(:card_declined)
          expect { @current_user.pay_via_stripe!(standard_plan) }.to raise_error {|e|
            expect(e).to be_a Stripe::CardError
            expect(e.http_status).to eq(402)
            expect(e.code).to eq('card_declined')
          }
        end
      end
    end

    context "#set_pricing_plan" do
      before { create(:mini_plan) }

      it "should downgrade pricing plan to default" do
        standard_plan = create(:standard_plan)
        plus_plan = create(:plus_plan)
        premium_plan = create(:premium_plan)
        user = create(:user, pricing_plan: premium_plan)
        expect { user.send(:set_pricing_plan, plus_plan.id) }.to change(user, :pricing_plan_id).to plus_plan.id
        expect { user.send(:set_pricing_plan, standard_plan.id) }.to change(user, :pricing_plan_id).to standard_plan.id
        expect { user.send(:set_pricing_plan, PricingPlan.defaul_plan.id) }.to change(user, :pricing_plan_id).to PricingPlan.defaul_plan.id
      end

      it "should set defaul_plan to new user" do
        user = build(:user, pricing_plan_id: nil)
        user.should be_valid
        expect{ user.save }.to change(user, :pricing_plan_id).to PricingPlan.defaul_plan.id
      end

      it "should not change pricing plan if pricing plan exist for new user" do
        pricing_plan = create(:standard_plan)
        user = build(:user, pricing_plan: pricing_plan)
        user.should be_valid
        expect{ user.save }.not_to change(user, :pricing_plan_id)
      end

      it "should not change pricing plan for existent user" do
        pricing_plan = create(:standard_plan)
        user = create(:user, pricing_plan: pricing_plan)
        expect { user.send(:set_pricing_plan) }.not_to change(user, :pricing_plan_id)
      end
    end
  end
end
