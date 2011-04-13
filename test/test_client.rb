require 'minitest/autorun'
require 'kenexa'

class TestIntegration < MiniTest::Unit::TestCase

  def test_jobs
    client = Kenexa::Client.new
    jobs = client.jobs
    job = jobs.first

    assert_equal 50, jobs.size
    assert_equal "Door Attendant", job.title
  end

end
