#= require ./mobile_carousel_classes

$ ->
   window.Views or= {}

   window.Views.AHomePageView = class AHomePageView extends MobileCarousel.AMobileCarouselLayout
      template: _.template(($ "#home-page-template").html())

      id: "home-page"
      className: "home_page"