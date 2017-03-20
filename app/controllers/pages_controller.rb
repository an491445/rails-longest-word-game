class PagesController < ApplicationController
  def game
    @grid = generate_grid(9);
  end

  def score
    @guess = params[:word]
    @grid = JSON.parse(params[:grid])
    @result = { score: 0, message: "Well done!", time: 1 }

    # If the word is not in the grid
    if !check_grid(@guess, @grid)
      @result[:message] = "Not in the grid"
    # If the word is a valid English word
    elsif !(File.read('/usr/share/dict/words').upcase.split("\n").include? @guess.upcase)
      @result[:message] = "not an english word"
    # Otherwise calculate score
    else
      @result[:score] = @guess.length
      @result[:translation] = get_translation(@guess)
    end
  end

  private

  # Generate a random grid of letters
  def generate_grid(grid_size)
    letters = ('A'..'Z').to_a
    Array.new(grid_size) { letters[rand(26)] }
  end

  def get_translation(word)
    key = "5d42af99-1a5c-4e03-88a0-4f3669dbe2f8"
    url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{key}&input=#{word}"
    begin
      data_serialized = open(url).read
      data = JSON.parse(data_serialized)
      translation = data["outputs"][0]["output"]
    rescue
      translation = nil
    end
    return translation
  end

  # Check if the word is included in the grid
  def check_grid(word, grid)
    array = grid.dup
    word.each_char do |c|
      return false unless array.include? c.upcase
      array.delete_at(array.index(c.upcase))
    end
    return true
  end

end
