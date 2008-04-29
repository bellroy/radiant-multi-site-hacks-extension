class Page < ActiveRecord::Base
  
  class MissingSiteError < StandardError
    def initialize(message = "Missing Site - I can't find the Site your search implies"); super end
  end

  def site_with_root_site
    root.site_without_root_site
  end
  alias_method_chain :site, :root_site
  
end
