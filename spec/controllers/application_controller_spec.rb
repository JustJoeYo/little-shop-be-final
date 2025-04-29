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
end