class LineItem
  attr_reader :type, :product_id, :quantity, :duration, :name, :price
  
  def initialize(params)
    @type = params[:type]
    @product_id = params[:product_id]
    @quantity = params[:quantity] ? params[:quantity] : 0
    @duration = params[:duration]
    @name = params[:name]
    @price = params[:price]
  end
end