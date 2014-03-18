$ ->
   # Everything has to be added to the global namespace
   # Hence, the '@' prefix

   window.MobileCarousel or= {}

   window.MobileCarousel.MobileCarouselCollection = class MobileCarouselCollection extends Backbone.Collection

      initialize: ->
         @name = "_collection"
         @previousModels = []

      setName: (name) ->
         @name = name

      # We need to send a JSON hash to the server
      # as some servers (Rails, who knows about ASP) will automatically convert
      # a non-hash value into a hash for presentation to the handler
      toJSON: (options) ->
         returnArray = {}
         returnArray[@name] = this.map((model) -> return model.toJSON(options))
         return returnArray

      reset: (models, options) ->
         #These models have been completely validated and are in sync with the server
         #This is our local copy that we revert to if a sync fails
         @previousModels = models
         return Backbone.Collection.prototype.reset.call(@, models, options)

      saveAll: ->
         options = {
            success: (models, response, xhr) =>
               @.reset(models)
               @.trigger('collection:sync_success', @)
            error: (model, response, options) =>
               @.reset(@previousModels)

               # For some reason, sometimes the "error" event isn't propagated all the time
               # So I'm just triggering my own
               @.trigger('collection:sync_error', @, "Cart sync error")
         }

         # We need to send a "POST" instead of "PUT"
         # due to ISAPI restrictions...

         # The create method will do this for us
         return Backbone.sync('create', @, options)

      fetch: ->
         options = {
            reset: true
            success: (models, response, xhr) =>
               @.trigger('collection:sync_success', @)
            error: (model, response, options) =>
               @.reset(@previousModels)

               # For some reason, sometimes the "error" event isn't propagated all the time
               # So I'm just triggering my own
               @.trigger('collection:sync_error', @)
         }
         return Backbone.Collection.prototype.fetch.call(@, options)

   window.MobileCarousel.MobileCarouselModel = class MobileCarouselModel extends Backbone.Model

   window.MobileCarousel.MobileCarouselView = class MobileCarouselView extends Backbone.Marionette.View

   window.MobileCarousel.MobileCarouselItemView = class MobileCarouselItemView extends Backbone.Marionette.ItemView

   window.MobileCarousel.MobileCarouselCollectionView = class MobileCarouselCollectionView extends Backbone.Marionette.CollectionView
      constructor: (options) ->
         options or= {}
         Backbone.Marionette.CollectionView.prototype.constructor.apply(this, arguments);

         if (false == options.unbindAddRemove? or true == options.unbindAddRemove)
            @.stopListening(@collection, "add")
            @.stopListening(@collection, "remove")
            #@.stopListening(@collection, "reset")

   window.MobileCarousel.MobileCarouselRegion = class MobileCarouselRegion extends Backbone.Marionette.Region
      show: (view) ->
         if (null == view)
            @.close()
         else
            view.update()
            Backbone.Marionette.Region.prototype.show.call(@, view)

   window.MobileCarousel.MobileCarouselLayout = class MobileCarouselLayout extends Backbone.Marionette.Layout


   window.MobileCarousel.ItemModel = class ItemModel extends MobileCarousel.MobileCarouselModel
      defaults:
         itemType: ""
         guid: ""
         name: ""