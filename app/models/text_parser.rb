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
      unless words_used.include?(i)
        if words[i].capitalize == words[i]
        
          #don't add the 'word' if it's a number or a single character
          if words[i].to_i == 0 && words[i].length > 1
            term = words[i]
          end
        
          #check the next word...
          unless is_punctuation(words[i][-1,1])
            next_offset = i+1
            while words[next_offset] == words[next_offset].capitalize
              unless is_punctuation(term[-1,1])
                term = "#{term} #{words[next_offset]}"
                words_used << next_offset
              end
              next_offset += 1
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
end