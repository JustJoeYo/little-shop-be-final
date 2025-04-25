require 'rails_helper'

RSpec.configure do
  RSpec.config :documentation
end

RSpec.describe "Merchant Coupons API", type: :request do
  describe "GET /api/v1/merchants/:merchant_id/coupons/:id" do
    it "coupon count based on merchant" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant)
      customer = create(:customer)
      
      create_list(:invoice, 3, merchant: merchant, customer: customer, coupon: coupon)
      
      get "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"
      
      expect(response).to have_http_status(:ok)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:data][:id]).to eq(coupon.id.to_s)
      expect(json[:data][:type]).to eq('coupon')
      expect(json[:data][:attributes][:name]).to eq(coupon.name)
      expect(json[:data][:attributes][:code]).to eq(coupon.code)
      expect(json[:data][:attributes][:discount_type]).to eq(coupon.discount_type)
      expect(json[:data][:attributes][:discount_amount]).to eq(coupon.discount_amount.to_s)
      expect(json[:data][:attributes][:used_count]).to eq(3)
    end
    
    it "coupon not found" do
      merchant = create(:merchant)
      
      get "/api/v1/merchants/#{merchant.id}/coupons/29138012"
      
      expect(response).to have_http_status(:not_found)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to include("Couldn't find Coupon with 'id'=29138012")
    end
  end
end