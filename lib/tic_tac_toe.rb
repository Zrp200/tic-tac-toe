require_relative 'tic_tac_toe/board'
require_relative 'tic_tac_toe/computer'
require_relative 'tic_tac_toe/display_board'
require_relative 'tic_tac_toe/player'

class TicTacToe
  attr_reader :board, :turn_num, :players, :computer, :player, :game

  def self.start
    new.play
  end

  def initialize
    @board = Board.new(3,3)
    @turn_num = 0
    @players = []
  end

  def play
    trap('INT') do
      puts 'exiting!'
      exit!
    end
    print_intro
    choose_human
    set_players_order
    game_loop
  end


  def print_intro
    clear_screen

    print "Welcome to my Tic Tac Toe game!"
  end

  def choose_human
    error = ""
    while 1
      begin
        clear_screen
        puts "Which player would you like to be? (\"x\" or \"o\"): "
        puts error unless error.empty?
        human_symbol = gets.chomp
        @player = Player.new(human_symbol)
        break
      rescue Player::InvalidCharacterError => e
        error = e.message
        retry
      end
    end
    @computer = Computer.new(choose_computer(human_symbol))
  end

  def set_players_order
    if player.symbol == "x"
      @players << @player
      @players << @computer
    else
      @players << @computer
      @players << @player
    end
  end

  def game_loop
    while !@board.end_state?
      clear_board

      current_player = @players[@turn_num % 2]

      take_turn(current_player)

      @turn_num += 1
    end

    clear_board

    puts "The winner is: #{@board.end_state?}"
  end

  private

  def take_turn(current_player)
    if current_player.human?
      human_move(current_player)
    else
      move = current_player.calculate_best_move(@board)
      computer.make_move(@board, move)
    end
  end

  def human_move(current_player)
    puts
    error = ""
    while 1
      begin
        clear_board
        print_message
        puts error unless error.empty?

        move = gets.chomp
        current_player.make_move(@board, move)
        break
      rescue Board::InvalidCoordinateError => e
        error = e.message
      rescue Board::InvalidActionError => e
        error = e.message
      end
    end
  end

  def choose_computer(human)
    if human == "x"
      return "o"
    else
      return "x"
    end
  end

  def clear_screen
    puts "\033c"
  end

  def print_board
    puts DisplayBoard.call(@board)
  end

  def clear_board
    clear_screen
    print_board
  end

  def print_message
    puts "Please choose a square to mark."
  end
end
