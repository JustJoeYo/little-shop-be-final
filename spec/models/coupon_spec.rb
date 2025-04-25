require 'rails_helper'

RSpec.describe Coupon, type: :model do
  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoices }
  end

  describe 'validations' do
    let(:merchant) { create(:merchant) }
    
    subject { 
      described_class.new(
        name: 'Test Coupon',
        code: 'TEST101',
        discount_type: 'percent', 
        discount_amount: 10,
        merchant: merchant
      ) 
    }
    
    it { should validate_presence_of :name }
    it { should validate_presence_of :code }
    it { should validate_uniqueness_of :code }
    it { should validate_presence_of :discount_type }
    it { should validate_presence_of :discount_amount }
    it { should validate_inclusion_of(:discount_type).in_array(%w(percent dollar)) }
    it { should validate_numericality_of(:discount_amount).is_greater_than(0) }
    it { should validate_inclusion_of(:status).in_array(%w(active inactive)) }
  end

  describe 'instance methods' do
    it '# of invoices using the coupon' do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant)
      customer = create(:customer)
      
      create_list(:invoice, 3, merchant: merchant, customer: customer, coupon: coupon)
      
      expect(coupon.used_count).to eq(3)
    end
  end
end