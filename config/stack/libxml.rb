package :libxml do
  description 'Lib XML 2'
  version '2.7.6'
  source "ftp://xmlsoft.org/libxml2/libxml2-#{version}.tar.gz"
  
  requires :build_essential
end


package :libxslt do
  description 'Lib XSL libraries'
  version '1.1.26'
  source "ftp://xmlsoft.org/libxslt/libxslt-#{version}.tar.gz"
  
  requires :libxml
end