#= require ./mobile_carousel_classes

$ ->
   window.Cart or= {}

   class CartItemCollection extends MobileCarousel.MobileCarouselCollection
      model: MobileCarousel.ItemModel
      url: "/cart"

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

   class ErrorView extends MobileCarousel.MobileCarouselItemView
      template: _.template(($ "#error-template").html())

      initialize: ->
         @.setMessage("")

      setMessage: (message) ->
         @message = message

      serializeData: ->
         {message: @message}

   class CartCountView extends MobileCarousel.MobileCarouselItemView
      template: _.template(($ "#cart-count-template").html())

      serializeData: ->
         {totalQuantity: Cart.CartModelSingleton.getTotalQuantity()}

      update: ->
         Cart.CartModelSingleton.fetch()
         @

   window.Views or= {}

   window.Views.CartHeaderView = class CartHeaderView extends MobileCarousel.MobileCarouselLayout
      id: "cart-header"
      className: "cart_header"
      
      template: _.template(($ "#cart-header-template").html())

      initialize: ->
         $(document).on("cart:reset", => 
            @.showError("")
            @.cart_count.show(@cartCountView)
         )
         $(document).on("cart:error", (event, message) =>
            @.showError(message)
         )

         @.addRegion("cart_count", "div#cart-count")
         @.addRegion("error", "div#cart-error")

         @errorView = new ErrorView
         @cartCountView = new CartCountView

      onShowCalled: ->
         @cartCountView.update()
         @.cart_count.show(@cartCountView)
         @.error.show(@errorView)       

      showError: (message) ->
         @errorView.setMessage(message)
         @.error.show(@errorView)

      update: ->
         @