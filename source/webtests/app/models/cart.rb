class Cart < ActiveRecord::Base
   has_many :cart_items, -> {order("created_at DESC")}

   def self.getCart
      return Cart.first
   end

   def addItem(item)
      cartItem = CartItem.new
      cartItem.cart_id = self.id
      cartItem.update_attributes(item)
   end

   def removeItem(id)
      cartItem = CartItem.find(id)
      cartItem.destroy
   end

   def totalQuantity
      return cart_items.length
   end
end
