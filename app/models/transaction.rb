class Transaction < ActiveRecord::Base
  HALF_YEAR = 6
  belongs_to :category
  attr_accessor :category_name, :user_id

  with_options presence: true do |p|
    p.validates :date, timeliness: { type: :date }
    p.validates :amount, numericality: { greater_than: 0 }
    p.validates :category_name
  end
  validates :income, inclusion: { in: [true, false]}
  validates :description, length: { maximum: 65536 }

  scope :income_amount,       ->{ where(income: true) }
  scope :expenditures_amount, ->{ where(income: false) }
  scope :this_month,          ->{ where(date: Date.today.beginning_of_month..Date.today.end_of_month) }

  before_save :set_category

  def self.expenditures_this_month (ids)
    self.joins(:category).where(id: ids, income: false).this_month
                    .group('categories.name')
                    .sum(:amount).to_a
                    .map{ |t| [t.first, t.last.to_f]}
  end

  def self.current_balance
    all.income_amount.sum(:amount) - all.expenditures_amount.sum(:amount)
  end

  def self.weekly_balances( month = HALF_YEAR )
    date = (Date.today - month.months).beginning_of_month.beginning_of_week
    data = []
    balance = 0
    while date < Date.today.end_of_month do
      trs = all.where(date: date..date + 6.days)
      dif = trs.current_balance.to_f
      data << [(date + 6.days).strftime("%d.%m"), (dif + balance), (dif + balance)] unless dif.zero?
      balance += dif
      date = date + 7.days
    end
    data
  end

  private
  def set_category
    self.category = Category.where({user_id: user_id, name: category_name.capitalize}).first_or_create
  end
end
