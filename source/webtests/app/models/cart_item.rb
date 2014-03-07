class CartItem < ActiveRecord::Base
  belongs_to :cart

  scope :newest, -> { order(:created_at => asc) }
end
