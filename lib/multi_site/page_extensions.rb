module MultiSite::PageExtensions::ClassMethods
  def find_by_url_with_sites(url, live=true)
    root = nil
    if self.current_site.is_a?(Site)
      root, url = site_root_and_url_from_url_or_current_site(url)
    else
      root = find_by_parent_id(nil)
    end
    raise Page::MissingRootPageError unless root
    root.find_by_url(url, live)
  end
  
  # def url_with_sites
  #   if parent
  #     parent.child_url(self)
  #   else
  #     "/"
  #   end
  # end

  private

  def site_root_and_url_from_url_or_current_site(url)
    site = nil
    if url.match(/(.+):(.+)/)
      site, url = Site.find_by_base_domain($1), $2
    end
    if site
      [site.homepage, url]
    else
      [self.current_site.homepage, url]
    end
  end
end