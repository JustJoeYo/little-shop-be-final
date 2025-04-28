class Api::V1::Merchants::InvoicesController < ApplicationController
  before_action :set_merchant
  
  def index
    if params[:status].present?
      invoices = @merchant.invoices_filtered_by_status(params[:status])
    else
      invoices = @merchant.invoices
    end
    render json: MerchantInvoiceSerializer.new(invoices)
  end
  
  private
  
  def set_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end