class Transaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :category

  with_options presence: true do |p|
    p.validates :date, timeliness: { type: :date }
    p.validates :amount, numericality: { greater_than: 0 }
    p.validates :user
    p.validates :category
  end
  validates :income, inclusion: { in: [true, false]}
  validates :description, length: { maximum: 65536 }
end
