FactoryBot.define do
  factory :coupon do
    name { "MyString" }
    code { "MyString" }
    discount_type { "MyString" }
    discount_amount { "9.99" }
    status { "MyString" }
    merchant { nil }
  end
end
