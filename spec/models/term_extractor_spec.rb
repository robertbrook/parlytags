require File.dirname(__FILE__) + '/../spec_helper.rb'

describe TermExtractor do
  describe 'when parsing text' do
    it 'should create an array of words from the text' do
      test_text = "The cat sat on the mat"
      parser = TermExtractor.new(test_text)
      parser.words.should == test_text.split(" ")
      parser.words.should be_an(Array)
    end
    
    it 'should create an empty array of words from the text if no terms exists' do
      test_text = "something about nothing in particular. nothing to see here!"
      parser = TermExtractor.new(test_text)
      parser.terms.should == []
    end 
    
    it 'should concatenate adjacent capital words together' do
      test_text = "Something about Price Waterhouse Cooper. Or something!"
      parser = TermExtractor.new(test_text)
      parser.terms.should == ["Something", "Price Waterhouse Cooper"]
    end
    
    it 'should create an array of capitalised words from the text' do
      parser = TermExtractor.new('That this House notes and praises the unstinting work of postal workers in delivering election addresses; further notes that the Union of Communication Workers has been successful in a number of regions of the UK in getting financial recognition for that extra work in the shape of delivery bonuses of 2 pence per item; further notes that this is not the case in the Cleveland, Darlington and Durham area; and calls on the regional managers of Consigna for that area to think again and re-open positive negotiations with the Union of Communication Workers in the interests of the morale and loyalty of their staff.')
      parser.terms.should == ["Union of Communication Workers", "Cleveland", "Darlington", "Durham", "Consigna"]
    end
  end
  
  describe 'when extracting a list of terms' do
    it 'should exclude terms shorter than 3 characters' do
      parser = TermExtractor.new("It should work As Expected")
      parser.terms.should == ["As Expected"]
    end
    
    it 'should exclude terms that will be shorter than 3 characters with puncutation removed' do
      parser = TermExtractor.new("`a' hat")
      parser.terms.should == []
    end
    
    it 'should return an empty array when passed blank text' do
      parser = TermExtractor.new("")
      parser.terms.should == []
    end
    
    it 'should not include lower case words wrapped with punctuation' do
      parser = TermExtractor.new("'and the thing shouldn't break at this point")
      parser.terms.should == []
      parser = TermExtractor.new("(and neither should This Example)")
      parser.terms.should == ["Example"]
    end
    
    it 'should not include terms that start with html escaped values' do
      parser = TermExtractor.new('&pound700 for')
      parser.terms.should == []
      parser = TermExtractor.new('&pound;1,000,000')
      parser.terms.should == []
    end
    
    it 'should remove trailing single quotes' do
      parser = TermExtractor.new("Government Management Network'")
      parser.terms.should == ["Government Management Network"]
    end
    
    it 'should remove apostrophe s from the end of the term string' do
      parser = TermExtractor.new("Prime Minister's")
      parser.terms.should == ["Prime Minister"]
    end
    
    it 'should retain apostrophe s in the middle of a term string' do
      parser = TermExtractor.new("St. Thomas's Hospital")
      parser.terms.should == ["St Thomas's Hospital"]
      parser = TermExtractor.new("Guy's and Lewisham Mental Health Trust")
      parser.terms.should == ["Guy's and Lewisham Mental Health Trust"]
    end
    
    it 'should not return duplicate phrases' do
      parser = TermExtractor.new("the Phrase One, something something Phrase One")
      parser.terms.should == ["Phrase One"]
    end
    
    it 'should return hyphenated place names' do
      parser = TermExtractor.new("the London Borough of Richmond-upon-Thames")
      parser.terms.should == ["London Borough of Richmond-upon-Thames"]
    end
    
    it 'should return terms containing an isolated hyphen' do
      parser = TermExtractor.new("making One Point - Then Another and so on")
      parser.terms.should == ["One Point - Then Another"]
    end
    
    it 'should deal with company names such as Mercury One 2 One' do
      parser = TermExtractor.new("Mercury One 2 One")
      parser.terms.should == ["Mercury One 2 One"]
    end
    
    it 'should not include Minister as a term' do
      parser = TermExtractor.new("and calls on the Health and Safety Executive, the Minister and the railway watchdogs ")
      parser.terms.should == ["Health and Safety Executive"]
    end
    
    it 'should return names that include an apostrophe' do
      parser = TermExtractor.new("Joyce D'Silva")
      parser.terms.should == ["Joyce D'Silva"]
    end
    
    it 'should exclude numbers from the end of terms' do
      parser = TermExtractor.new("Conservative supporters, 64 per cent. of Lib Dem and 55 per cent")
      parser.terms.should == ["Conservative", "Lib Dem"]
    end
    
    it 'should exclude month and year from terms' do
      parser = TermExtractor.new("this scheme was established in April 1996")
      parser.terms.should == []
    end
    
    it 'should include words in all caps' do
      parser = TermExtractor.new("the OFSTED Report")
      parser.terms.should == ["OFSTED Report"]
    end
    
    it 'should cope without an Oxford Comma' do
      parser = TermExtractor.new("England, Wales and Northern Ireland")
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Wales").and_return([mock_model(Place)])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Northern Ireland").and_return([mock_model(Place)])
      
      parser.terms.should == ["England", "Wales", "Northern Ireland", "Wales and Northern Ireland"]
    end
    
    it 'should handle initials correctly' do
      parser = TermExtractor.new("Mr C.M.J. Matthews")
      parser.terms.should == ["Mr C M J Matthews"]
    end
    
    it 'should handle text starting with "Mc"' do
      parser = TermExtractor.new("Mr C.M.J. McMatthews")
      parser.terms.should == ["Mr C M J McMatthews"]
    end
    
    it 'should handle text starting with "Mac"' do
      parser = TermExtractor.new("Mr C.M.J. MacMatthews")
      parser.terms.should == ["Mr C M J MacMatthews"]
    end
    
    it 'should not allow "and the" as a joining phrase' do
      parser = TermExtractor.new("immediate action to prevent Mr C.M.J. Matthews and the MAFF vet Mr Whyte from continuing")
      parser.terms.should == ["Mr C M J Matthews", "MAFF", "Mr Whyte"]
    end
    
    it 'should not allow terms ending with and' do
      parser = TermExtractor.new("Mr C M J Matthews and")
      parser.terms.should == ["Mr C M J Matthews"]
    end
    
    it 'should not allow terms starting with "Between"' do
      parser = TermExtractor.new("Between 1 and 17 January")
      parser.terms.should == []
    end
    
    it 'should not include the term "Our"' do
      parser = TermExtractor.new("Our favourite")
      parser.terms.should == []
    end
    
    it 'should not include the term "London \'"' do
      parser = TermExtractor.new("concessionary fares in London.'.")
      parser.terms.should == ["London"]
    end
    
    it 'should not include the term How when it is at the beginning of a sentence' do
      parser = TermExtractor.new("in How, Cumbria")
      parser.terms.should == ["How", "Cumbria"]
      
      parser = TermExtractor.new("How did this happen?")
      parser.terms.should == []
    end
  end
end