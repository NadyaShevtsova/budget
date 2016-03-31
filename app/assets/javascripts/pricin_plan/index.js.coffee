@module 'PricingPlan', ->
  @module 'Index', ->
    @init =->
      svgAnimashion()
      showAnotherDesign()

    svgAnimashion =->
      speed = 330
      easing = mina.backout
      [].slice.call(document.querySelectorAll('.sanimate, #grid > a')).forEach (el) ->
        s = Snap(el.querySelector('svg'))
        path = s.select('path')
        pathConfig =
          from: path.attr('d')
          to: el.getAttribute('data-path-hover')
        el.addEventListener 'mouseenter', ->
          path.animate { 'path': pathConfig.to }, speed, easing
          return
        el.addEventListener 'mouseleave', ->
          path.animate { 'path': pathConfig.from }, speed, easing
          return
        return
      return

    showAnotherDesign =->
      $('.another-design').click ->
        $('.container .row').toggleClass 'hidden'
        return

$ ->
  PricingPlan.Index.init() if $('#pricing-plans-index').length

