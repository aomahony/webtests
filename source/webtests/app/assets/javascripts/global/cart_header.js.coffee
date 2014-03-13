#= require ./mobile_carousel_classes

$ ->
   
   window.Cart or= {}

   class CartItemCollection extends MobileCarousel.MobileCarouselCollection
      model: MobileCarousel.ItemModel
      url: "/cart"

   # !!! NOTE!!  DO NOT USE THIS CLASS DIRECTLY
   # Due to a CoffeeScript compilation bug, placing this class
   # within the singleton class makes it inherit from itself,
   # so we can't do that yet

   window.Cart.CartModelSingleton = class CartModelSingleton
      class CartModel extends MobileCarousel.MobileCarouselModel
         initialize: ->
            @items = new CartItemCollection
            @items.setName("cart")

            @.listenTo(@items, "collection:sync_error", (object, event) =>
               $(document).trigger("cart:error", "Error syncing cart with server")
            )
            @.listenTo(@items, "collection:sync_success", (object, event) =>
               $(document).trigger("cart:reset")
            )

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

      instance = new CartModel

      @getTotalQuantity: ->
         instance.getTotalQuantity()

      @addItem: (type, guid, quantity) ->
         instance.addItem(type, guid, quantity)

      @removeItem: (id) ->
         instance.removeItem(id)

      @fetch: ->
         instance.fetch()

      @getItems: ->
         instance.items

   class ErrorView extends MobileCarousel.MobileCarouselView
      initialize: (element) ->
         @setElement(element)
      SetErrorEvent: (eventName) ->
         $(document).on(eventName, (event, message) => @.render(message))
      SetSuccessEvent: (eventName) ->
         $(document).on(eventName, => @.render(""))
      render: (message) ->
         @$el.html(message)

   window.Views or= {}

   window.Views.CartHeaderView = class CartHeaderView extends MobileCarousel.MobileCarouselView
      el: ($ "#cart-view")
      
      template: _.template(($ "#cart-template").html())

      initialize: ->
         $(document).on("cart:reset", => @.render())

         errorView = new ErrorView(@.$('div.error'))
         errorView.SetErrorEvent("cart:error")
         errorView.SetSuccessEvent("cart:reset")

      render: ->
         @.$('div.cart-count').html(@template({totalQuantity: Cart.CartModelSingleton.getTotalQuantity()}))
         @ 

      update: ->
         Cart.CartModelSingleton.fetch()