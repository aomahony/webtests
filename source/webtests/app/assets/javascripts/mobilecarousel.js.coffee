$ ->   

   class MobileCarouselViewContainer extends MobileCarousel.MobileCarouselView

      initialize: (element) ->
         @.setElement(element)

      appendView: (view) ->         
         @$el.append(view.update().el)
         view.render()

      setView: (view) ->
         @$el.html(view.update().el)
         view.render()

   class MobileCarouselApp extends Backbone.Router
      routes:
         "cart": "cartAction"
         "*page": "defaultAction"

      initialize: ->
         @currentView = null

         # HEADER
         @headerView = new MobileCarouselViewContainer(($ "div.header"))

         # Header Views
         @cartHeaderView = new Views.CartHeaderView   
         @headerView.appendView(@cartHeaderView)

         # CONTENT
         @contentView = new MobileCarouselViewContainer(($ "div.content"))

         # Content Views
         @cartPageView = new Views.CartPageView   

         # FOOTER
         @footerView = new MobileCarouselViewContainer($( "div.footer"))

         # Footer Views

      switchView: (view) ->
         if null != @currentView
            @currentView.remove()

         if null != view
            @contentView.setView(view)
         @currentView = view

      cartAction: ->
         @.switchView(@cartPageView)

      defaultAction: (page) ->
         console.log("Default Action: " + page)
         @.switchView(null)

   mobileCarouselApp = new MobileCarouselApp

   Backbone.history.start();