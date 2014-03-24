$ ->   

   class AMobileCarouselApp extends Backbone.Router
      routes:
         "cart": "cartAction"
         "*page": "defaultAction"

      initialize: ->
         # HEADER
         @headerRegion = new MobileCarousel.AMobileCarouselRegion({el: "div.header"})

         # Header Views  
         @headerRegion.show(new Views.ACartHeaderView)

         # CONTENT
         @contentRegion = new MobileCarousel.AMobileCarouselRegion({el: "div.content"})

         # FOOTER
         @footerRegion = new MobileCarousel.AMobileCarouselRegion({el: "div.footer"})

         # Footer Views

      cartAction: ->
         @contentRegion.show(new Views.ACartPageView)

      defaultAction: (page) ->
         @contentRegion.show(new Views.AHomePageView)

   new AMobileCarouselApp
   Backbone.history.start();