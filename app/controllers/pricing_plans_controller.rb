class PricingPlansController < ApplicationController
  before_action :set_pricing_plan, only: [:checkout, :upgrade_with_stripe, :paypal_express_checkout, :cancel_payment]

  def index
    @pricing_plans = PricingPlan.all
  end

  def checkout
  end

  def upgrade_with_stripe
    begin
      current_user.create_stripe_customer(params[:stripeToken]) if current_user.stripe_id.blank?
      current_user.pay_via_stripe!(@pricing_plan)
      finish_payment
    rescue Stripe::CardError => e
      redirect_to cancel_paypal_pricing_plan_path(id: params[:id], message: e.message)
    end
  end

  def paypal_express_checkout
    amount = (@pricing_plan.price * 100).to_i

    response = EXPRESS_GATEWAY.setup_purchase(amount,
      ip: request.remote_ip,
      return_url: upgrade_with_paypal_pricing_plan_url(@pricing_plan),
      cancel_return_url: cancel_payment_pricing_plan_url(@pricing_plan),
      currency: Figaro.env.currency_code,
      allow_guest_checkout: true,
      items: [{name: @pricing_plan.name, description: "Payment for pricing plan ##{ @pricing_plan.name }", quantity: "1", amount: amount}]
    )
    redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)

  end

  def upgrade_with_paypal
    purchase = current_user.pay_via_paypal!( params.merge({ ip: request.remote_ip }) )
    if purchase[:success]
      finish_payment
    else
      redirect_to cancel_payment_pricing_plan_path(id: purchase[:id], message: purchase[:message])
    end
  end

  def cancel_payment
    # TODO: test with invalid response
    flash[:error] = params[:message] || response.message
    redirect_to checkout_pricing_plan_path(@pricing_plan)
  end

  def finish_payment
    flash[:success] = "You Pricing plan was successfully upgrated. Congrates with #{ current_user.pricing_plan.name.capitalize } pricing plan!"
    redirect_to root_path
  end

  def downgrade
    if current_user.can_downgrade?(params[:id])
      current_user.send(:set_pricing_plan, params[:id])
      flash[:success] = "You Pricing plan was successfully downgrated to #{ current_user.pricing_plan.name.capitalize } pricing plan!"
    else
      flash[:error] = "You don't have permissions to upgrade pricing plan"
    end
    redirect_to root_path
  end

  private
  def set_pricing_plan
    @pricing_plan = PricingPlan.find(params[:id])
  end
end
