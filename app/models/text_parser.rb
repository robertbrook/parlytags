class TextParser
  attr  :text, true
  
  def initialize(input_text)
    @text = input_text
  end

  def words
    if text.blank?
      return nil
    else
      return text.split(" ")
    end
  end
  
  def terms
    if words.nil?
      return []
    end
    found_terms = []
    words_used = []
        
    for i in 0..words.length-1
      term = ""
      unless already_used(words_used, i)
        word = words[i]
        if valid_word?(word)
          term = word
                
          #check the words that follow...
          unless trailing_punctuation?(word)
            next_offset = i+1
            next_word = words[next_offset]
            while within_term_phrase?(words, next_offset)
              term = "#{term} #{next_word}"
              words_used << next_offset
              next_offset += 1
              next_word = words[next_offset]
            end
          end
        
          #make sure term has been set before trying to add it!
          if valid_term?(term)
            term = remove_punctuation(term)
            found_terms << term unless found_terms.include?(term)
          end
        end
      end
    end
    
    found_terms
  end
  
  private
    def remove_punctuation input
      input.gsub!(',', ' ')
      input.gsub!(';', ' ')
      input.gsub!('.', ' ')
      input.gsub!('!', ' ')
      input.gsub!('?', ' ')
      input.gsub!(')', ' ')
      input.gsub!('(', ' ')
      input.gsub!('"', '')
      input.gsub!("`", '')
      input.gsub!('  ', ' ')
      input.gsub!('  ', ' ')
      input.gsub!(/^&\W*/, '')
      input.gsub!(/^\'/, '')
      input.gsub!(/\'$/, '')
      input.gsub!(/\'s$/, '')
      input.strip
    end
    
    def trailing_punctuation? word
      last_char = word[-1,1]
      ".,;!?".include?(last_char) unless word == "St."
    end
    
    def already_used used, number
      used.include?(number)
    end
    
    def joining_word? word
      joining_words = ["of", "the"]
      joining_words.include?(word)
    end
    
    def valid_word? word
      return false if word.nil?
      return false unless word.to_i == 0
      return false unless word.length > 1
      return false if is_stop_word?(word)
      remove_punctuation(word) == remove_punctuation(word).capitalize
    end
    
    def valid_term? term
      return false if term.nil?
      return false unless term.to_i == 0
      return false unless remove_punctuation(term).length > 2
      return false if is_stop_phrase?(term)
      true
    end
    
    def is_stop_word? word
      stop_words = "|That|This|"
      stop_words.include?("|#{word}|")
    end
    
    def is_stop_phrase? term
      stop_phrases = "|Government|Her Majesty's Government|Right|House|Member|Act|Right Honourable|"
      stop_phrases.include?("|#{term}|")
    end
    
    def within_term_phrase? words, current_offset
      word = words[current_offset]
      next_word = words[current_offset+1]
      if current_offset > 0
        previous_word = words[current_offset-1]
      else
        previous_word = ""
      end
      return false if trailing_punctuation?(previous_word)
      return true if valid_word?(word)
      if joining_word?(word)
        return true if valid_word?(next_word)
      end
      false
    end
end