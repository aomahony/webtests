$ ->   

   # This is where it all starts.  The Backbone.Router class
   # defines a way to parse hashbangs in URL's, and allows us to
   # display whatever page we want as a result

   # Our basic page layout is composed of a header div, a content div,
   # and a footer div, as well as all our Underscore.js templates

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

   # Create the app and start tracking history, and we're off!
   new AMobileCarouselApp
   Backbone.history.start();