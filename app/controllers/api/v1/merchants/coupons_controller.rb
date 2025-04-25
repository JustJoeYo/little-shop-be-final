class Api::V1::Merchants::CouponsController < ApplicationController
  before_action :set_merchant
  before_action :set_coupon, only: [:show, :update]
  
  def index
    coupons = @merchant.coupons
    render json: CouponSerializer.new(coupons)
  end

  def show
    render json: CouponSerializer.new(@coupon)
  end
  
  def create
    coupon = @merchant.coupons.new(coupon_params)
    
    if !@merchant.can_activate_coupon? && coupon.status == 'active'
      render json: { 
        message: "Your query could not be completed", 
        errors: ["Merchant has reached the maximum of 5 active coupons"] 
      }, status: :unprocessable_entity
    elsif coupon.save
      render json: CouponSerializer.new(coupon), status: :created
    else
      render json: { 
        message: "Your query could not be completed", 
        errors: coupon.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end
  
  def update
    if coupon_status_changed_to_active?
      unless @merchant.can_activate_coupon?
        return render json: { 
          message: "Your query could not be completed", 
          errors: ["Merchant has reached the maximum of 5 active coupons"] 
        }, status: :unprocessable_entity
      end
    end
    
    if @coupon.update(coupon_params)
      render json: CouponSerializer.new(@coupon)
    else
      render json: { 
        message: "Your query could not be completed", 
        errors: @coupon.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
  
  def set_coupon
    @coupon = @merchant.coupons.find(params[:id])
  end
  
  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_type, :discount_amount, :status)
  end
  
  def coupon_status_changed_to_active?
    params[:coupon][:status] == 'active' && @coupon.status != 'active'
  end
end