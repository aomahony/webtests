# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

cart = Cart.create

items = Item.create([{
                        name: "Soft Fabric", 
                        itemType: "fabric", 
                        guid: "udsa89dyas89dash9"
                     },
                     {
                        name: "Soft Fabric Swatch",
                        itemType: "swatch",
                        guid: "dsa79ydas97dash9u"
                     },
                     {
                        name: "Pink and Gray Drapes",
                        itemType: "product",
                        guid: "dsay79days79dagh9"
                     }]);