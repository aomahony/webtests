$ ->   

   class MobileCarouselApp extends Backbone.Router
      routes:
         "cart": "cartAction"
         "*page": "defaultAction"

      initialize: ->
         @currentView = null

         # HEADER
         @headerRegion = new MobileCarousel.MobileCarouselRegion({el: "div.header"})

         # Header Views  
         @headerRegion.show(new Views.CartHeaderView)

         # CONTENT
         @contentRegion = new MobileCarousel.MobileCarouselRegion({el: "div.content"})

         # FOOTER
         @footerRegion = new MobileCarousel.MobileCarouselRegion({el: "div.footer"})

         # Footer Views

      cartAction: ->
         @contentRegion.show(new Views.CartPageView)

      defaultAction: (page) ->
         console.log(window.Views)
         @contentRegion.show(new Views.HomePageView)

   mobileCarouselApp = new MobileCarouselApp

   Backbone.history.start();