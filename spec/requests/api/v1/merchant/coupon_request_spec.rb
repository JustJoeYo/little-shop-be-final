require 'rails_helper'

RSpec.describe "Merchant coupons endpoints", type: :request do
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

  describe "GET /api/v1/merchants/:merchant_id/coupons" do
    it "All coupons for merchant" do
      merchant = create(:merchant)
      coupons = create_list(:coupon, 3, merchant: merchant)
      
      get "/api/v1/merchants/#{merchant.id}/coupons"
      
      expect(response).to have_http_status(:ok)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:data].length).to eq(3)
      expect(json[:data].first[:attributes][:name]).to eq(coupons.first.name)
    end
    
    it "Coupon filtering" do
      merchant = create(:merchant)
      active_coupons = create_list(:coupon, 2, merchant: merchant, status: 'active')
      inactive_coupons = create_list(:coupon, 2, merchant: merchant, status: 'inactive')
      
      get "/api/v1/merchants/#{merchant.id}/coupons?status=active"
      
      expect(response).to have_http_status(:ok)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:data].length).to eq(2)
      expect(json[:data].all? { |coupon| coupon[:attributes][:status] == 'active' }).to be true
    end
  end

  describe "POST /api/v1/merchants/:merchant_id/coupons" do
    it "creates new coupon" do
      merchant = create(:merchant)
      coupon_params = {
        coupon: {
          name: "Turing Sale",
          code: "Turing25",
          discount_type: "percent",
          discount_amount: 25,
          status: "active"
        }
      }
      
      post "/api/v1/merchants/#{merchant.id}/coupons", params: coupon_params
      
      expect(response).to have_http_status(:created)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:data][:attributes][:name]).to eq("Turing Sale")
      expect(json[:data][:attributes][:code]).to eq("Turing25")
      expect(json[:data][:attributes][:discount_type]).to eq("percent")
      expect(json[:data][:attributes][:discount_amount]).to eq("25.0")
    end
    
    it "TOO MANY DISCOUNTS YO" do
      merchant = create(:merchant)
      create_list(:coupon, 5, merchant: merchant, status: 'active')
      
      coupon_params = {
        coupon: {
          name: "the straw", # that broke the camel's back hehehe
          code: "uhoh",
          discount_type: "percent",
          discount_amount: 10,
          status: "active"
        }
      }
      
      post "/api/v1/merchants/#{merchant.id}/coupons", params: coupon_params
      
      expect(response).to have_http_status(:unprocessable_entity)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:errors]).to include("Merchant has reached the maximum of 5 active coupons")
    end
    
    it "duplicate entry" do
      merchant = create(:merchant)
      existing_coupon = create(:coupon, merchant: merchant, code: "samesies")
      
      coupon_params = {
        coupon: {
          name: "Duplicate Code",
          code: "samesies",
          discount_type: "percent",
          discount_amount: 15,
          status: "active"
        }
      }
      
      post "/api/v1/merchants/#{merchant.id}/coupons", params: coupon_params
      
      expect(response).to have_http_status(:unprocessable_entity)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:errors]).to include("Code has already been taken")
    end
  end

  describe "PATCH /api/v1/merchants/:merchant_id/coupons/:id" do
    it "activation of coupon" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant, status: 'inactive')
      
      patch_params = {
        coupon: {
          status: 'active'
        }
      }
      
      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", params: patch_params
      
      expect(response).to have_http_status(:ok)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:data][:attributes][:status]).to eq('active')
    end
    
    it "deactivation of coupon" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant, status: 'active')
      
      patch_params = {
        coupon: {
          status: 'inactive'
        }
      }
      
      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", params: patch_params
      
      expect(response).to have_http_status(:ok)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:data][:attributes][:status]).to eq('inactive')
    end
    
    it "too many coupons ):" do
      merchant = create(:merchant)
      create_list(:coupon, 5, merchant: merchant, status: 'active')
      inactive_coupon = create(:coupon, merchant: merchant, status: 'inactive')
      
      patch_params = {
        coupon: {
          status: 'active'
        }
      }
      
      patch "/api/v1/merchants/#{merchant.id}/coupons/#{inactive_coupon.id}", params: patch_params
      
      expect(response).to have_http_status(:unprocessable_entity)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:errors]).to include("Merchant has reached the maximum of 5 active coupons")
    end
    
    it "deactivation issues" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant, status: 'active')
      customer = create(:customer)
      
      create(:invoice, merchant: merchant, customer: customer, coupon: coupon, status: 'packaged')
      
      patch_params = {
        coupon: {
          status: 'inactive'
        }
      }
      
      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", params: patch_params
      
      expect(response).to have_http_status(:unprocessable_entity)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:errors]).to include("Cannot deactivate a coupon with pending invoices")
    end
    
    it "duplicate entry" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant)
      existing_coupon = create(:coupon, merchant: merchant, code: "samesies")
      
      patch_params = {
        coupon: {
          code: "samesies"
        }
      }
      
      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", params: patch_params
      
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "Error handling" do
    it "returning not found" do
      non_existent_merchant_id = 324832482992
      
      get "/api/v1/merchants/#{non_existent_merchant_id}/coupons"
      
      expect(response).to have_http_status(:not_found)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to include("Couldn't find Merchant with 'id'=#{non_existent_merchant_id}")
    end
    
    it "merchant doesnt exist" do
      non_existent_merchant_id = 324832482992
      
      coupon_params = {
        coupon: {
          name: "Test Coupon",
          code: "TEST",
          discount_type: "percent",
          discount_amount: 10,
          status: "active"
        }
      }
      
      post "/api/v1/merchants/#{non_existent_merchant_id}/coupons", params: coupon_params
      expect(response).to have_http_status(:not_found)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to include("Couldn't find Merchant with 'id'=#{non_existent_merchant_id}")
    end
  end
end