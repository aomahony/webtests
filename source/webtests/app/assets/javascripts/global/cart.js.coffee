#= require ./mobile_carousel_classes
#= require ./cart_header

$ ->

   class CartItemView extends MobileCarousel.MobileCarouselItemView
      template: _.template(($ "#cart-item-template").html())

      events:
         "click a.cart-item": "removeItem"

      removeItem: ->
         Cart.CartModelSingleton.removeItem(@model.get("id"))

   class CartItemsView extends MobileCarousel.MobileCarouselCollectionView
      itemView: CartItemView

      initialize: ->
         @collection = Cart.CartModelSingleton.getItems()
         
      update: ->
         @collection.fetch()
         @

   class ItemView extends MobileCarousel.MobileCarouselItemView
      template: _.template(($ "#item-template").html())

      events:
         "click a.item": "addItemToCart"

      addItemToCart: ->
         Cart.CartModelSingleton.addItem(@model.get("itemType"), @model.get("guid"), 10)

   class ItemCollection extends MobileCarousel.MobileCarouselCollection
      model: MobileCarousel.ItemModel
      url: "/cartitems"

   class ItemsView extends MobileCarousel.MobileCarouselCollectionView
      itemView: ItemView

      initialize: ->
         @collection = new ItemCollection

      update: ->
         @collection.fetch()
         @

   window.Views or= {}

   window.Views.CartPageView = class CartPageView extends MobileCarousel.MobileCarouselLayout
      template: _.template(($ "#cart-page-template").html())

      id: "cart-page"
      className: "cart_page"

      initialize: ->
         @.addRegion("items", "div#items")
         @.addRegion("cart_items", "div#cart-items")

         @cartItemsView = new CartItemsView
         @itemsView = new ItemsView

      onShowCalled: ->
         @itemsView.update()
         @.items.show(@itemsView)
         @cartItemsView.update()    
         @.cart_items.show(@cartItemsView)

      update: ->
         @