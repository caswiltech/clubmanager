class PaymentOption < ActiveRecord::Base
  has_many :registrations
  scope :publicly_visible, order("defaultresponse DESC, id").where(:adminonly => false)
end