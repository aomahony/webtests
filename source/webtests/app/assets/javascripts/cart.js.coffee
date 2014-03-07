# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

gItems = [{"itemType": "fabric", "guid": "483983hefuy9"}, {"itemType": "swatch", "guid": "88ad0h89ash9udasb9"}];

$ ->

   class ItemModel extends Backbone.Model

      defaults:
         itemType: ""
         guid: ""

      initialize: (item) ->
         this.set("itemType", item.itemType)
         this.set("guid", item.guid)

   class CartItemCollection extends Backbone.Collection
      model: ItemModel
      url: "/cart"

      saveAll: ->
         options = {
            success: (models, response, xhr) =>
               @.reset(models)
            error: (model, response, options) =>
               console.log("Error")
         }
         return Backbone.sync('update', @, options)

      fetch: ->
         options = {
            reset: true
            error: (model, response, options) =>
               console.log ("FETCH ERROR")
         }
         return Backbone.Collection.prototype.fetch.call(@, options)

   class CartModel extends Backbone.Model

      initialize: ->
         @items = new CartItemCollection

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

   class CartView extends Backbone.View
      el: ($ "#cart-view")
      
      template: _.template(($ "#cart-template").html())

      initialize: ->
         @listenTo(gCart.items, "reset", this.render)

      render: ->
         @$el.html(@template({totalQuantity: gCart.getTotalQuantity()}))
         @

   class CartItemView extends Backbone.View
      tagName: "div"
      template: _.template(($ "#cart-item-template").html())

      events:
         "click a.cart-item": "removeItem"

      initialize: ->

      removeItem: ->
         gCart.removeItem(this.model.get("id"))

      render: ->
         @$el.html(@template({
                                 itemType: this.model.get("itemType"), 
                                 guid: this.model.get("guid"),
                                 id: this.model.get("id")
                             }));
         @

   class CartItemsView extends Backbone.View
      el: ($ "div.cartItems")

      initialize: ->
         @listenTo(gCart.items, "reset", this.render)

      render: ->
         @$el.empty();
         gCart.items.each((model) =>
            cartItemView = new CartItemView({model: model});
            @$el.append(cartItemView.render().el)
         )
         @

   class ItemView extends Backbone.View
      tagName: "div"
      template: _.template(($ "#item-template").html())

      events:
         "click a.item": "addItemToCart"

      addItemToCart: ->
         gCart.addItem(this.model.get("itemType"), this.model.get("guid"), 1)

      render: ->
         @$el.html(@template({itemType: this.model.get("itemType"), guid: this.model.get("guid")}))
         @

   class ItemCollection extends Backbone.Collection
      model: ItemModel

      initialize: (itemsJSON) ->
         $.each(itemsJSON, (k, v) =>
            this.add(new ItemModel(v))
         )

   class ItemsView extends Backbone.View
      el: ($ "div.itemsView")

      initialize: ->
         @collection = new ItemCollection(gItems)
         @render()

      render: ->
         @$el.empty()
         @collection.each((model) =>
            itemView = new ItemView({model: model});
            @$el.append(itemView.render().el)
         )      
         @

   gCart = new CartModel
   gCartView = new CartView
   gCartItemsView = new CartItemsView
   gItemsView = new ItemsView

   gCart.fetch()  