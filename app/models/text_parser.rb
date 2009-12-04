class TextParser
  attr  :text, true
  
  def initialize(input_text)
    @text = input_text
  end

  def words
    text.split(" ")
  end
  
  def search_terms
    terms = []
    words_used = []
        
    for i in 0..words.length-1
      term = ""
      unless already_used(words_used, i)
        word = words[i]
        if word.capitalize == word
        
          #don't add the 'word' if it's a number or a single character
          if word.to_i == 0 && word.length > 1
            term = word
          end
        
          #check the following words...
          unless is_punctuation(word[-1,1])
            next_offset = i+1
            next_word = words[next_offset]
            while (next_word == next_word.capitalize) || (is_joining_word(next_word) && words[next_offset+1] == words[next_offset+1].capitalize)
              unless is_punctuation(term[-1,1])
                term = "#{term} #{next_word}"
                words_used << next_offset
              end
              next_offset += 1
              next_word = words[next_offset]
            end
          end
        
          #make sure term has been set before trying to add it!
          if term != ""
            terms << term unless terms.include?(term)
          end
        end
      end
    end
    
    all_terms = terms.join("^")
    all_terms = remove_punctuation(all_terms)
    all_terms.gsub!(" ^", "^")
    
    if all_terms
      terms = all_terms.split("^")
    else
      terms = []
    end
    terms
  end
  
  private
    def remove_punctuation input
      input.gsub!(',', ' ')
      input.gsub!(';', ' ')
      input.gsub!('.', ' ')
      input.gsub!('!', ' ')
      input.gsub!('?', ' ')
      input
    end
    
    def is_punctuation input
      ",.,;!?".include?(input)
    end
    
    def already_used used, number
      used.include?(number)
    end
    
    def is_joining_word word
      joining_words = ["of", "the"]
      joining_words.include?(word)
    end
end