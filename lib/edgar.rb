require 'cgi'
require 'rubygems'

require 'nokogiri'
require 'open-uri'

EdgarResult = Struct.new :title, :abstract, :url, :date

class Edgar
  # API to Edgar search API
  #
  # Example:
  #   >> Edgar.new('[Referer]').search('nano fibers')
  #   => [ #<EdgarResult:...>, ... ]
  #
  # Arguments:
  #   referer: (String)
  #   num_results: (Integer+)

  API_PATH = 'https://searchwww.sec.gov/EDGARFSClient/jsp/EDGAR_MainAccess.jsp'
  CSS_ATTRS = [
    '#ifrm2 tr i.blue',
    '#ifrm2 tr a.filing',
    '#ifrm2 tr i.small'
  ]
  CSS_TYPES = {
    :date => 0,
    :title_url => 1,
    :abstract => 2
  }

  attr_accessor :referer, :num_results

  def initialize(referer = '', num_results = 100)
    @referer = referer
    @num_results = num_results
  end

  def search(query)
    params = "?search_text=#{CGI.escape(query)}&sort=Date&formType=1&isAdv=true&stemming=true&numResults=#{@num_results}"
    response = open(API_PATH + params, 'Referer' => @referer)
    return nil if response.class.superclass == Net::HTTPServerError
    doc = Nokogiri::HTML(response)
    # check that results were returned
    no_results = doc.css('#ifrm2 font.normalbold')[0]
    return [] if no_results && no_results.content == 'No Results were Found.'
    # fetch number of results so we slice properly
    num_returned = doc.css('#header td:first > font.normalbold')[0]
    return [] if num_returned.nil?
    num_returned = num_returned.content.match(/- (\d+)/)[1].to_i
    build_results(doc, num_returned)
  end

  private

  def build_results(doc, num_returned)
    tag_sets = doc.css(CSS_ATTRS.join(', ')).each_slice(num_returned)
    tag_sets = safe_transpose(tag_sets)
    tag_sets.map do |tag_set|
      EdgarResult.new(
        get_tag(tag_set, :title_url),
        get_tag(tag_set, :abstract),
        get_url(tag_set),
        get_tag(tag_set, :date)
      )
    end
  end

  def get_url(tag_set)
    node = tag_set[CSS_TYPES[:title_url]]
    href = node && node['href']
    href && href.match(/'([^']+)'/)[1] || ''
  end

  def get_tag(tag_set, key)
    node = tag_set[CSS_TYPES[key]]
    node && node.content || ''
  end

  def safe_transpose(a)
    max_size = a.map(&:size).max
    a.dup.map do |r|
      r << nil while r.size < max_size
      r
    end.transpose
  end
end
