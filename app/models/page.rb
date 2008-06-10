class Page < ActiveRecord::Base
  
  class MissingSiteError < StandardError
    def initialize(message = "Missing Site - I can't find the Site your search implies"); super end
  end

end
