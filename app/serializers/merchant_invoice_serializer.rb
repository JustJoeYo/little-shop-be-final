class MerchantInvoiceSerializer
  include JSONAPI::Serializer
  set_type :invoice
  attributes :customer_id, :merchant_id, :status, :coupon_id
end