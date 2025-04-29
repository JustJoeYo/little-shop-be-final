class Api::V1::ItemsController < ApplicationController
  def index
    items = Item.all

    if params[:sorted].present? && params[:sorted] == "price"
      items = Item.sort_by_price
    end

    render json: ItemSerializer.new(items), status: :ok
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.new(item), status: :ok
  end

  def create
    item = Item.create!(item_params) # safe to use create! here because our exception handler will gracefully handle exception
    render json: ItemSerializer.new(item), status: :created
  end

  def update
    item = Item.find(params[:id])
    
    if !item_params[:merchant_id].nil?
      begin
        merchant = Merchant.find(item_params[:merchant_id])
      rescue ActiveRecord::RecordNotFound
        return render_not_found("Merchant", item_params[:merchant_id])
      end
    end
    
    if item.update(item_params)
      render json: ItemSerializer.new(item), status: :ok
    else
      render_validation_error(item.errors.full_messages)
    end
  end

  def destroy
    item = Item.find(params[:id])
    item.destroy
  end

  private

  def item_params
    params.permit(:name, :description, :unit_price, :merchant_id)
  end
end