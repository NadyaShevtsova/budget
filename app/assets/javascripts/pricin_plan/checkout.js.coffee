@module 'PricingPlan', ->
  @module 'Checkout', ->
    @init =->
      initStripe()

    initStripe =->
      $(':submit').on 'click', (event) ->
        event.preventDefault()
        $button = $(@)
        $form = $button.parents('form')

        opts = $.extend({}, $button.data(), token: (result) ->
          token = result.id
          $form.append "<input type='hidden' name='stripeToken' value='#{ token }' />"
          $form.submit()
        )
        StripeCheckout.open(opts)

$ ->
  PricingPlan.Checkout.init() if $('#pricing-plans-checkout').length

