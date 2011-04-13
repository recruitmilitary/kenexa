require 'minitest/autorun'
require 'kenexa'
require 'webmock'

class TestIntegration < MiniTest::Unit::TestCase

  include WebMock::API

  FIXTURE_PATH = File.dirname(__FILE__) + '/fixtures'

  def fixture(name)
    File.read(File.join(FIXTURE_PATH, name))
  end

  def setup
    stub_request(:post, "http://import.brassring.com/WebRouter/WebRouter.asmx/route").
      to_return(:status => 200, :body => fixture('search_results.xml'), :headers => {})
  end

  def test_jobs
    client = Kenexa::Client.new
    jobs = client.jobs
    job = jobs.first

    assert_equal 50, jobs.size
    assert_equal 'Door Attendant', job.title
    assert_equal 'https://sjobs.brassring.com/1033/ASP/TG/cim_jobdetail.asp?partnerid=25152&siteid=5244&jobid=217790', job.url
    assert_equal 'New York', job.city
    assert_equal 'New York', job.state
    assert_equal '14879BR',  job.internal_id
    assert_equal Date.new(2011, 4, 12), job.last_updated
  end

end
