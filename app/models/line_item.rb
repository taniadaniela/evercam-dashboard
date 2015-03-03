class LineItem
  attr_reader :plan_id, :plan_name, :price, :duration, :quantity

  def initialize(plan_id, plan_name, price, duration, quantity)
    @plan_id = plan_id
    @plan_name = plan_name
    @price = price
    @duration = duration
    @quantity = quantity
  end
end