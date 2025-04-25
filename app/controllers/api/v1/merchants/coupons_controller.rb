class Api::V1::Merchants::CouponsController < ApplicationController
  before_action :set_merchant
  before_action :set_coupon, only: [:show, :update]
  
  def index
    coupons = @merchant.coupons
    render json: CouponSerializer.new(coupons)
  end
end