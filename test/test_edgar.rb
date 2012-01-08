require 'test/unit'
require 'edgar'

class EdgarTest < Test::Unit::TestCase
  def test_set_referer
    e = Edgar.new('ref')
    assert_equal 'ref', e.referer
  end

  # requires internet connectivity
  def test_get_search_response
    e = Edgar.new('example.com')
    assert_equal false, e.search('nano fibers').empty?
  end

  # requires internet connectivity
  def test_get_num_search_response
    e = Edgar.new('example.com', 10)
    assert_equal 10, e.search('nano fibers').length
  end

  # requires internet connectivity
  def test_work_with_fewer_than_limit_returned
    e = Edgar.new('example.com')
    # if 'helicoid' returns >= 100 results this test is trivial
    assert_equal false, e.search('helicoid').empty?
  end

  # TODO test this 
  def test_return_nil_on_error
    e = Edgar.new('example.com', 10)
  end

  # requires internet connectivity
  def test_return_empty_if_not_results
    e = Edgar.new('example.com')
    # if 'Ambiogenesis568' returns results this test is trivial
    assert_equal true, e.search('Ambiogenesis568').empty?
  end
end

