require 'minitest/autorun'
require 'kenexa'

class TestIntegration < MiniTest::Unit::TestCase

  def test_jobs
    client = Kenexa::Client.new
    jobs = client.jobs
    job = jobs.first

    assert_equal 50, jobs.size
    assert_equal 'Door Attendant', job.title
    assert_equal 'https://sjobs.brassring.com/1033/ASP/TG/cim_jobdetail.asp?partnerid=25152&siteid=5244&jobid=217790', job.url
  end

end
