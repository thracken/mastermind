module Mastermind
  class Game
    def initialize
      @player = Player.new
      @answer = Solution.new.create
      @turns = 0
      @guesses = Array.new
      @all_clues = Array.new
      @turn_count = 0
    end #initialize

    def play
      show_board
      loop do
        take_turn
        break if game_over?
      end
      play_again?
    end #play

    def take_turn
      get_player_guess
      @turn_count += 1
      show_board
    end #take_turn

    def get_player_guess
      new_guess = Player_Guess.new.get_guess
      @guesses.push new_guess
    end #get_player_guess

    def show_board
      if @turn_count > 1 && game_over?
        puts "   GAME OVER   "
        puts " #{@answer[0]} | #{@answer[1]} | #{@answer[2]} | #{@answer[3]}"
      else
        puts "               "
        puts " X | X | X | X |"
      end
      puts "---+---+---+---+----"
      @guesses.each do |guess|
        clue = Feedback.new.analyze(guess, @answer)
        @all_clues.push clue
        puts " #{guess[0]} | #{guess[1]} | #{guess[2]} | #{guess[3]} | #{clue[0]} #{clue[1]} "
        puts "   |   |   |   | #{clue[2]} #{clue[3]}"
        puts "---+---+---+---+----"
      end
    end #show_board

    def game_over?
      last_clue = Feedback.new.analyze(last_guess, @answer)
      if last_clue == ["C","C","C","C"]
        puts "You Win!"
        return true
      elsif @turn_count >= 12
        return true
      else
        return false
      end
    end #game_over?

    def last_guess
      return @guesses.last
    end

    def play_again?
      loop do
        print "Would you like to play again? (Y/N) "
        restart = gets.chomp.downcase
        if restart == "n"
          "Thanks for playing, #{@player.name}!"
          return
        elsif restart == "y"
          Game.new.play
        end
      end
    end #play_again?

  end #Game

  class Player
    attr_reader :name
    def initialize
      get_name
    end

    def get_name
      print "What's your name? "
      @name = gets.chomp
    end
  end #Player

  class Combo
    attr_reader :slots
    def initialize
      @slots = Array.new(4)
    end
  end #Combo

  class Player_Guess < Combo
    VALID_NUM = [1,2,3,4,5,6]
    def get_guess
      puts "Enter 4 numbers (1-6), one at a time:"
      @slots.each_with_index do |val, index|
        loop do
          input = gets.chomp.to_i
          if VALID_NUM.include?(input)
            @slots[index] = input
            break
          end
          puts "Try again - enter a number from 1-6."
        end
      end
      return @slots
    end #get_guess
  end #Player_Guess

  class Solution < Combo
    attr_reader :slots
    def create
      @slots = 4.times.map { rand(1..6) }
    end
  end #Solution

  class Feedback
    attr_reader :clues
    def initialize
      @clues = Array.new
    end

    def analyze(combo,solution)
      guess = combo.clone
      answer = solution.clone
      guess.each_with_index do |num, index|
        if guess[index] == answer[index]
          @clues.push("C")
          answer[index] = nil
          guess[index] = nil
        end
      end
      (1..6).each do |num|
        [guess.count(num), answer.count(num)].min.times do
          @clues.push("x")
        end
      end
      @clues.push("-") while @clues.length < 4
      return @clues.shuffle
    end
  end #Feedback

end #Mastermind

include Mastermind
Game.new.play
