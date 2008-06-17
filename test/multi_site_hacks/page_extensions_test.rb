require File.dirname(__FILE__) + '/../test_helper'

class PageExtensionsTest < Test::Unit::TestCase
  test_helper :page
  
  def setup
    @site_a = Site.create(:name => "Site A",
                        :domain => "^a\.", :base_domain => "a.example.com", :position => 1)
    @page = @site_a.homepage; @page.status_id = 100; @page.save!
    @site_b = Site.create(:name => "Site B",
                        :domain => "^b\.", :base_domain => "b.example.com", :position => 2)
    page_b = @site_b.homepage; page_b.status_id = 100; page_b.save!
  end

  def test_should_find_page_on_other_site
    Page.current_site = @site_a
    kid = make_kid!(@site_b.homepage, "a_child")
    assert_equal kid, Page.find_by_url("b.example.com:/a_child")
  end
  def test_should_raise_if_site_is_implied_but_cant_be_found
    Page.current_site = @site_a
    assert_raise(Page::MissingSiteError) { Page.find_by_url("c.example.com:/") }
  end
  def test_should_return_nil_if_site_is_found_but_page_isnt
    Page.current_site = @site_a
    assert_nil Page.find_by_url("b.example.com:/not-a-page") 
  end

  # MultiSite tests, to make sure their functionality still works

  def test_should_override_url
    assert_respond_to @page, :url_with_sites
    assert_respond_to @page, :url_without_sites
    assert_equal "/", @page.url
    @page.slug = "some-slug"
    assert_equal "/", @page.url
  end
  
  def test_should_override_class_find_by_url
    assert_respond_to Page, :find_by_url_with_sites
    assert_respond_to Page, :find_by_url_without_sites
    assert_respond_to Page, :current_site
    assert_respond_to Page, :current_site=
    # Defaults should still work
    assert_nothing_raised {
      Page.current_site = nil
      assert_equal @page, Page.find_by_url("/"), 'page is not root page when no current site'
    }
    # Now find a site-scoped page
    doc_page = make_kid!(@page, "documentation")
    assert_nothing_raised {
      Page.current_site = @site_a
      assert_equal @page, Page.find_by_url("/"), 'page is not root page'
      assert_equal doc_page, Page.find_by_url("/documentation")
    }
    # Now try a site that has no homepage
    assert_raises(Page::MissingRootPageError) {
      site_b = Site.create(:name => "Site B", :domain => "^b\.", :base_domain => "b.example.com")
      Page.delete(site_b.homepage)
      site_b.homepage = nil
      Page.current_site = site_b
      Page.find_by_url("/")
    }
  end
  
  def test_should_nullify_site_homepage_id_on_destroy
    assert_not_nil @site_a.homepage_id
    @page.destroy
    assert_nil @site_a.reload.homepage_id
  end
  
  def test_should_not_nullify_site_homepage_id_on_destroy_if_not_site_root_page
    kid = make_kid!(@page, 'sub')
    kid.destroy
    assert_not_nil @site_a.reload.homepage_id, 'homepage id should not be nullifed by deleted child page'
  end

  protected

  def setup_page(page)
    @page = page
    @context = PageContext.new(@page)
    @parser = Radius::Parser.new(@context, :tag_prefix => 'r')
    @page
  end

  def assert_parse_output(expected, input, msg=nil)
    output = @parser.parse(input)
    assert_equal expected, output, msg
  end

  def make_page!(title)
    p = Page.find_or_create_by_title(title)
    p.slug, p.breadcrumb = title.downcase, title
    p.parts.find_or_create_by_name("body")
    p.status_id = 100
    p.save!
    p
  end
  def make_kid!(page, title)
    kid = make_page!(title)
    page.children << kid
    page.save!
    kid
  end
  def make_kids!(page, *kids)
    kids.collect {|kid| make_kid!(page, kid) }
  end

end
