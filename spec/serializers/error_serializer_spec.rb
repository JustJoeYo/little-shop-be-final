require 'rails_helper'

RSpec.describe ErrorSerializer do
  describe 'formatting errors' do
    it 'formats errors correctly' do
      messages = ["error message 1", "error message 2"]
      result = ErrorSerializer.format_errors(messages)
      
      expect(result).to be_a(Hash)
      expect(result[:message]).to eq('Your query could not be completed')
      expect(result[:errors]).to eq(messages)
    end
  end
  
  describe 'invalid searching' do 
    it 'error format for bad search' do
      result = ErrorSerializer.format_invalid_search_response
      
      expect(result).to be_a(Hash)
      expect(result[:message]).to eq("your query could not be completed")
      expect(result[:errors]).to eq(["invalid search params"])
    end
  end
end