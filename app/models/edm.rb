class Edm < ActiveRecord::Base
  # has_one :proposer
  # has_many :signatories
  
end


# class Appearance < ActiveRecord::Base
#   belongs_to :dancer
#   belongs_to :movie
# end
# 
# class Dancer < ActiveRecord::Base
#   has_many :appearances, :dependent => true
#   has_many :movies, :through => :appearances
# end
# 
# class Movie < ActiveRecord::Base
#   has_many :appearances, :dependent => true
#   has_many :dancers, :through => :appearances
# end