require File.dirname(__FILE__) + '/../../spec_helper'

describe "MultiSiteHacks::StandardTags" do
  scenario :users, :home_page

  describe "Standard Tags, which should work without modification" do

    before do
      create_page "Parent" do
        create_page "Child",   :published_at => DateTime.parse('2000-1-01 08:00:00') do
          create_page "Grandchild" do
            create_page "Great Grandchild"
          end
        end
        create_page "Child 2", :published_at => DateTime.parse('2000-1-01 09:00:00')
        create_page "Child 3", :published_at => DateTime.parse('2000-1-01 10:00:00')
      end
    end

    describe '<r:find url="url">' do
      it "should change the local page to the page specified in the 'url' attribute" do
        page.should render(%{<r:find url="/parent/child/"><r:title /></r:find>}).as('Child')
      end

      it "should render an error without the 'url' attribute" do
        page.should render(%{<r:find />}).with_error("`find' tag must contain `url' attribute")
      end

      it "should render nothing when the 'url' attribute does not point to a page" do
        page.should render(%{<r:find url="/asdfsdf/"><r:title /></r:find>}).as('')
      end

      it "should render nothing when the 'url' attribute does not point to a page and a custom 404 page exists" do
        page.should render(%{<r:find url="/gallery/asdfsdf/"><r:title /></r:find>}).as('')
      end

      it "should scope contained tags to the found page" do
        page.should render(%{<r:find url="/parent/"><r:children:each><r:slug /> </r:children:each></r:find>}).as('child child-2 child-3 ')
      end

      it "should accept a path relative to the current page" do
        page(:great_grandchild).should render(%{<r:find url="../../../child-2"><r:title/></r:find>}).as("Child 2")
      end
    end

  end

  describe "Altered Standard Tag behaviour, which should be a command superset" do

    before do
#       @site_a = Site.create(:name => "Site A",
#                             :domain => "^a\.", :base_domain => "a.example.com", :position => 1)
#       page_a = @site_a.homepage; page_a.status_id = 100; page_a.save!
#       @page = page_a
#       create_page "Parent", :title => "Parent A" do
#         create_page "Child", :title => "Child A"
#       end
#       @site_b = Site.create(:name => "Site B",
#                             :domain => "^b\.", :base_domain => "b.example.com", :position => 2)
#       page_b = @site_b.homepage; page_b.status_id = 100; page_b.save!
#       @page = page_b
#       create_page "Parent", :title => "Parent B" do
#         create_page "Child", :title => "Child B"
#       end
#       @page = page_a
      create_site "A", :homepage_id => page(:home).id do
        create_page "Parent", :title => "Parent A", :slug => "parent" do
          create_page "Child", :title => "Child A", :slug => "child"
        end
      end
      create_site "B" do
        create_page "Parent B", :title => "Parent B", :slug => "parent" do
          create_page "Child B", :title => "Child B", :slug => "child"
        end
        create_page "B page"
      end
    end

    describe '<r:find url="url" site="site_domain">' do
      it "should find a page on the current site if site is not specified" do
        page(:home).should render(%{<r:find url="/parent/child/"><r:title /></r:find>}).as('Child A')
      end
      it "should not find a page on a different site if site is not specified" do
        page(:home).should render(%{<r:find url="/b-page/"><r:title /></r:find>}).as('')
      end
      it "should find page on specified site" do
        page(:home).should render(%{<r:find url="/parent/child/" site="b.example.com"><r:title /></r:find>}).as('Child B')
      end
      it "should find page on specified site, even when introspective" do
        page(:home).should render(%{<r:find url="/parent/child/" site="a.example.com"><r:title /></r:find>}).as('Child A')
      end
      it "should return nothing if specified site does not exist" do
        page(:home).should render(%{<r:find url="/parent/child/" site="x.example.com"><r:title /></r:find>}).as('')
      end
      it "should return nothing if site is found but page isn't" do
        page(:home).should render(%{<r:find url="/no/page/" site="b.example.com"><r:title /></r:find>}).as('')
      end
      
    end
  end

  private

  def page(symbol = nil)
    if symbol.nil?
      @page ||= pages(:parent)
    else
      @page = pages(symbol)
    end
    Page.current_site = @page.root.site
    @page
  end

  def site(symbol_or_id = nil)
    case symbol_or_id
    when nil
      @site ||= sites(:default)
    when Numeric
      @site = Site.find(symbol_or_id)
    else
      @site = sites(symbol_or_id)
    end
  end

  def create_site(name, attributes={})
    attributes[:name] ||= name
    clean_name = name.gsub(/[^\w]/,'x').downcase
    attributes[:domain] ||= "^#{clean_name}\."
    attributes[:base_domain] ||= "#{clean_name}.example.com"
    symbol = name.symbolize
    create_record(:site, symbol, attributes)
    current_site = site(symbol)
    unless attributes[:homepage_id]
      current_site.create_homepage
    end
    if block_given?
      old_page_id = @current_page_id
      @current_page_id = page_id(current_site.homepage)
      yield
      @current_page_id = old_page_id
    end

  end

end
