FactoryBot.define do
  factory :coupon do
    name { Faker::Commerce.promotion_code }
    code { Faker::Alphanumeric.unique.alphanumeric(number: 8).upcase }
    discount_type { ['percent', 'dollar'].sample }
    discount_amount { discount_type == 'percent' ? rand(5..50) : rand(1..20) }
    status { 'active' }
    merchant
  end
end