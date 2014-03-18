#= require ./mobile_carousel_classes

$ ->
   window.Views or= {}

   console.log("IS THIS BEING CALLED")
   window.Views.HomePageView = class HomePageView extends MobileCarousel.MobileCarouselLayout
      template: _.template(($ "#home-page-template").html())

      id: "home-page"
      className: "home_page"

      update: ->
         @