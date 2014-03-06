# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
   console.log("Something")

   class TempBackbone extends Backbone.Model
      defaults:
         name: "Someone"
         index: 0

   class TempBackboneView extends Backbone.View
      tagName: 'div'

      render: ->
         @$el.html("Hello!")
         @

   view = new TempBackboneView
   view.render()
   ($ "body").append(view.$el)