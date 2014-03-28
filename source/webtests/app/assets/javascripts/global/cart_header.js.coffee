#= require ./mobile_carousel_classes

$ ->
   window.Cart or= {}

   window.Cart.ACartModelSingleton = class ACartModelSingleton
      class ACartItemCollection extends MobileCarousel.AMobileCarouselCollection
         model: MobileCarousel.AItemModel
         url: "/cart"

      class ACartModel extends MobileCarousel.AMobileCarouselModel
         initialize: ->
            @items = new ACartItemCollection
            @items.setName("cart")

            @.listenTo(@items, "request", (object, event) =>
               $(document).trigger("cart:request")
            )
            @.listenTo(@items, "collection:sync_error", (object, event) =>
               $(document).trigger("cart:error", "Error syncing cart with server")
            )
            @.listenTo(@items, "collection:sync_success", (object, event) =>
               $(document).trigger("cart:reset")
            )

         GetTotalQuantity: ->
            return @items.length

         AddItem: (type, guid, quantity) ->
            for i in [0...quantity]
               @items.add({"itemType": type, "guid": guid})
            @SaveAll()

         RemoveItem: (id) ->
            @items.remove(@items.get(id))
            @SaveAll()

         SaveAll: ->
            @items.saveAll()

         Fetch: ->
            @items.fetch()

      instance = new ACartModel

      @GetTotalQuantity: ->
         instance.GetTotalQuantity()

      @AddItem: (type, guid, quantity) ->
         instance.AddItem(type, guid, quantity)

      @RemoveItem: (id) ->
         instance.RemoveItem(id)

      @Fetch: ->
         instance.Fetch()

      @GetItems: ->
         instance.items

      @Track: ->
         returnValue = new ACartItemCollection
         returnValue.TrackCollection(ACartModelSingleton.GetItems())
         returnValue

   class ACartCountView extends MobileCarousel.AMobileCarouselItemView
      template: _.template(($ "#cart-count-template").html())

      initialize: ->
         $(document).on("cart:reset", => 
            @.render()
         )
         @.UpdateOnShow()

      serializeData: ->
         {totalQuantity: Cart.ACartModelSingleton.GetTotalQuantity()}

      Update: ->
         Cart.ACartModelSingleton.Fetch()
         @

   window.Views or= {}

   window.Views.ACartHeaderView = class ACartHeaderView extends MobileCarousel.AMobileCarouselLayout
      id: "cart-header"
      className: "cart_header"
      
      template: _.template(($ "#cart-header-template").html())

      initialize: ->
         @.addRegion("cart_count", "div#cart-count")
         @.addRegion("error", "div#cart-error")

      onShowCalled: ->
         @.cart_count.show(new ACartCountView)
         @.error.show(new MobileCarousel.AMobileCarouselErrorView({errorEvent: "cart:error", successEvent: "cart:reset"}))    