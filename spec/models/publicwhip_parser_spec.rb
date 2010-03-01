require File.dirname(__FILE__) + '/../spec_helper.rb'

describe PublicwhipParser do
  before do
    @parser = PublicwhipParser.new
  end

  describe 'when parsing written answers' do
    it 'should create a new item for each question, but not save it when no place data is found' do
      item1 = mock_model(Item, :id => 1)
      item2 = mock_model(Item, :id => 2)
      file = RAILS_ROOT + '/spec/fixtures/wra-no-place-data.xml'

      Item.should_receive(:new).with(
        :title => 'ENVIRONMENT FOOD AND RURAL AFFAIRS Departmental Advertising [309933] - Grant Shapps',
        :kind => 'Written Answer',
        :url => 'http://www.publications.parliament.uk/pa/cm200910/cmhansrd/cm100201/text/100201w0002.htm#10020115000341').and_return(item1)
      item1.should_receive(:created_at=).with('2010-02-01')
      item1.should_receive(:updated_at=).with('2010-02-01')
      Item.should_receive(:find_by_title_and_created_at).with('ENVIRONMENT FOOD AND RURAL AFFAIRS Departmental Advertising [309933] - Grant Shapps', '2010-02-01').and_return(item1)

      item1.should_receive(:placetags).exactly(2).times.and_return([])

      Item.should_receive(:new).exactly(2).times.with(
        :title => 'ENVIRONMENT FOOD AND RURAL AFFAIRS Departmental Billing [311259] - John Mason',
        :kind => 'Written Answer',
        :url => 'http://www.publications.parliament.uk/pa/cm200910/cmhansrd/cm100201/text/100201w0002.htm#10020115000343').and_return(item2)
      item2.should_receive(:created_at=).with('2010-02-01').exactly(2).times
      item2.should_receive(:updated_at=).with('2010-02-01').exactly(2).times
      Item.should_receive(:find_by_title_and_created_at).with('ENVIRONMENT FOOD AND RURAL AFFAIRS Departmental Billing [311259] - John Mason', '2010-02-01').and_return(nil)
      item2.should_receive(:placetags).exactly(2).times.and_return([])

      @parser.parse_file file, "Written Answer"
    end

    it 'should create an item for each question and placetags for each matching place' do
      item1 = mock_model(Item)
      place1 = mock_model(Place, :geoname_id => 1234, :county_name => nil, :country_name => 'England')
      place2 = mock_model(Place, :geoname_id => 2222, :county_name => 'London', :country_name => 'England')
      placetag1 = mock_model(Placetag)
      placetag2 = mock_model(Placetag)
      
      file = RAILS_ROOT + '/spec/fixtures/wra-with-place-data.xml'
      
      Item.should_receive(:new).with(
        :title => 'CULTURE MEDIA AND SPORT National Lottery: Bexley [314679] - David Evennett',
        :kind => 'Written Answer',
        :url => 'http://www.publications.parliament.uk/pa/cm200910/cmhansrd/cm100201/text/100201w0003.htm#10020115000363').and_return(item1)
      item1.should_receive(:created_at=).with('2010-02-01')
      item1.should_receive(:updated_at=).with('2010-02-01')
      
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with('Secretary of State for Culture').and_return([])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with('Media').and_return([])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with('Sport').and_return([])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).exactly(2).times.with('Big Lottery Fund').and_return([])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with('London').and_return([place1])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with('Bexley').and_return([place2])
      Placetag.should_receive(:new).with(:name => 'London').and_return(placetag1)
      Placetag.should_receive(:new).with(:name => 'Bexley').and_return(placetag2)
      placetag2.should_receive(:county=).with('London')
      placetag1.should_receive(:country=).with('England')
      placetag2.should_receive(:country=).with('England')
      placetag1.should_receive(:place_id=).with(place1.id)
      placetag2.should_receive(:place_id=).with(place2.id)
      placetag1.should_receive(:geoname_id=).with(1234)
      placetag2.should_receive(:geoname_id=).with(2222)
      placetag1.should_receive(:save)
      placetag2.should_receive(:save)
      place1.should_receive(:has_placetag=).with(true)
      place2.should_receive(:has_placetag=).with(true)
      place1.should_receive(:save)
      place2.should_receive(:save)
      item1.should_receive(:placetags).exactly(6).times.and_return([])
      item1.should_receive(:save).exactly(2).times
      
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Member for Bexleyheath").and_return([])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Crayford").and_return([])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("The").and_return([])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Department").and_return([])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Accordingly").and_return([])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Member for Bexleyheath and Crayford").and_return([])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Copies").and_return([])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Libraries").and_return([])
      Place.should_receive(:find_all_by_ascii_name_or_alternate_names).with("Houses").and_return([])
   
      Item.should_receive(:find_by_title_and_created_at).with('CULTURE MEDIA AND SPORT National Lottery: Bexley [314679] - David Evennett', '2010-02-01').and_return(item1)
      
      @parser.parse_file file, "Written Answer"
    end
  end

  describe 'when parsing Westminster Hall debates' do
    it 'should create a new item for each debate, but not save it when no place data is found' do
      file = RAILS_ROOT + '/spec/fixtures/westminster-no-place-data.xml'
      
      item1 = mock_model(Item, :id => 1)

      Item.should_receive(:new).with(
        :title => 'Fuel Duty (Rural Areas)',
        :kind => 'Westminster Hall Debate',
        :url => 'http://www.publications.parliament.uk/pa/cm200910/cmhansrd/cm100210/halltext/100210h0001.htm#10021066000001').and_return(item1)
      item1.should_receive(:created_at=).exactly(2).times.with('2010-02-10')
      item1.should_receive(:updated_at=).exactly(2).times.with('2010-02-10')
      item1.should_receive(:placetags).exactly(2).times.and_return([])

      Item.should_receive(:new).with(
        :title => 'Fuel Duty (Rural Areas)',
        :kind => 'Westminster Hall Debate',
        :url => 'http://www.publications.parliament.uk/pa/cm200910/cmhansrd/cm100210/halltext/100210h0001.htm#10021066000546').and_return(item1)

      @parser.parse_file file, "Westminster Hall Debate"
    end
  end
end