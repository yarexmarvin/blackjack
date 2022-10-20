class Bank
  def initialize
    @money = 0
  end

  def deposit(amount)
    @money += amount
  end

  def reset
    @money = 0
  end

  def award(players)
    deposit = @money / players.size
    players.each { |player| player.take_award(deposit) }
  end
end
