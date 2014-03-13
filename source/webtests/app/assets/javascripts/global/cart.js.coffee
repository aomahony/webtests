# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#= require ./mobile_carousel_classes
#= require ./cart_header

$ ->

   class CartItemView extends MobileCarousel.MobileCarouselItemView
      tagName: "div"
      template: _.template(($ "#cart-item-template").html())

      events:
         "click a.cart-item": "removeItem"

      removeItem: ->
         Cart.CartModelSingleton.removeItem(@model.get("id"))

   class CartItemsView extends MobileCarousel.MobileCarouselCollectionView
      itemView: CartItemView

      tagName: "div"
      className: "cartItems"

      update: ->
         @collection.fetch()

   class ItemView extends MobileCarousel.MobileCarouselItemView
      tagName: "div"
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

      tagName: "div"
      className: "items"

      initialize: ->
         @collection = new ItemCollection

      update: ->
         @collection.fetch()

   window.Views or= {}

   window.Views.CartPageView = class CartPageView extends MobileCarousel.MobileCarouselView
      tagName: "div"
      className: "cart"

      initialize: ->
         @cartItemsView = new CartItemsView({
                                                collection: Cart.CartModelSingleton.getItems()
                                            })
         @itemsView = new ItemsView

      render: ->
         @$el.append(@itemsView.el)
         @$el.append(@cartItemsView.el)

      update: ->
         @itemsView.update()
         @cartItemsView.update()
         @