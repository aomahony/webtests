$ ->
   # ASP.net uses the default underscore template tags (<% %>),
   # so we need to change what it looks for to "{%" and "%}"

   _.templateSettings = { 
      interpolate: /\{\{(.+?)\}\}/g,
      evaluate: /\{%([\s\S]+?)%\}/g,
      escape: /\{%-([\s\S]+?)%\}/g
   };

   console.log("gInit called");