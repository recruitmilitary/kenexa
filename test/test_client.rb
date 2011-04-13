require 'minitest/autorun'
require 'kenexa'

class TestIntegration < MiniTest::Unit::TestCase

  def test_jobs
    client = Kenexa::Client.new
    jobs = client.jobs

    assert_equal 50, jobs.size
  end

end
