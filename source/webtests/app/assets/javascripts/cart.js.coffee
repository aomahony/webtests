# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#= require mobile_carousel_classes

$ ->
   class ItemModel extends @.MobileCarouselModel

      defaults:
         itemType: ""
         guid: ""
         name: ""

   class CartItemCollection extends @.MobileCarouselCollection
      model: ItemModel
      url: "/cart"

   # !!! NOTE!!  DO NOT USE THIS CLASS DIRECTLY
   # Due to a CoffeeScript compilation bug, placing this class
   # within the singleton class makes it inherit from itself,
   # so we can't do that yet

   class CartModel extends @.MobileCarouselModel
      initialize: ->
         @items = new CartItemCollection

         @.listenTo(@items, "sync_error", (object, event) =>
            $(document).trigger("cart:error", "Error syncing cart with server")
         )
         @.listenTo(@items, "success", (object, event) =>
            $(document).trigger("cart:reset"))

      getTotalQuantity: ->
         return @items.length

      addItem: (type, guid, name, quantity) ->
         for i in [0...quantity]
            @items.add({"itemType": type, "guid": guid, "name": name})
         @saveAll()

      removeItem: (id) ->
         @items.remove(@items.get(id))
         @saveAll()

      saveAll: ->
         @items.saveAll()

      fetch: ->
         @items.fetch()

   class CartModelSingleton
      instance = null

      @get: ->
         if null == instance
            instance = new CartModel
         instance

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
         @listenTo(gCart.items, "reset", @.render)
         errorView = new ErrorView(@.$('div.error'))
         errorView.SetErrorEvent("cart:error")
         errorView.SetSuccessEvent("cart:reset")

      render: ->
         @.$('div.cart-count').html(@template({totalQuantity: gCart.getTotalQuantity()}))
         @

   class CartItemView extends @.MobileCarouselItemView
      tagName: "div"
      template: _.template(($ "#cart-item-template").html())

      events:
         "click a.cart-item": "removeItem"

      removeItem: ->
         gCart.removeItem(@model.get("id"))

   class CartItemsView extends @.MobileCarouselCollectionView
      el: ($ "div.cartItems")
      itemView: CartItemView

   class ItemView extends @.MobileCarouselItemView
      tagName: "div"
      template: _.template(($ "#item-template").html())

      events:
         "click a.item": "addItemToCart"

      addItemToCart: ->
         gCart.addItem(@model.get("itemType"), @model.get("guid"), @model.get("name"), 10)

   class ItemCollection extends @.MobileCarouselCollection
      model: ItemModel
      url: "/cartitems"

   class ItemsView extends @.MobileCarouselCollectionView
      el: ($ "div.itemsView")
      itemView: ItemView

      initialize: ->
         @collection.fetch()

   gCart = CartModelSingleton.get()
   gCartView = new CartView
   gCartItemsView = new CartItemsView({collection: gCart.items})
   gItemsView = new ItemsView({collection: new ItemCollection, el: ($ "div.itemsView")})
   #errorView = new ErrorView

   gCart.fetch()  