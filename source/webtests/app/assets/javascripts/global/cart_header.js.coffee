#= require ./mobile_carousel_classes

$ ->
   
   class TempModel extends @.ItemModel


   class CartItemCollection extends @.MobileCarouselCollection
      model: TempModel
      url: "/cart"

   # !!! NOTE!!  DO NOT USE THIS CLASS DIRECTLY
   # Due to a CoffeeScript compilation bug, placing this class
   # within the singleton class makes it inherit from itself,
   # so we can't do that yet

   class CartModel extends @.MobileCarouselModel
      initialize: ->
         @items = new CartItemCollection
         @items.setName("cart")

         @.listenTo(@items, "sync_error", (object, event) =>
            $(document).trigger("cart:error", "Error syncing cart with server")
         )
         @.listenTo(@items, "sync_success", (object, event) =>
            $(document).trigger("cart:reset"))

      getTotalQuantity: ->
         return @items.length

      addItem: (type, guid, quantity) ->
         for i in [0...quantity]
            @items.add({"itemType": type, "guid": guid})
         @saveAll()

      removeItem: (id) ->
         @items.remove(@items.get(id))
         @saveAll()

      saveAll: ->
         @items.saveAll()

      fetch: ->
         @items.fetch()

   class @CartModelSingleton
      instance = null

      @get: ->
         if null == instance
            instance = new CartModel
         instance

   localCartModelSingleton = @CartModelSingleton

   class ErrorView extends @.MobileCarouselView
      initialize: (element) ->
         @setElement(element)
      SetErrorEvent: (eventName) ->
         $(document).on(eventName, (event, message) => @.render(message))
      SetSuccessEvent: (eventName) ->
         $(document).on(eventName, => @.render(""))
      render: (message) ->
         @$el.html(message)

   class CartView extends @.MobileCarouselView
      el: ($ "#cart-view")
      
      template: _.template(($ "#cart-template").html())

      initialize: ->
         @listenTo(localCartModelSingleton.get().items, "reset", @.render)

         errorView = new ErrorView(@.$('div.error'))
         errorView.SetErrorEvent("cart:error")
         errorView.SetSuccessEvent("cart:reset")

      render: ->
         @.$('div.cart-count').html(@template({totalQuantity: localCartModelSingleton.get().getTotalQuantity()}))
         @

   gCartView = new CartView
   localCartModelSingleton.get().fetch()  