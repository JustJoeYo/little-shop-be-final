class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :discount_type, :discount_amount, :status, :merchant_id
  
  attribute :used_count do |coupon|
    coupon.used_count
  end
end