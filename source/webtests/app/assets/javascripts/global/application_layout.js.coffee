$ ->
   _.templateSettings = { 
      interpolate: /\{\{(.+?)\}\}/g,
      evaluate: /\{%([\s\S]+?)%\}/g,
      escape: /\{%-([\s\S]+?)%\}/g
   };

   console.log("gInit called");