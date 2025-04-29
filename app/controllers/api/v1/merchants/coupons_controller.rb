class Api::V1::Merchants::CouponsController < ApplicationController
  before_action :set_merchant
  before_action :set_coupon, only: [:show, :update]
  
  def index
    coupons = if params[:status].present?
      @merchant.coupons.where(status: params[:status])
    else
      @merchant.coupons
    end
    render json: CouponSerializer.new(coupons)
  end

  def show
    render json: CouponSerializer.new(@coupon)
  end
  
  def create
    coupon = @merchant.coupons.new(coupon_params)
    
    if !@merchant.can_activate_coupon? && coupon.status == 'active'
      render_rule_error("Merchant has reached the maximum of 5 active coupons")
    elsif coupon.save
      render json: CouponSerializer.new(coupon), status: :created
    else
      render_validation_error(coupon.errors.full_messages)
    end
  end
  
  def update
    if coupon_status_changed_to_active?
      unless @merchant.can_activate_coupon?
        return render_rule_error("Merchant has reached the maximum of 5 active coupons")
      end
    end
    
    # check pending invoices before deactivating
    if params[:coupon][:status] == 'inactive' && @coupon.status == 'active'
      pending_invoices = @coupon.invoices.where(status: 'packaged')
      if pending_invoices.any?
        return render_rule_error("Cannot deactivate a coupon with pending invoices")
      end
    end
    
    if @coupon.update(coupon_params)
      render json: CouponSerializer.new(@coupon)
    else
      render_validation_error(@coupon.errors.full_messages)
    end
  end
  
  private
  
  def set_merchant
    @merchant = Merchant.find(params[:merchant_id])
  rescue ActiveRecord::RecordNotFound
    render_not_found("Merchant", params[:merchant_id])
  end
  
  def set_coupon
    @coupon = @merchant.coupons.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_not_found("Coupon", params[:id])
  end
  
  def coupon_params
    params.require(:coupon).permit(:name, :code, :discount_type, :discount_amount, :status)
  end
  
  def coupon_status_changed_to_active?
    params[:coupon][:status] == 'active' && @coupon.status != 'active'
  end
end