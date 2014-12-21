# Monkey patching Jekyll::Pagination.

module Jekyll

  # This is probably obsolete soon, once 
  # https://github.com/mojombo/jekyll/commit/725b127f9b9ad6e7d6dacf33038c544c111204ab
  # hits the general public.
  class Page
    def subdir
      @dir
    end
  end

  class Pagination

    def generate(site)
      site.pages.dup.each do |page|
        paginate(site, page) if Pager.pagination_enabled?(site.config, page)
      end
    end

    def paginate(site, page)
      category = page.data['pagination_category']
      all_posts = site.site_payload['site']['posts'].select! { |p| p.data['category'] == category }

      pages = Pager.calculate_pages(all_posts, site.config['paginate'].to_i)
      (1..pages).each do |num_page|
        pager = Pager.new(site.config, num_page, all_posts, pages)
        if num_page > 1
          newpage = Page.new(site, site.source, page.subdir, page.name)
          newpage.pager = pager
          newpage.dir = File.join(page.dir, paginate_path(site, page, num_page))
          site.pages << newpage
        else
          page.pager = pager
        end
      end
    end

  private

    def paginate_path(site, page, num_page)
      format = site.config['paginate_path']
      format.sub(':num', num_page.to_s).prepend(page.data['pagination_category'] + "_")
    end

  end

  class Pager
    def self.pagination_enabled?(config, page)
      page.name == 'index.html' && !config['paginate'].nil? && !page.data['pagination_category'].nil?
    end
  end
end
