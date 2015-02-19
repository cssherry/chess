require_relative('chess/board.rb')
require 'yaml'
require 'dispel'

class GameSaved < ArgumentError
end

class Game
  attr_accessor :board, :player1, :player2, :current_player, :players

  def initialize(player1, player2)
    @board = Board.new
    @player1 = { player: player1, color: 'white' }
    @player2 = { player: player2, color: 'black' }
    @current_player = @player1
    @players = { @player1 => @player2, @player2 => @player1 }
  end

  def play
    game_over = false
    until game_over
      board.render
      game_over = turn(@current_player[:color])
      puts
      break if game_over == true
      @current_player = @players[current_player]
    end
    board.render
    puts "CHECKMATE. #{current_player[:player]} playing #{current_player[:color]} wins!"
  end

  def turn(color)
    begin
      puts "#{current_player[:player]}, you are #{current_player[:color]}. \nWhat's your move? \nEnter 's' to save the game. Enter 'e' to exit the game."
      move = gets.chomp
      exit if move == 'e'
      move == 's' ? save_game : move = parse_answer(move)

      board.move(move[0], move[1], color)
    rescue WrongStartPositionError => s
      puts "#{s}: Enter a correct start position"
      retry
    rescue WrongEndPositionError => e
      puts "#{e}: Enter a correct end position"
      retry
    rescue GameSaved => g
      puts 'Game saved!'
      retry
    rescue InCheckError => c
      puts "#{c}: You are still in check"
      retry
    end
    board.checkmate?(color)
  end

  def save_game
    puts 'Filename?'
    filename = gets.chomp.downcase
    File.open("saved_games/#{filename}.yml", 'w') { |f| f.puts self.to_yaml }
    fail GameSaved
    rescue Errno::ENOENT => s
      puts "#{s}: Enter a legitimate filename"
      retry
  end

  def parse_answer(string)
    move = string.split(' ')
    start_position = parse_position(move[0])
    end_position = parse_position(move[1])
    [start_position, end_position]
  end

  def parse_position(position)
    symbols = Hash['8', 0, '7', 1, '6', 2, '5', 3,
                   '4', 4, '3', 5, '2', 6, '1', 7,
                   'a', 0, 'b', 1, 'c', 2, 'd', 3,
                   'e', 4, 'f', 5, 'g', 6, 'h', 7]

    new_position = position.split('')
    new_position[0], new_position[1] = new_position[1], new_position[0]
    new_position.collect { |array| symbols[array] }
  end
end

puts 'Do you want to start a new game or load an old one? (n/l)'
load = gets.chomp.downcase
if load == 'l'
  begin
    puts 'Filename?'
    filename = gets.chomp.downcase
    file = YAML.load_file("saved_games/#{filename}.yml")
    file.play
  rescue Errno::ENOENT => e
    puts "#{e}: Wrong File Name"
    retry
  end
else
  puts "What is player 1's name?"
  player1 = gets.chomp.capitalize
  puts "What is player 2's name?"
  player2 = gets.chomp.capitalize
  game = Game.new(player1, player2)
  game.play
end
