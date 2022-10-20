class Card
  attr_reader :value, :name

  def initialize(name, icon, value)
    @name = name
    @icon = icon
    @value = value
  end

  def show
    "#{@name}#{@icon}"
  end
end
