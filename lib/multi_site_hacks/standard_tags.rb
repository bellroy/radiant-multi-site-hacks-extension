module MultiSiteHacks::StandardTags
  include Radiant::Taggable

  class TagError < StandardError; end

  desc %{
    Inside this tag all page related tags refer to the page found at the @url@ attribute.  
    @url@s may be relative or absolute paths.
    @site@s will only exist if the multi_site extension is installed
    
    *Usage:*
    <pre><code><r:find url="value_to_find" [site="base_domain_of_site_to_search"]>...</r:find></code></pre>
  }
  tag 'find' do |tag|
    url = tag.attr['url']
    raise TagError.new("`find' tag must contain `url' attribute") unless url
    
    found = nil
    if tag.attr['site'] && Page.current_site.is_a?(Site)
      search_site = Site.find_by_base_domain(tag.attr['site'])

      if search_site
        old_current_site = Page.current_site
        begin
          Page.current_site = search_site
          found = Page.find_by_url(absolute_path_for(tag.locals.page.url, url))
        ensure
          Page.current_site = old_current_site
        end
      end
    else
      found = Page.find_by_url(absolute_path_for(tag.locals.page.url, url))
    end
    if page_found?(found)
      tag.locals.page = found
      tag.expand
    end
  end

  private

    def page_found?(page)
      page && !(FileNotFoundPage === page)
    end

end
