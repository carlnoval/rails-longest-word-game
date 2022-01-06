class GamesController < ApplicationController
  def new
    @random_letters = generate_letters(10)
  end

  def score
    # need to use @ so erb can access values
    @entered_word = params[:entered_word]
    @random_letters = params[:random_letters]
    @result = check_word_validity(@entered_word, @random_letters)
  end

  # number of vowels is at least 20% of letter_count
  def generate_letters(letter_count)
    random_letters = []

    # 20% must be vowels
    vowels_count = (letter_count * 0.2).round
    remaining_count = letter_count - vowels_count
    vowels_count.times { random_letters << "AEIOU".chars.sample }
    remaining_count.times { random_letters << ("A".."Z").to_a.sample }
    # shuffle the letters before return
    random_letters.shuffle
  end

  # checks work validity
  def check_word_validity(entered_word, random_letters)
    return "empty" if entered_word.empty?
    # have to use !, match_set? returns true if there is a matcha and false if no match
    return "does_not_match_set" if !match_set?(entered_word, random_letters)
    return valid_word?(entered_word, random_letters) ? "valid_word" : "invalid_word"
  end

  def match_set?(entered_word, random_letters)
    random_letters_array = random_letters.chars
    # iterate through each letter of the entered word
    entered_word.upcase.chars.each do |letter|
      # delete matching element from set of random letters if a match is found
      if random_letters_array.include?(letter)
        # using .index to find the first matching element and deletes it
        # not using .dex will delete all matched elements at once
        random_letters_array.delete_at(random_letters_array.index(letter))
      else
        # return false indicating invalid match with the user's entered word
        return false
      end
    end
    # if the flow hits this line it means the entered word matches with the set of random letters
    return true
  end

  def valid_word?(entered_word, random_letters)
    word_url = "https://wagon-dictionary.herokuapp.com/#{entered_word}"
    word_serialized = URI.open(word_url).read
    # sample returned json: {"found"=>true, "word"=>"test", "length"=>4}
    returned_json = JSON.parse(word_serialized)
    returned_json["found"]
  end
end
