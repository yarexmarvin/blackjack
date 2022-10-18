require_relative "card"
require_relative "bank"
require_relative "./player/user"
require_relative "./player/dealer"

NAMES = [*(2..10), "J", "Q", "K", "A"].freeze
ICONS = ["♥", "♠", "♣", "♦"].freeze

USER = "user".freeze
DEALER = "dealer".freeze
NEXT_GAME = "next_game".freeze
END_GAME = "end_game".freeze

class Main
  def initialize
    @cards = []
    @user = {}
    @dealer = {}
    @move = USER
    @bank = Bank.new
  end

  def start_game
    puts "================"
    puts "Enter your name:"
    puts "================"

    user_name = gets.chomp
    return unless user_name != ""

    @user = User.new(user_name)
    @dealer = Dealer.new("Dealer")
    game_initialization
  end

  def game_initialization
    generate_cards
    @user.cards = []
    @dealer.cards = []

    puts "====================================="
    puts "Your deposit: #{@user.deposit}"
    puts "Dealer's deposit: #{@dealer.deposit}"
    puts "====================================="

    player_took_card(@user, 2)
    player_took_card(@dealer, 2)

    begin
      @bank.reset
      player_make_deposit(@user, 10)
      player_make_deposit(@dealer, 10)
    rescue StandardError => e
      puts "Game is ending"
      puts e
      return
    end
    @move = USER
    game
  end

  def game
    loop do
      case @move
      when USER
        user_move
      when DEALER
        dealer_move
      when NEXT_GAME
        continue_game = next_game
        game_initialization if continue_game
      when END_GAME
        break
      end
      check_for_results unless @move == END_GAME
    end
  end

  def next_game
    puts "Would you like to play next game?"
    puts "1 - yes"
    puts "2 - no"
    ask_user = gets.chomp
    @move = END_GAME
    case ask_user
    when "1"
      puts "let is go"
      true
    when "2"
      false
    end
  end

  def user_move
    print "My cards:"
    @user.cards.each { |card| print " #{card.show} " }
    puts
    puts "My score: #{count_cards(@user)}"
    puts "================="
    print "Dealer's cards: "
    @dealer.cards.each { |card| print "*" }
    puts
    puts "================="
    options = ["Пропустить", "Добавить карту", "Открыть карты"]
    puts "================"
    puts "Choose your move:"
    options.each_with_index { |option, index| puts "#{index + 1} - #{option}" }
    puts "================"
    user_move = gets.chomp

    case user_move
    when "1"
      user_pass_action
    when "2"
      user_take_card_action
    when "3"
      user_reveal_cards
    else
      puts "Wrong option, try again"
    end
  end

  def user_pass_action
    @move = DEALER
  end

  def user_take_card_action
    player_took_card(@user)
  end

  def user_reveal_cards
    puts count_cards(@user)
    end_game
  end

  def dealer_move
    current_result = count_cards(@dealer)

    puts "=============="
    puts "Dealer's move!"
    puts "=============="

    if current_result <= 17
      player_took_card(@dealer)
    end
    @move = USER
  end

  def count_cards(player)
    selectA = player.cards.select { |card| card.name == "A" }
    filterA = player.cards.reject { |card| card.name == "A" }

    result = filterA.reduce(0) do |sum, card|
      sum += card.value
      sum
    end

    if selectA.size.positive?
      option1 = result + 11
      option2 = result + 1
      return option1 if option2 > 21
      return option2 if option1 > 21
      return option2 if option1 < option2
      return option1 if option1 > option2
    else
      result
    end
  end

  def end_game
    puts "================="
    print "Dealer's cards: "
    @dealer.cards.each { |card| print " #{card.show} " }
    puts
    puts "================="
    puts "================="
    print "Your cards: "
    @user.cards.each { |card| print " #{card.show} " }
    puts
    puts "================="

    user_score = count_cards(@user)
    dealer_score = count_cards(@dealer)

    puts "================="
    puts "Dealer's score: #{dealer_score}"
    puts "================="
    puts "================="
    puts "Your score: #{user_score}"
    puts "================="

    winners = []

    if user_score == dealer_score
      winners << @user
      winners << @dealer
    elsif user_score == 21
      winners << @user
    elsif dealer_score == 21
      winners << @dealer
    elsif user_score < 21 && dealer_score < 21
      who_won = user_score > dealer_score ? @user : @dealer
      winners << who_won
    elsif user_score > 21 && dealer_score < 21
      winners << @dealer
    elsif dealer_score > 21 && user_score < 21
      winners << @user
    end

    if winners.size == 2
      puts "======"
      puts "Ничья"
      puts "======"
    else
      puts "==============================="
      puts "#{winners[0].name} is a winner!"
      puts "==============================="
    end

    @bank.award(winners)
    @move = NEXT_GAME
  end

  def check_for_results
    end_game if @user.cards.size == 3 && @dealer.cards.size == 3
  end

  def player_took_card(player, cards_amount = 1)
    if cards_amount == 2
      player_card1, player_card2 = @cards.sample(2)
      player.take_card(player_card1)
      player.take_card(player_card2)
      @cards.delete_if { |card| card == player_card1 || card == player_card2 }
    elsif cards_amount == 1
      player_card = @cards.sample
      player.take_card(player_card)
      @cards.delete(player_card)
    end
  end

  def player_make_deposit(player, deposit)
    status_ok = player.make_deposit(deposit)
    @bank.deposit(deposit) if status_ok
  end

  def generate_cards
    @cards = []
    ICONS.each do |icon|
      NAMES.each do |name|
        case name
        when Integer
          @cards << Card.new(name, icon, name)
        when "J"
          @cards << Card.new(name, icon, 10)
        when "Q"
          @cards << Card.new(name, icon, 10)
        when "K"
          @cards << Card.new(name, icon, 10)
        when "A"
          @cards << Card.new(name, icon, 11)
        end
      end
    end
  end
end

Main.new.start_game
