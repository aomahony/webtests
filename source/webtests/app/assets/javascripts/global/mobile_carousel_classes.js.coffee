$ ->

   # We add these methods to Marionette.View directly as both ItemView
   # and CollectionView can use these methods

   Backbone.Marionette.View.prototype.SetLoadingView = (view) ->
      @loadingView = view

   Backbone.Marionette.View.prototype.BindFetchEvent = (event) ->
      
      fetchEventHandler = =>
         # !!! This relies a bit on knowing the internals of Backbone.Marionette.CollectionView
         # !!! Which can change at any time!

         if true == @ instanceof Backbone.Marionette.CollectionView
            #Collection views use document fragments and append them to the element,
            #So we need to append the loading view to the element and remove it when we're done
            @$el.append(@loadingView.render().el)
         else
            # Everything else uses .html() to fill the view up once they have data, so we can just
            # Fill the view with the loading view HTML while waiting
            @$el.html(@loadingView.render().$el.html())

      if "object" == typeof event
         @.listenTo(event, "request", fetchEventHandler)
      else if "string" == typeof event
         $(document).on(event, fetchEventHandler)

   Backbone.Marionette.View.prototype.BindLoadedEvent = (event) ->
      
      loadedEventHandler = =>
         # We call this on the object regardless of the type of the view
         # So that the object can clean itself up
         @loadingView.remove()

      if "object" == typeof event
         @.listenTo(event, "reset", loadedEventHandler)
      else if "string" == typeof event
         $(document).on(event, loadedEventHandler) 

   Backbone.Marionette.View.prototype.BindFetchAndLoadedEvents = (fetchEvent, loadedEvent) ->
      @.BindFetchEvent(fetchEvent)
      @.BindLoadedEvent(loadedEvent)

   # Everything has to be added to the global namespace
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

      UpdateOnShow: ->
         # We want to update after we get the initial show event (incase we want to bind a loading view)
         @.listenTo(@, "show", => 
            @.Update()
         )
         @         

      Update: ->
         @

   window.MobileCarousel.AMobileCarouselCollectionView = class AMobileCarouselCollectionView extends Backbone.Marionette.CollectionView
      constructor: (options) ->
         options or= {}
         Backbone.Marionette.CollectionView.prototype.constructor.apply(this, arguments)

         if false == options.unbindAddRemove? or true == options.unbindAddRemove
            @.stopListening(@collection, "add")
            @.stopListening(@collection, "remove")

      BindCollectionToFetchAndLoadedEvents: ->
         @.BindFetchAndLoadedEvents(@collection, @collection)

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

   window.MobileCarousel.AMobileCarouselLoadingView = class AMobileCarouselLoadingView extends MobileCarousel.AMobileCarouselItemView
      template: _.template(($ "#loading-template").html())

   window.MobileCarousel.AMobileCarouselRegion = class AMobileCarouselRegion extends Backbone.Marionette.Region

   window.MobileCarousel.AMobileCarouselLayout = class AMobileCarouselLayout extends Backbone.Marionette.Layout

   window.MobileCarousel.AItemModel = class AItemModel extends MobileCarousel.AMobileCarouselModel
      defaults:
         itemType: ""
         guid: ""
         name: ""