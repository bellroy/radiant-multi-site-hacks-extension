# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class MultiSiteHacksExtension < Radiant::Extension
  version "1.0"
  description "Adds some useful extensions to the multi_site extension."
  url "http://code.trike.com.au/svn/radiant/extensions/multi_site_hacks"
  
  def activate
    # require File.join(File.dirname(__FILE__), "lib/multi_site_hacks/page_extensions.rb")
    Page.send :include, MultiSiteHacks::StandardTags
  end
  
end
