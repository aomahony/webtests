#= require_tree ./global

$ ->   

   class MobileCarouselAppContentView extends MobileCarousel.MobileCarouselView
      el: ($ "div.content")

      setView: (view) ->
         @$el.html(view.el)
         view.render()

   class MobileCarouselApp extends Backbone.Router
      routes:
         "cart": "cartAction"
         "*page": "defaultAction"

      initialize: ->
         @currentView = null

         # Header Views
         @cartHeaderView = new Views.CartHeaderView 

         # Content Views
         @cartPageView = new Views.CartPageView     

         # Global Content App View   
         @appView = new MobileCarouselAppContentView

         @cartHeaderView.update()

      switchView: (view) ->
         if null != @currentView
            @currentView.remove()

         if null != view
            @appView.setView(view.update())
         @currentView = view

      cartAction: ->
         @.switchView(@cartPageView)

      defaultAction: (page) ->
         @.switchView(null)

   Backbone.emulateHTTP = true
   Backbone.emulateJSON = true
   mobileCarouselApp = new MobileCarouselApp

   Backbone.history.start();