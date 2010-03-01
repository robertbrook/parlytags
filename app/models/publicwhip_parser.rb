require 'hpricot'
require 'htmlentities'

class PublicwhipParser
  def parse_file file, type, log=nil
    unless log
      @log = Logger.new(STDOUT)
    else
      @log = log
    end
    
    xml = IO.read(file)
    doc = Hpricot.XML xml
    @type = type
    @log << file unless RAILS_ENV == 'test'
    
    (doc/'publicwhip').each do |publicwhip|
      handle_data(publicwhip)
    end
    @log << "\n" unless RAILS_ENV == 'test'
  end
  
  def initialize_values
    @oral_answers = false
    @bill_presentations = false
    @major_heading = ''
    @minor_heading = ''
    @titles = []
  end
  
  def handle_major_heading element
    @major_heading = element.inner_text.strip
    @minor_heading = ''
    @oral_answers = false if @major_heading == 'Point of Order'
    
    @major_heading.gsub!("\n", "")
    @major_heading = HTMLEntities.new.encode(@major_heading, :decimal)
    @major_heading.gsub!('&#9;', "")
    @major_heading.gsub!('&#8212;', "-")
    @major_heading.strip!
  end
  
  def handle_minor_heading element
    @minor_heading = element.inner_text.strip
    
    @minor_heading = @minor_heading.gsub("\n", "")
    @minor_heading = HTMLEntities.new.encode(@minor_heading, :decimal)
    
    case @minor_heading.strip
      when /(\[.*in the Chair.*\])()/
        @minor_heading.gsub!($1,"")
        @minor_heading.gsub!('&#8212;', "")
      when /^\[.* [a|A]llocated [d|D]ay\]/,
           /^New Clause/,
           /^Clause/
        @minor_heading = ''
    end
    
    @minor_heading = cleanup_text(@minor_heading)
    @minor_heading.strip!    
  end

  def handle_question element
    question_ref =  element.attributes['id']
    @question_date = ""
    if question_ref =~ /(\d{4}-\d{2}-\d{2})/
      @question_date = $1
    end
    
    questions = []
    question_text = ''
    (element/'p').each do |para|
      question_text << " #{para.inner_text}"
      questions << "[#{para.attributes['qnum']}]" if para.attributes['qnum']
    end
    
    speaker = element.attributes['speakername']
    @question_url = element.attributes['url']
    
    @question_title = "#{@major_heading} #{@minor_heading} #{questions.join(', ')} - #{speaker}"
    
    @log << "\nWRA - #{questions.join(', ')} "  unless RAILS_ENV == 'test'
    
    item = Item.new(
      :url => @question_url,
      :title => @question_title,
      :kind => 'Written Answer'
    )
    unless @question_date.blank?
      item.created_at = @question_date
      item.updated_at = @question_date
    end
    @log << "i" unless RAILS_ENV == 'test'
    
    term_extractor = TermExtractor.new(question_text)
    add_placetags(term_extractor.terms, item)

    unless item.placetags.empty?
      item.save
      @log << "s" unless RAILS_ENV == 'test'
    end
  end
  
  def handle_answer element
    title = @question_title
    
    item = Item.find_by_title_and_created_at(title, @question_date)
    unless item
      item = Item.new(
        :url => @question_url,
        :title => @question_title,
        :kind => @type
      )
      unless @question_date.blank?
        item.created_at = @question_date
        item.updated_at = @question_date
      end
    end
    @log << "i" unless RAILS_ENV == 'test'
    
    answer_text = element.inner_text
    term_extractor = TermExtractor.new(answer_text)
    add_placetags(term_extractor.terms, item)
    
    unless item.placetags.empty?
      item.save
      @log << "s" unless RAILS_ENV == 'test'
    end
  end
  
  def handle_speech element
    debate_type = @type
    
    if @type == 'WMS'
      wms_speaker_name = element.attributes['speakername']
      wms_speaker_office = element.attributes['speakeroffice']
      debate_title = "#{@major_heading} #{@minor_heading} - #{wms_speaker_name} - #{wms_speaker_office}".strip
    else
      if @oral_answers
       debate_type= "Oral Answer"
       debate_title = "Debate -"
      end
 
      unless @major_heading.blank?
        if @major_heading =~ /^BILL PRESENTED\s*(?:-)*\s*(.*)/
          debate_title = "#{$1}".strip
          @major_heading = ''
        elsif @major_heading =~ /^PETITIONS\s*(?:-)*\s*(.*)/
          debate_title = $1.strip
          debate_type = "Petition"
        else
          debate_title = "#{debate_title} #{@major_heading}".strip
        end
      end
 
      unless @minor_heading.blank?
        if debate_title.blank?
          debate_title = @minor_heading.strip
        elsif @major_heading.blank?
          debate_title = "#{debate_title} #{@minor_heading}".strip
        else
          debate_title = "#{debate_title} - #{@minor_heading}".strip
        end
      end
    end
    
    if debate_title == 'Debate -'
      debate_title = @titles.last
    else
      @titles << debate_title
    end
    
    debate_id = element.attributes['id']
    debate_date = ""
    if debate_id =~ /(\d{4}\-\d{2}\-\d{2})/
      debate_date = $1
    end
    
    debate_url = element.attributes['url']
    
    debate_text = element.inner_text.strip
    
    item = Item.find_by_title_and_kind_and_created_at(debate_title, debate_type, debate_date)
    unless item
      item = Item.new(
        :url => debate_url,
        :title => debate_title,
        :kind => debate_type
      )
      unless debate_date.blank?
        item.created_at = debate_date
        item.updated_at = debate_date
      end
      @log << "\ni" unless RAILS_ENV == 'test'
    end
    
    term_extractor = TermExtractor.new(debate_text)
    add_placetags(term_extractor.terms, item)

    unless item.placetags.empty?
      item.save
      @log << "s" unless RAILS_ENV == 'test'
    end
  end
  
  def handle_data doc_root
    initialize_values
    doc_root.traverse_element do |element|
      case element.name
        when 'oral-heading'
          @oral_answers = true
        when 'major-heading'
          handle_major_heading element
        when 'minor-heading'
          handle_minor_heading element
        when 'speech'
          handle_speech element
        when 'ques'
          handle_question element
        when 'reply'
          handle_answer element
      end
    end
  end

  
  private    
    def add_placetags terms, item
      terms.each do |term|
        places = Place.find_all_by_ascii_name_or_alternate_names(term)
        places.each do |place|
          placetag = Placetag.find_by_geoname_id(place.geoname_id)
          if placetag.nil?
            placetag = Placetag.new(:name => term)
            county = place.county_name
            placetag.county = county if county
            country = place.country_name
            placetag.country = place.country_name if country
            placetag.place_id = place.id
            placetag.geoname_id = place.geoname_id
            placetag.save
            place.has_placetag = true
            place.save
          end
          unless item.placetags.include?(placetag)
            item.placetags << placetag
            @log << "p" unless RAILS_ENV == 'test'
          end
        end
      end
    end
    
    def cleanup_text text
      text = text.gsub('&#8212;', "-")
      text = text.gsub('&#9;', "")
      text = text.gsub('&#39;', "'")
      text = text.gsub('&#34;', '"')
      text
    end
end