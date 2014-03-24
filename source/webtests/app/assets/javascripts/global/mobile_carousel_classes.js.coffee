$ ->
   # Everything has to be added to the global namespace
   # Hence, the '@' prefix

   window.MobileCarousel or= {}

   window.MobileCarousel.AMobileCarouselCollection = class AMobileCarouselCollection extends Backbone.Collection

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

   window.MobileCarousel.AMobileCarouselModel = class AMobileCarouselModel extends Backbone.Model

   window.MobileCarousel.AMobileCarouselView = class AMobileCarouselView extends Backbone.Marionette.View

   window.MobileCarousel.AMobileCarouselItemView = class AMobileCarouselItemView extends Backbone.Marionette.ItemView

   window.MobileCarousel.AMobileCarouselCollectionView = class AMobileCarouselCollectionView extends Backbone.Marionette.CollectionView
      constructor: (options) ->
         options or= {}
         Backbone.Marionette.CollectionView.prototype.constructor.apply(this, arguments);

         if (false == options.unbindAddRemove? or true == options.unbindAddRemove)
            @.stopListening(@collection, "add")
            @.stopListening(@collection, "remove")
            #@.stopListening(@collection, "reset")

   window.MobileCarousel.AMobileCarouselErrorView = class AMobileCarouselErrorView extends MobileCarousel.AMobileCarouselItemView
      template: _.template(($ "#error-template").html())

      initialize: (options) ->
         @message = ""
         $(document).on(options['successEvent'], => 
            @message = ""
            @.render()
         )
         $(document).on(options['errorEvent'], (event, message) =>
            @message = message
            @.render()
         )

      serializeData: ->
         {message: @message}

   window.MobileCarousel.AMobileCarouselRegion = class AMobileCarouselRegion extends Backbone.Marionette.Region
      show: (view) ->
         if (null == view)
            # This should never happen
            @.close()
         else
            Backbone.Marionette.Region.prototype.show.call(@, view)

   window.MobileCarousel.AMobileCarouselLayout = class AMobileCarouselLayout extends Backbone.Marionette.Layout


   window.MobileCarousel.AItemModel = class AItemModel extends MobileCarousel.AMobileCarouselModel
      defaults:
         itemType: ""
         guid: ""
         name: ""