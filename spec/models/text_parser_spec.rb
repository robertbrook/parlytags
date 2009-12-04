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
    
    it 'should concatenate adjacent capital words together' do
      test_text = "Something about Price Waterhouse Cooper. Or something!"
      parser = TextParser.new(test_text)
      parser.search_terms.should == ["Something", "Price Waterhouse Cooper", "Or"]
    end
    
    it 'should create an array of capitalised words from the text' do
      @parser.search_terms.should == ["That", "House", "Union of Communication Workers", "Cleveland", "Darlington", "Durham", "Consigna"]
    end
  end
end