#= require ./mobile_carousel_classes

$ ->
   # Everything that we want to use elsewhere
   # needs to be added to the global namespace

   # The "Cart" namespace just handles cart logic
   window.Cart or= {}

   # This is the way I'm currently handling the cart for the page.
   # We use a "singleton" to keep all handling methods in one place,
   # and create a global instance of it that we can use

   # Lots of different views and regions can access the cart and modify
   # it, so we want to keep it all centralized

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

         # !!! Do we want to have a "quantity" field on the server?
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

      # Collections can, instead of getting their data from the server,
      # get their data from another collection.
      # The cart loads itself on page load, but the viewer might only need
      # to view 10 or so items, so the viewer's collection can be set up
      # to track the main collection

      @Track: ->
         returnValue = new ACartItemCollection
         returnValue.TrackCollection(ACartModelSingleton.GetItems())
         returnValue

   class ACartCountView extends MobileCarousel.AMobileCarouselItemView
      template: _.template(($ "#cart-count-template").html())

      initialize: ->
         @.RenderOnEvent("cart:reset")
         @.UpdateOnShow()

      # Marionette.ItemView (which we extend as MobileCarousel.AMobileCarouselItemView)
      # uses serialized data to render the template we provide

      serializeData: ->
         {totalQuantity: Cart.ACartModelSingleton.GetTotalQuantity()}

      Update: ->
         Cart.ACartModelSingleton.Fetch()
         @

   # The "Views" namespace handles any view that will be displayed by the main router
   # on command

   window.Views or= {}

   # The header view for the cart currently has the count display and a default error view

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