$ ->
   # Everything has to be added to the global namespace
   # Hence, the '@' prefix

   class @.MobileCarouselCollection extends Backbone.Collection

      initialize: ->
         @name = "_collection"
         @previousModels = []

      setName: (name) ->
         @name = name

      toJSON: (options) ->
         returnArray = {}
         returnArray[@name] = this.map((model) -> return model.toJSON(options))
         return returnArray

      reset: (models, options) ->
         #These models have been completely validated and are in sync with the server
         #This is our local copy that we revert to if a sync fails
         @previousModels = models;
         return Backbone.Collection.prototype.reset.call(@, models, options)

      saveAll: ->
         options = {
            success: (models, response, xhr) =>
               @.reset(models)
               @.trigger('sync_success', @)
            error: (model, response, options) =>
               @.reset(@previousModels)

               # For some reason, sometimes the "error" event isn't propagated all the time
               # So I'm just triggering my own
               @.trigger('sync_error', @)
         }

         # We need to send a "POST" instead of "PUT"
         # due to ISAPI restrictions...

         # The create method will do this for us
         return Backbone.sync('create', @, options)

      fetch: ->
         options = {
            reset: true
            success: (models, response, xhr) =>
               @.trigger('sync_syccess', @)
            error: (model, response, options) =>
               @.reset(@previousModels)

               # For some reason, sometimes the "error" event isn't propagated all the time
               # So I'm just triggering my own
               @.trigger('sync_error', @)
         }
         return Backbone.Collection.prototype.fetch.call(@, options)

   class @.MobileCarouselModel extends Backbone.Model

   class @.MobileCarouselView extends Backbone.View

   class @.MobileCarouselItemView extends Backbone.Marionette.ItemView

   class @.MobileCarouselCollectionView extends Backbone.Marionette.CollectionView

      constructor: (options) ->
         Backbone.Marionette.CollectionView.prototype.constructor.apply(this, arguments);

         if (false == options.unbindAddRemove? or true == options.unbindAddRemove)
            @.stopListening(@collection, "add")
            @.stopListening(@collection, "remove")

   class @.ItemModel extends @.MobileCarouselModel
      defaults:
         itemType: ""
         guid: ""
         name: ""