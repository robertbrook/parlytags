atom_feed('xmlns:openSearch' => 'http://a9.com/-/spec/opensearch/1.1/') do |feed|
  feed.title("Parlytags Search Results", :type => 'html')
  feed.updated((Time.now))

  feed.openSearch(:totalResults, @results.count)
  feed.openSearch(:startIndex, 1)
  feed.openSearch(:itemsPerPage, 1, @results.count)
  feed.openSearch(:Query, :role => 'request', :searchTerms => @last_search_term)
  
  feed.link(:rel => 'search', :href => "http://#{request.host_with_port}/search.xml", :type => 'application/opensearchdescription+xml')  
  
  for result in @results
     feed.entry(result, :url => result.url, :updated => Time.now, :published => result.created_at) do |entry|
       entry.title(result.title, :type => 'html')
     end
  end
end