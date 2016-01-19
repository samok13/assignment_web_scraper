require 'rubygems'
require 'mechanize'


class PageGetter

  HOME_PAGE = 'http://www.dice.com/jobs'

  attr_reader :full_page, :agent, :search_query, :jobs

  def initialize
    @agent = Mechanize.new
    @agent.history_added = Proc.new { sleep 0.5 }
    @full_page = nil
    @search_query = nil
    @jobs = []
  end

  def make_search_query(search_term, location)
    @search_query = HOME_PAGE + "?q=#{search_term}" + "&l=#{location}"
  end


  def create_jobs_array(target_url)
    @full_page = agent.get(target_url)
    all_links = @full_page.search("#serp")
    root = all_links[0]
    # p root

    stack = []
    stack << root
    while node = stack.pop
      node.children.each do |child|
        @jobs << child.attributes
        @jobs << child.children
        stack << child
      end
    end
  end


  def get_job_info
    listing = {}
    i = 0


    # until i == 29 do |jobs|
        @jobs.each_with_index do |info_block, index|
          if info_block.nil? 
            print "Nothing to evaluate."
          elsif !info_block.is_a? Hash
            print "Nothing to evaluate."
          elsif info_block['id'].nil?
              print "Nothing to evaluate."
          elsif info_block['id'].value.nil?
            print "Nothing to evaluate."
          else
            if info_block['id'].value == 'position0'
              listing['job_title'] = info_block['title'].value
              listing['link'] = info_block['href'].value
              listing['job_id'] = info_block['href'].value
            end
            if info_block['id'].value == 'company0'
              listing['company_id'] = info_block['href'].value
              listing['company_name'] = @jobs[index + 1].text
              listing['company_location'] = @jobs[index + 5].text
              listing['posting_date'] = @jobs[index + 9].text
            end
          end
        end
        print listing
  end

end

m = PageGetter.new
m.make_search_query("ruby", "francisco")
m.create_jobs_array(m.search_query)
m.get_job_info
