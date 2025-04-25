class Coupon < ApplicationRecord
  belongs_to :merchant
  has_many :invoices
  
  validates_presence_of :name, :code, :discount_type, :discount_amount # aka cant leave these blank
  validates_uniqueness_of :code # unique codes only yo (forgot this at first)
  validates :discount_type, inclusion: { in: %w(percent dollar) } # allows for %s and $s
  validates :discount_amount, numericality: { greater_than: 0 } # just gotta be more than 0
  validates :status, inclusion: { in: %w(active inactive) } # allows for active/inactive coupons
  
  scope :active, -> { where(status: 'active') } # query for only active coupons
  
  def used_count # just simple function to see how many invoices are usin this coupon
    invoices.count
  end
end