class CartController < ApplicationController
  
   def index
   end

   def get_all_items
      render :json => Item.all
   end

   def get
      cart = Cart.getCart
      render :json => cart.cart_items
   end

   def update
      cart = Cart.getCart

      cartItems = cart.cart_items

      items = if nil == params[:_json] then [] else params[:_json] end
 
      newArray = items.select{|hash| true == hash.has_key?("id")}.map {|hash| hash['id']}
      existingArray = cartItems.to_a.map(&:serializable_hash).map {|hash| hash['id']}

      removedItems = if newArray.length > existingArray.length then newArray - existingArray else existingArray - newArray end;

      removedItems.each do |id|
         cart.removeItem(id)
      end

      newItems = items.select {|hash| false == hash.has_key?("id")}

      newItems.each do |item|
         cart.addItem(item)
      end

      cart.reload
      render :json => cart.cart_items
   end
end
