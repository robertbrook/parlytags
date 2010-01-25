require File.dirname(__FILE__) + '/../spec_helper.rb'

describe TextParser do
  describe 'when parsing text from an Edm' do
    before do
      #Using a mockup of an actual Edm - number 624 from the 2000-2001 session for our test
      #http://localhost:3000/2000-2001/edms/624
      @edm = mock_model(Edm, 
        :title => 'Postal Workers', 
        :number => '624', 
        :text => 'That this House notes and praises the unstinting work of postal workers in delivering election addresses; further notes that the Union of Communication Workers has been successful in a number of regions of the UK in getting financial recognition for that extra work in the shape of delivery bonuses of 2 pence per item; further notes that this is not the case in the Cleveland, Darlington and Durham area; and calls on the regional managers of Consigna for that area to think again and re-open positive negotiations with the Union of Communication Workers in the interests of the morale and loyalty of their staff.'
      )
      @parser = TextParser.new(@edm.text)
    end
    
    it 'should set text to the text of the Edm' do
      @parser = TextParser.new(@edm.text)
      @parser.text.should == @edm.text
    end
    
    it 'should create an array of words from the text' do
      test_text = "The cat sat on the mat"
      parser = TextParser.new(test_text)
      parser.words.should == test_text.split(" ")
      parser.words.should be_an(Array)
    end
    
    it 'should create an empty array of words from the text if no terms exists' do
      test_text = "something about nothing in particular. nothing to see here!"
      parser = TextParser.new(test_text)
      parser.search_terms.should == []
    end 
    
    it 'should concatenate adjacent capital words together' do
      test_text = "Something about Price Waterhouse Cooper. Or something!"
      parser = TextParser.new(test_text)
      parser.terms.should == ["Something", "Price Waterhouse Cooper"]
    end
    
    it 'should create an array of capitalised words from the text' do
      @parser.terms.should == ["That", "House", "Union of Communication Workers", "Cleveland", "Darlington", "Durham", "Consigna"]
    end
  end
  
  describe 'when extracting a list of terms' do
    it 'should exclude terms shorter than 3 characters' do
      parser = TextParser.new("It should work As Expected")
      parser.terms.should == ["As Expected"]
    end
    
    it 'should exclude terms that will be shorter than 3 characters with puncutation removed' do
      parser = TextParser.new("`a' hat")
      parser.terms.should == []
    end
    
    it 'should return an empty array when passed blank text' do
      parser = TextParser.new("")
      parser.terms.should == []
    end
    
    it 'should not include lower case words wrapped with punctuation' do
      parser = TextParser.new("'and the thing shouldn't break at this point")
      parser.terms.should == []
      parser = TextParser.new("(and neither should This Example)")
      parser.terms.should == ["This Example"]
    end
    
    it 'should not include terms that start with html escaped values' do
      parser = TextParser.new('&pound700 for')
      parser.terms.should == []
      parser = TextParser.new('&pound;1,000,000')
      parser.terms.should == []
    end
    
    it 'should remove trailing single quotes' do
      parser = TextParser.new("Government Management Network'")
      parser.terms.should == ["Government Management Network"]
    end
    
    it 'should remove apostrophe s from the end of the term string' do
      parser = TextParser.new("Prime Minister's")
      parser.terms.should == ["Prime Minister"]
    end
    
    it 'should retain apostrophe s in the middle of a term string' do
      parser = TextParser.new("St. Thomas's Hospital")
      parser.terms.should == ["St Thomas's Hospital"]
    end
    
    it 'should have a spec for previous_word in within_term_phrase'
    
  end
end