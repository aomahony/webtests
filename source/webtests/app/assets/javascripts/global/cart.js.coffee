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

         @.BindCollectionToFetchAndLoadedEvents()
         @.UpdateOnShow()

   class ACartItemsView extends MobileCarousel.AMobileCarouselLayout
      template: _.template(($ "#cart-items-template").html())

      initialize: ->
         @.addRegion("cart_items_list", "div#cart-items-list")
         @.addRegion("load_more_cart_items", "div#load-more-cart-items")

      onShowCalled: ->
         @.cart_items_list.ShowWithLoadMoreView(new ACartItemsListView({pageSize: 10}), @.load_more_cart_items)

   class AItemView extends MobileCarousel.AMobileCarouselItemView
      template: _.template(($ "#item-template").html())

      events:
         "click a.item": "AddItemToCart"

      AddItemToCart: ->
         Cart.ACartModelSingleton.AddItem(@model.get("itemType"), @model.get("guid"), 1)

   class AItemCollection extends MobileCarousel.AMobileCarouselCollection
      model: MobileCarousel.AItemModel
      url: "/cartitems"

   class AItemsView extends MobileCarousel.AMobileCarouselCollectionView
      itemView: AItemView

      initialize: ->
         @.SetCollection(new AItemCollection)

         @.BindCollectionToFetchAndLoadedEvents()
         @.UpdateOnShow()

   class AItemImageCollection extends MobileCarousel.AMobileCarouselCollection
      model: MobileCarousel.AItemImageModel

   class AItemImageView extends MobileCarousel.AMobileCarouselItemView
      template: _.template(($ "#item-image-template").html())
      tagName: "li"

      serializeData: ->
         {imgSrc: @model.get('src')}

   class AItemsImageView extends MobileCarousel.AMobileCarouselCollectionView
      itemView: AItemImageView
      tagName: "ul"

      initialize: (opts) ->
         opts or= {}
         opts['images'] or= []
         @.SetCollection(new AItemImageCollection(opts['images']))

         @.UpdateOnShow()

      Update: ->
         @collection.reset(@collection.models)

   window.Views or= {}

   window.Views.ACartPageView = class ACartPageView extends MobileCarousel.AMobileCarouselLayout
      template: _.template(($ "#cart-page-template").html())

      id: "cart-page"
      className: "cart_page"

      initialize: ->
         @.addRegion("items", "div#items")
         @.addRegion("cart_items", "div#cart-items")
         @.addRegion("cart_items_images", "div#cart-items-images")

         @.listenTo(@.cart_items_images, "show", => console.log("CART ITEMS IMAGES SHOWN!"))

      onShowCalled: ->
         @.items.show(new AItemsView)  
         @.cart_items.show(new ACartItemsView)
         @.cart_items_images.show(new AItemsImageView({images: [{src: "http://www.babybedding.com/images/default/homepage_aprilsavings.jpg"}]}))