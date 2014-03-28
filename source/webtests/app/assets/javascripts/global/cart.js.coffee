#= require ./mobile_carousel_classes
#= require ./cart_header

$ ->

   class ACartItemView extends MobileCarousel.AMobileCarouselItemView
      template: _.template(($ "#cart-item-template").html())

      events:
         "click a.cart-item": "RemoveItem"

      RemoveItem: ->
         Cart.ACartModelSingleton.RemoveItem(@model.get("id"))

   class ACartItemsListView extends MobileCarousel.AMobileCarouselPagedCollectionView
      itemView: ACartItemView

      initialize: ->
         @.SetCollection(Cart.ACartModelSingleton.Track())

         @.SetLoadingView(new MobileCarousel.AMobileCarouselLoadingView)
         @.SetLoadMoreView(new MobileCarousel.AMobileCarouselLoadMoreView)

         @.BindCollectionToFetchAndLoadedEvents()

         @.UpdateOnShow()

   class ACartItemsView extends MobileCarousel.AMobileCarouselLayout
      template: _.template(($ "#cart-items-template").html())

      initialize: ->
         @.addRegion("cart_items_list", "div#cart-items-list")
         @.addRegion("load_more_cart_items", "div#load-more-cart-items")

      onShowCalled: ->
         # !!! I think there can be a better way to streamline this
         @.cart_items_list.show(new ACartItemsListView({pageSize: 10}))
         @.load_more_cart_items.show(@.cart_items_list.currentView.loadMoreView)

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
         @.SetCollection(new AItemCollection)

         @.SetLoadingView(new MobileCarousel.AMobileCarouselLoadingView)
         @.BindCollectionToFetchAndLoadedEvents()

         @.UpdateOnShow()

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