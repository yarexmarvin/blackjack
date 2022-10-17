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
    puts "size #{players.size}"
    deposit = @money / players.size
    puts "deposit #{deposit}"
    players.each { |player| player.take_award(deposit) }
  end
end
