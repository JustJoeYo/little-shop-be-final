require 'rails_helper'

class TestController < ApplicationController
  def validation_error
    render_validation_error(["Name can't be blank", "Price must be greater than 0"])
  end

  def not_found_error
    render_not_found("TestResource", 123)
  end
  
  def rule_error
    render_rule_error("This action violates business rules")
  end
  
  def direct_error_response
    render_error_response("Custom message", ["Error 1", "Error 2"], :forbidden)
  end
end

RSpec.describe ApplicationController, type: :controller do
  controller TestController do
  end

  before do
    routes.draw do # easiest way to get these errors for the test
      get 'validation_error', to: 'test#validation_error'
      get 'not_found_error', to: 'test#not_found_error'
      get 'rule_error', to: 'test#rule_error'
      get 'direct_error_response', to: 'test#direct_error_response'
    end
  end

  describe "#render_validation_error" do
    it "error formatting" do
      get :validation_error
      
      expect(response).to have_http_status(:unprocessable_entity)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to include("Name can't be blank")
      expect(json[:errors]).to include("Price must be greater than 0")
    end
  end
  
  describe "#render_not_found" do
    it "error formating" do
      get :not_found_error
      
      expect(response).to have_http_status(:not_found)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to include("Couldn't find TestResource with 'id'=123")
    end
  end
  
  describe "#render_rule_error" do
    it "error formatting" do
      get :rule_error
      
      expect(response).to have_http_status(:unprocessable_entity)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to include("This action violates business rules")
    end
  end
  
  describe "#render_error_response" do
    it "error formatting" do
      get :direct_error_response
      
      expect(response).to have_http_status(:forbidden)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:message]).to eq("Custom message")
      expect(json[:errors]).to include("Error 1")
      expect(json[:errors]).to include("Error 2")
    end
  end
  
  describe "rescue_from ActiveRecord::RecordNotFound" do
    it "error formatting" do
      allow(controller).to receive(:not_found_error).and_raise(ActiveRecord::RecordNotFound.new("Couldn't find Item with 'id'=999"))
      
      get :not_found_error
      
      expect(response).to have_http_status(:not_found)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to include("Couldn't find Item with 'id'=999")
    end
  end
  
  describe "rescue_from ActiveRecord::RecordInvalid" do
    it "error formatting" do
      item = Item.new
      item.errors.add(:name, "can't be blank")
      
      exception = ActiveRecord::RecordInvalid.new(item)
      allow(controller).to receive(:validation_error).and_raise(exception)
      
      get :validation_error
      
      expect(response).to have_http_status(:unprocessable_entity)
      
      json = JSON.parse(response.body, symbolize_names: true)
      
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors].first).to include("Validation failed")
    end
  end
end