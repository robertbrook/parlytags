atom_feed('xmlns:openSearch' => 'http://a9.com/-/spec/opensearch/1.1/') do |feed|
  feed.title("Parlytags Search Results - Error", :type => 'html')
  feed.updated((Time.now))
  feed.openSearch(:totalResults, 1)
  feed.openSearch(:startIndex, 1)
  feed.openSearch(:itemsPerPage, 1)
  feed.entry('', :url => '', :updated => Time.now, :published => Time.now) do |entry|
    entry.title('Seach Error')
    entry.content("There were no results found for #{params[:q]}.", :type => 'html')
  end
end