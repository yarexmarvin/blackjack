class Player
  attr_reader :name
  attr_accessor :deposit, :cards

  def initialize(name)
    @name = name
    @deposit = 100
    @cards = []
  end

  def make_deposit(amount)
    if amount > deposit
      raise "#{@name}: Not enought money in the deposit! Game Over!"
    else
      @deposit -= amount
      true
    end
  end

  def take_card(card)
    @cards << card if @cards.size < 3
  end

  def take_award(award)
    @deposit += award
  end
end
