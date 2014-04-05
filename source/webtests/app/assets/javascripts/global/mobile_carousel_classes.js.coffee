$ ->

   # This file is just a collection of classes extending from Backbone.Marionette classes
   # so we can implement custom functionality

   # There is also some direct extension of Marionette.View as some classes which extend from
   # Marionette.View can use the methods we define

   # We add these methods to Marionette.View directly as both ItemView
   # and CollectionView can use these methods

   Backbone.Marionette.View.prototype.Show = ->
      @$el.show()

   Backbone.Marionette.View.prototype.Hide = ->
      @$el.hide()

   Backbone.Marionette.View.prototype.SetLoadingView = (view) ->
      # This is the view we display when the view is "loading",
      # As in, waiting for data from the server
      @loadingView = view

   # These two methods can either take an object or a string
   # An object is a Backbone model which fires events
   # A string is the name of an event that is fired by the document

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
      else
         throw Error("Invalid event " + event + " for BindFetchEvent!")

   Backbone.Marionette.View.prototype.BindLoadedEvent = (event) ->
      loadedEventHandler = =>
         # We call this on the object regardless of the type of the view
         # So that the object can clean itself up
         @loadingView.remove()

      if "object" == typeof event
         @.listenTo(event, "reset", loadedEventHandler)
      else if "string" == typeof event
         $(document).on(event, loadedEventHandler) 
      else
         throw Error("Invalid event " + event + " for BindLoadedEvent!")

   Backbone.Marionette.View.prototype.BindFetchAndLoadedEvents = (fetchEvent, loadedEvent) ->
      @.BindFetchEvent(fetchEvent)
      @.BindLoadedEvent(loadedEvent)

   Backbone.Marionette.View.prototype.RenderOnEvent = (event) ->
      if "object" == typeof event
         @.listenTo(event, "reset", => @.render())
      else if "string" == typeof event
         $(document).on(event, => @.render())
      else
         throw Error("Invalid event " + event + " for RenderOnEvent!")

   Backbone.Marionette.View.prototype.UpdateOnShow = ->
      # We want to update after we get the initial show event (incase we want to bind a loading view)
      @.listenTo(@, "show", => 
         @.Update()
      )
      @   

   # Default update method, just here incase the views don't need to define it

   Backbone.Marionette.View.prototype.Update = ->
      @

   # Everything has to be added to the global namespace
   # to be accessable from other files
   # Basically, anything we want to use elsewhere is defined in the global namespace,
   # while anything we just need "privately" is just defined within the file

   window.MobileCarousel or= {}

   window.MobileCarousel.AMobileCarouselCollection = class AMobileCarouselCollection extends Backbone.Collection
      initialize: ->
         @name = "_collection"
         @previousModels = []
         @collectionTracking = null

      setName: (name) ->
         @name = name

      # "Tracking" a collection means that this collection
      # gets its data from another collection

      # We do it this way because CollectionViews and such need
      # their own collection object, so we keep the logic for
      # actually filling that object within the object itself.

      IsTrackingCollection: ->
         return null != @collectionTracking

      TrackCollection: (collection) ->
         @collectionTracking = collection
         # All our collections just use the "reset" event to signal changes.
         # When this happens, the collection asks anyone who's listening (a view) to tell
         # it how to refill itself, as the view typically manages the current state, and can
         # quickly tell the collection how much data it needs to get from the updated tracked
         # collection
         @.listenTo(@collectionTracking, "reset", => 
            @.trigger("tracked_collection_reset", @))

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
         if true == @.IsTrackingCollection
            throw Error("Cannot call saveAll while tracking a collection!")

         options = 
         {
            success: (models, response, xhr) =>
               @.reset(models)
               @.trigger('collection:sync_success', @)
            error: (model, response, options) =>
               @.reset(@previousModels)

               # For some reason, sometimes the "error" event isn't propagated all the time
               # So I'm just triggering my own
               @.trigger('collection:sync_error', @)
         }

         # We need to send a "POST" instead of "PUT"
         # due to ISAPI restrictions...

         # The create method will do this for us
         return Backbone.sync('create', @, options)

      # Remote and Local data-access functions
      # Remote request data from the server, while the local request data from ANOTHER collection
      # A collection can "track" a local collection for changes
      # This is used incase we have one master copy of a collection and a view which reads from it
      # EG: The shopping cart is managed by a singleton, but the cart view shows its contents

      fetch: ->
         if true == @.IsTrackingCollection()
            @.reset(@collectionTracking.models)
            return true
         else         
            options = 
            {
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

      fetchAmount: (amount) ->
         if true == @.IsTrackingCollection()
            @.reset(@collectionTracking.models.slice(0, amount))
            isDone = if amount < @collectionTracking.length then false else true
            @.trigger("collection:amount_fetched", @, {isDone: isDone})
         else
            options = 
            {
               reset: true
               success: (models, response, xhr) =>
                  @.trigger('collection:sync_success', @)
               error: (model, response, options) =>
                  @.reset(@previousModels)

                  # For some reason, sometimes the "error" event isn't propagated all the time
                  # So I'm just triggering my own
                  @.trigger('collection:sync_error', @)
               data:
                  length: amount
            }       
            return Backbone.Collection.prototype.fetch.call(@, options)  

      fetchPage: (page, pageSize) ->
         if true == @.IsTrackingCollection()
            startIndex = page * pageSize
            @.add(@collectionTracking.models.slice(startIndex, startIndex + pageSize), {silent: true})
            @.reset(@models)

            isDone = if (page + 1) * pageSize < @collectionTracking.length then false else true
            @.trigger('collection:page_fetched', @, {isDone: isDone})
         else
            options =
            {
               reset: false
               success: (data, response, xhr) =>
                  @.add(data['items'], {silent: true})
                  @.reset(@models)
                  @.trigger('collection:page_fetched', @, {isDone: data['isDone']})
            
               error: (model, response, options) =>
                  @.reset(@previousModels)

                  # For some reason, sometimes the "error" event isn't propagated all the time
                  # So I'm just triggering my own
                  @.trigger('collection:sync_error', @)
               data:
                  page: page
                  pageSize: pageSize
            }
            return Backbone.sync('read', @, options)

   window.MobileCarousel.AMobileCarouselModel = class AMobileCarouselModel extends Backbone.Model

   window.MobileCarousel.AMobileCarouselView = class AMobileCarouselView extends Backbone.Marionette.View

   window.MobileCarousel.AMobileCarouselItemView = class AMobileCarouselItemView extends Backbone.Marionette.ItemView      

   # AMobileCarouselCollectionView
   # Extends from Backbone.Marionette.CollectionView

   # We extend it to provide update methods and loading views

   # The options that we have added to the defaults are:

   # useCustomLoadingView (boolean): If we have defined our own view object to display 
   # when the collection is loading, we use it instead of the default template

   window.MobileCarousel.AMobileCarouselCollectionView = class AMobileCarouselCollectionView extends Backbone.Marionette.CollectionView
      constructor: (options) ->
         options or= {}
         Backbone.Marionette.CollectionView.prototype.constructor.apply(this, arguments)

         if true == options.useCustomLoadingView? and true == options.useCustomLoadingView
            @useCustomLoadingView = true
         else
            @useCustomLoadingView = false
            @.SetLoadingView(new MobileCarousel.AMobileCarouselDefaultLoadingView)

         # We only use the "reset" event for most collections.  The default
         # Marionette handler listens to "add" and "remove" and redraws,
         # while we don't want to do that as it redraws everything twice

         if null != @collection and (false == options.keepAddRemove? or false == options.keepAddRemove)
            @.stopListening(@collection, "add")
            @.stopListening(@collection, "remove")

      BindCollectionToFetchAndLoadedEvents: ->
         @.BindFetchAndLoadedEvents(@collection, @collection)

      Update: ->
         @collection.fetch()
         @

      SetCollection: (collection) ->
         @collection = collection

   # AMobileCarouselPagedCollectionView
   # Extends from MobileCarousel.AMobileCarouselCollectionView

   # We define this class to have a collection view which is loaded in pieces
   # It handles displaying a view to "load more" if not previously defined,
   # as well as interacting with the collection to fetch only a certain number of items

   # The options that we have added to the defaults are:

   # useCustomLoadMoreView (boolean): If we have defined our own view object to display
   # for the "load more" button, we let the object know here

   # appendLoadMoreView (boolean): If we want to just append the load more view to the end
   # of what's rendered, we can do that.  Alternatively, we define our own region for it, as
   # it might have its own styles and placement.

   window.MobileCarousel.AMobileCarouselPagedCollectionView = class AMobileCarouselPagedCollectionView extends MobileCarousel.AMobileCarouselCollectionView
      constructor: (options) ->
         options or= {}
         MobileCarousel.AMobileCarouselCollectionView.prototype.constructor.apply(this, arguments)

         @currentPage = 0;
         @pageSize = options['pageSize']

         if true == options.useCustomLoadMoreView? and true == options.useCustomLoadMoreView
            @useCustomLoadMoreView = true
         else
            @useCustomLoadMoreView = false
            @.SetLoadMoreView(new AMobileCarouselDefaultLoadMoreView)

         if true == options.appendLoadMoreView? and true == options.appendLoadMoreView
            @appendLoadMoreView = true
         else
            @appendLoadMoreView = false

      SetLoadMoreView: (loadMoreView) ->
         @loadMoreView = loadMoreView
         @.listenTo(@loadMoreView, "new_page_requested", => @.Update())
         @loadMoreView

      SetCollection: (collection) ->
         MobileCarousel.AMobileCarouselCollectionView.prototype.SetCollection.call(@, collection)
         @.listenTo(@collection, "collection:page_fetched", (object, params) => 
            @.NewPageFetched()
            if true == params['isDone']
               @loadMoreView.Hide()
            else
               @loadMoreView.Show()
         )
         @.listenTo(@collection, "collection:amount_fetched", (object, params) =>
            if true == params['isDone']
               @loadMoreView.Hide()
            else
               @loadMoreView.Show()
         )

         @.listenTo(@collection, "tracked_collection_reset", (object) =>
            @collection.fetchAmount(@currentPage * @pageSize)
         )

      NewPageFetched: ->
         @currentPage++

      Update: ->
         @collection.fetchPage(@currentPage, @pageSize)

      render: ->
         @isClosed = false
         @.triggerBeforeRender()
         @._renderChildren()

         if true == @appendLoadMoreView
            @$el.append(@loadMoreView.render().el)
         @.triggerRendered()
         @

   # AMobileCarouselRegion

   # A region shows views within it.  We can extend this just
   # to streamline the process of showing a custom loading view that is
   # not appended to the bottom of the collection view

   window.MobileCarousel.AMobileCarouselRegion = class AMobileCarouselRegion extends Backbone.Marionette.Region
      ShowWithLoadMoreView: (view, loadMoreViewRegion) ->
         Backbone.Marionette.Region.prototype.show.call(@, view)
         if 'undefined' != typeof loadMoreViewRegion
            loadMoreViewRegion.show(@.currentView.loadMoreView)

   window.MobileCarousel.AMobileCarouselLayout = class AMobileCarouselLayout extends Backbone.Marionette.Layout
      regionType: MobileCarousel.AMobileCarouselRegion

   # These are just some default objects for quick implementation and functionality testing

   window.MobileCarousel.AMobileCarouselDefaultErrorView = class AMobileCarouselDefaultErrorView extends MobileCarousel.AMobileCarouselItemView
      template: _.template(($ "#default-error-template").html())

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

   window.MobileCarousel.AMobileCarouselDefaultLoadingView = class AMobileCarouselDefaultLoadingView extends MobileCarousel.AMobileCarouselItemView
      template: _.template(($ "#default-loading-template").html())

   window.MobileCarousel.AMobileCarouselDefaultLoadMoreView = class AMobileCarouselDefaultLoadMoreView extends MobileCarousel.AMobileCarouselItemView
      template: _.template(($ "#default-load-more-template").html())

      events:
         "click a#load-more": "NewPageRequested"

      NewPageRequested: ->
         @.trigger("new_page_requested")

   # This is the model I'm currently using to define cart items

   window.MobileCarousel.AItemModel = class AItemModel extends MobileCarousel.AMobileCarouselModel
      defaults:
         itemType: ""
         guid: ""
         name: ""

   window.MobileCarousel.AItemImageModel = class AItemImageModel extends MobileCarousel.AMobileCarouselModel
      defaults:
         src: ""