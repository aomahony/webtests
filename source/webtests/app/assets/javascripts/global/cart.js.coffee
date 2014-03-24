#= require ./mobile_carousel_classes
#= require ./cart_header

$ ->

   class ACartItemView extends MobileCarousel.AMobileCarouselItemView
      template: _.template(($ "#cart-item-template").html())

      events:
         "click a.cart-item": "RemoveItem"

      RemoveItem: ->
         Cart.ACartModelSingleton.RemoveItem(@model.get("id"))

   class ACartItemsView extends MobileCarousel.AMobileCarouselCollectionView
      itemView: ACartItemView

      initialize: ->
         @collection = Cart.ACartModelSingleton.GetItems()

         @.SetLoadingView(new MobileCarousel.AMobileCarouselLoadingView)
         @.BindCollectionToFetchAndLoadedEvents()

         @.UpdateOnShow()

      Update: ->
         @collection.fetch()
         @

   class AItemView extends MobileCarousel.AMobileCarouselItemView
      template: _.template(($ "#item-template").html())

      events:
         "click a.item": "AddItemToCart"

      AddItemToCart: ->
         Cart.ACartModelSingleton.AddItem(@model.get("itemType"), @model.get("guid"), 10)

   class AItemCollection extends MobileCarousel.AMobileCarouselCollection
      model: MobileCarousel.AItemModel
      url: "/cartitems"

   class AItemsView extends MobileCarousel.AMobileCarouselCollectionView
      itemView: AItemView

      initialize: ->
         @collection = new AItemCollection

         @.SetLoadingView(new MobileCarousel.AMobileCarouselLoadingView)
         @.BindCollectionToFetchAndLoadedEvents()

         @.UpdateOnShow()

      Update: ->
         @collection.fetch()
         @

   window.Views or= {}

   window.Views.ACartPageView = class ACartPageView extends MobileCarousel.AMobileCarouselLayout
      template: _.template(($ "#cart-page-template").html())

      id: "cart-page"
      className: "cart_page"

      initialize: ->
         @.addRegion("items", "div#items")
         @.addRegion("cart_items", "div#cart-items")

      onShowCalled: ->
         @.items.show(new AItemsView)  
         @.cart_items.show(new ACartItemsView)

      #Update: ->
      #   @