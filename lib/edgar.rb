require 'cgi'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'result'

class Edgar 
  # API to Edgar search API
  # 
  # Example:
  #   >> Edgar.new('[Referer]').search('nano fibers')
  #   => [ #<Result:...>, ... ]
  #
  # Arguments:
  #   referer: (String)
  #   num_results: (Integer+)

  API_PATH = "http://searchwww.sec.gov/EDGARFSClient/jsp/EDGAR_MainAccess.jsp"

  attr_accessor :referer, :num_results

  def initialize(referer='', num_results=100)
    @referer = referer
    @num_results = num_results
  end
  
  def search(query)
    params = "?search_text=#{CGI.escape(query)}&sort=Date&formType=1&isAdv=true&stemming=true&numResults=#{@num_results}&numResults=#{@num_results}"
    response = open(API_PATH + params, { 'Referer' => @referer })
    return nil if response.class.superclass == Net::HTTPServerError
    doc = Nokogiri::HTML(response)
    # check that results were returned
    no_results = doc.css('#ifrm2 font.normalbold')[0]
    return [] if no_results and no_results.content == 'No Results were Found.'
    # fetch number of results so we slice properly
    num_returned = doc.css('#header td:first font.normalbold')[0].content.match(/- (\d+)/)[1].to_i
    css_types = {
      :date => 0,
      :title_url => 1,
      :abstract => 2
    }
    css_attrs = [
      '#ifrm2 tr i.blue',
      '#ifrm2 tr a.filing',
      '#ifrm2 tr i.small'
    ]
    tag_sets = doc.css(css_attrs.join(', ')).each_slice(num_returned).map do |el|
      el
    end.transpose
    tag_sets.map do |tag_set|
      Result.new({
        :title => tag_set[css_types[:title_url]].content,
        :abstract => tag_set[css_types[:abstract]].content,
        :url => tag_set[css_types[:title_url]]['href'].match(/'([^']+)'/)[1],
        :date => tag_set[css_types[:date]].content
      })
    end
  end
end

