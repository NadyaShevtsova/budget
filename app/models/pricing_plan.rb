class PricingPlan < ActiveRecord::Base
  has_many :users

  with_options presence: true do |p|
    p.validates :name, length: { maximum: 255 }
    p.validates :price, numericality: { greater_than_or_equal_to: 0.0 }
    p.validates :quantity_of_categories, numericality: { greater_than: 0, only_integer: true }
    p.validates :quantity_of_transactions, numericality: { greater_than: 0, only_integer: true }
  end

  def self.defaul_plan
    self.find_by_name("mini")
  end

  def method_missing(meth, *args, &block)
    method_name = meth.to_s.gsub("?","")
    if method_name.in?(PricingPlan.pluck(:name))
      self.class.send('define_method', meth) {
        method_name == self.name
      }
      self.send(meth)
    else
      super
    end
  end
end
