$ ->   

   class MobileCarouselAppHeaderView extends MobileCarousel.MobileCarouselView
      el: ($ "div.header")

      appendView: (view) ->         
         @$el.append(view.el)
         view.render()

   class MobileCarouselAppContentView extends MobileCarousel.MobileCarouselView
      el: ($ "div.content")

      setView: (view) ->
         @$el.html(view.el)
         view.render()

   class MobileCarouselAppFooterView extends MobileCarousel.MobileCarouselView
      el: ($ "div.footer")

   class MobileCarouselApp extends Backbone.Router
      routes:
         "cart": "cartAction"
         "*page": "defaultAction"

      initialize: ->
         @currentView = null

         # HEADER
         @headerView = new MobileCarouselAppHeaderView

         # Header Views
         @cartHeaderView = new Views.CartHeaderView   
         @headerView.appendView(@cartHeaderView.update())

         # CONTENT
         @contentView = new MobileCarouselAppContentView

         # Content Views
         @cartPageView = new Views.CartPageView   

         # FOOTER
         @footerView = new MobileCarouselAppFooterView

      switchView: (view) ->
         if null != @currentView
            @currentView.remove()

         if null != view
            @contentView.setView(view.update())
         @currentView = view

      cartAction: ->
         @.switchView(@cartPageView)

      defaultAction: (page) ->
         @.switchView(null)

   Backbone.emulateHTTP = true
   Backbone.emulateJSON = true
   mobileCarouselApp = new MobileCarouselApp

   Backbone.history.start();