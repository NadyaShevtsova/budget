class User < ActiveRecord::Base
  TEMP_EMAIL_PREFIX = 'change@me'

  has_many :authorizations, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :transactions, through: :categories
  has_one  :photo, as: :imageable, dependent: :destroy
  belongs_to :pricing_plan

  validates :first_name, :last_name, presence: true, length: { maximum: 255 }
  validates :pricing_plan, presence: true, on: :update
  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }, allow_blank: true

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  accepts_nested_attributes_for :photo, allow_destroy: true, reject_if: ->(attr){ attr['file'].blank? and attr['remote_file_url'].blank? }
  after_create :set_pricing_plan

  def self.from_omniauth auth, current_user = nil
    authorization = Authorization.from_omniauth auth
    user = current_user || User.where(({ email: [auth.info.email, self.temp_email(auth.uid, auth.provider)]})).first

    if authorization.user.blank?

      if user.nil?
        user = User.new(
          first_name: auth.extra.raw_info.name.split(/ /).first,
          last_name: auth.extra.raw_info.name.split(/ /).last,
          email:  auth.info.email || self.temp_email(auth.uid, auth.provider),
          password: Devise.friendly_token[0,20]
        )
        user.skip_confirmation!
        user.save!
      end
    end

    if authorization.user != user
      authorization.user = user
      authorization.save!
    end
    authorization.user
  end

  def self.temp_email( uid, provider )
    "#{TEMP_EMAIL_PREFIX}-#{uid}-#{provider}.com"
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def create_stripe_customer stripe_token
    Stripe.api_key = Figaro.env.stripe_api_key

    customer = Stripe::Customer.create email: email, card: stripe_token
    update_column :stripe_id, customer.id
  end

  def pay_via_stripe!(pricing_plan)
    Stripe.api_key = Figaro.env.stripe_api_key
    Stripe::Charge.create(
      amount:      (pricing_plan.price * 100).to_i,
      description: "SaveBudget: for pricing plan #{ pricing_plan.name }",
      currency:    Figaro.env.currency_code.downcase,
      customer:    self.stripe_id
    )
    update_pricing_plan pricing_plan.id
  end

  def pay_via_paypal!( params )
    pricing_plan = PricingPlan.find(params[:id])
    response = EXPRESS_GATEWAY.purchase(
      (pricing_plan.price * 100).to_i,
      { ip: params[:ip], token: params[:token], payer_id: params[:PayerID] })

    if response.success?
      update_pricing_plan pricing_plan.id
      { :success => true }
    else
      { :message => response.params["message"], id: pricing_plan.id }
    end
  end

  def can_downgrade?(plan_id)
    self.pricing_plan.price > PricingPlan.find(plan_id).price
  end

  private
  def set_pricing_plan( pricing_plan_id = nil )
    if pricing_plan_id
      update_column :pricing_plan_id, pricing_plan_id
    elsif !self.pricing_plan
      update_column :pricing_plan_id, PricingPlan.defaul_plan.id
    end
  end

  def update_pricing_plan plan_id
    update_column :pricing_plan_id, plan_id
  end
end
