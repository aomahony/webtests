# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#= require ../global/mobile_carousel_classes
#= require ../global/cart_header

$ ->

   localCartModelSingleton = @CartModelSingleton
   localItemModel = @ItemModel
   
   class CartItemView extends @.MobileCarouselItemView
      tagName: "div"
      template: _.template(($ "#cart-item-template").html())

      events:
         "click a.cart-item": "removeItem"

      removeItem: ->
         localCartModelSingleton.get().removeItem(@model.get("id"))

   class CartItemsView extends @.MobileCarouselCollectionView
      el: ($ "div.cartItems")
      itemView: CartItemView

   class ItemView extends @.MobileCarouselItemView
      tagName: "div"
      template: _.template(($ "#item-template").html())

      events:
         "click a.item": "addItemToCart"

      addItemToCart: ->
         localCartModelSingleton.get().addItem(@model.get("itemType"), @model.get("guid"), 10)

   class ItemCollection extends @.MobileCarouselCollection
      model: localItemModel
      url: "/cartitems"

   class ItemsView extends @.MobileCarouselCollectionView
      el: ($ "div.itemsView")
      itemView: ItemView

      initialize: ->
         @collection.fetch()

   
   gCartItemsView = new CartItemsView({collection: localCartModelSingleton.get().items})
   gItemsView = new ItemsView({collection: new ItemCollection})