class TextParser
  attr  :text, true
  
  def initialize(input_text)
    @text = input_text
  end

  def words
    if text.blank?
      return nil
    else
      return text.gsub("\n"," ").split(" ")
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
          unless trailing_punctuation?(word) && !(word =~ /^(?:[A-Z]\.)+$/)
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
          if valid_term?(term.strip)
            term = remove_punctuation(term)
            term = remove_final_apostrophe(term)
            subterms = term.split(" ")
            if subterms.length == 3 && subterms[1] == "and"
              found_terms << subterms[0]
              found_terms << subterms[2]
            else
              if term.include?(" and ")
                parts = term.split(" and ")
                parts.each do |part|
                  place = Place.find_all_by_ascii_name_or_alternate_names(part)
                  found_terms << part unless place.blank?
                end
              end
              if subterms.last =~ /^\d+$/
                subterms.pop
                if joining_word?(subterms.last)
                  subterms.pop
                end
                term = subterms.join(" ")
              end
              if valid_term?(term.strip)
                found_terms << term unless found_terms.include?(term)
              end
            end
          end
        end
      end
    end
    
    found_terms
  end
  
  private
    def remove_punctuation input
      output = input.strip
      output = output.gsub(',', ' ').strip unless output.nil?
      output = output.gsub(';', ' ').strip unless output.nil?
      output = output.gsub('.', ' ').strip unless output.nil?
      output = output.gsub('!', ' ').strip unless output.nil?
      output = output.gsub('?', ' ').strip unless output.nil?
      output = output.gsub(')', ' ').strip unless output.nil?
      output = output.gsub('(', ' ').strip unless output.nil?
      output = output.gsub('"', '').strip unless output.nil?
      output = output.gsub("`", '').strip unless output.nil?
      output = output.gsub('  ', ' ').strip unless output.nil?
      output = output.gsub('  ', ' ').strip unless output.nil?
      output = output.gsub(/^&\W*/, '').strip unless output.nil?
      output = output.gsub(/^\'/, '').strip unless output.nil?
      output = output.gsub(/\'$/, '').strip unless output.nil?
      return "" if output.nil?
      output
    end
    
    def remove_final_apostrophe term
      term.gsub(/\'s$/, '')
    end
    
    def trailing_punctuation? word
      last_char = word[-1,1]
      ".,;!?".include?(last_char) unless word == "St."
    end
    
    def already_used used, number
      used.include?(number)
    end
    
    def joining_word? word
      joining_words = ["of", "the", "and", "for", "le", "de"]
      joining_words.include?(word)
    end
    
    def valid_word? word
      return false if word.nil?
      return false if is_stop_word?(remove_punctuation(word))
      return true if remove_punctuation(word) =~ /^[0-9+]$/
      return true if remove_punctuation(word) =~ /^M(?:a?)c[A-Z]+[a-z]*$/
      return true if remove_punctuation(word) == remove_punctuation(word).capitalize
      return true if remove_punctuation(word) == remove_punctuation(word).upcase
      return true if remove_punctuation(word) =~ /[A-Z].*-.*/
      return remove_punctuation(word) =~ /^[A-Z][a-z]*\'[A-Z][a-z]*$/
    end
    
    def valid_term? term
      return false if term.nil?
      return false unless term.to_i == 0
      return false unless remove_punctuation(term).length > 2
      return false if is_stop_phrase?(term)
      true
    end
    
    def is_stop_word? word
      stop_words = ["That", "This", "House"]
      stop_words.include?(word)
    end
    
    def is_stop_phrase? term
      stop_phrases = ["Government", "Her Majesty's Government", "Right", "Parliament", "Member", "Members",
          "Act", "Right Honourable", "Humble Address", "Her Majesty", "Even", "Bill", "Closed", "Centre",
          "The Status", "Agency", "Address", "State", "Members of the House", "Minister", "Ministers",
          "January", "February", "March", "April", "May", "June", "July", "August", "September", "October",
          "November", "December", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "EDM", "Her Majesty's Ministers",
          "They", "They're", "That", "That'll"]
      stop_phrases.include?(term.strip)
    end
    
    def within_term_phrase? words, current_offset
      word = words[current_offset]
      next_word = words[current_offset+1]
      if current_offset > 0
        previous_word = words[current_offset-1]
      else
        previous_word = ""
      end
      return false if trailing_punctuation?(previous_word) unless previous_word =~ /^(?:[A-Z]\.)+$/
      return true if valid_word?(word)
      if joining_word?(word)
        return true if valid_word?(next_word)
        if current_offset+2 < words.length
          word_after_next = words[current_offset+2]
          return true if joining_word?(next_word) && valid_word?(word_after_next) && (word != "and" && next_word != "the")
          return true if next_word == "-" && valid_word?(word_after_next)
          return true if next_word =~ /[0-9*]/ && valid_word?(word_after_next)
        end
      end
      false
    end
end