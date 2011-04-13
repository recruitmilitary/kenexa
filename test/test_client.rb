require 'minitest/autorun'
require 'kenexa'
require 'webmock'

class TestIntegration < MiniTest::Unit::TestCase

  include WebMock::API

  FIXTURE_PATH = File.dirname(__FILE__) + '/fixtures'

  def fixture(name)
    File.read(File.join(FIXTURE_PATH, name)).chomp
  end

  def setup
    stub_request(:post, "http://import.brassring.com/WebRouter/WebRouter.asmx/route").
      with(:body => fixture('page_1_request.xml')).
      to_return(:status => 200, :body => fixture('search_results.xml'), :headers => {})

    stub_request(:get, "https://sjobs.brassring.com/1033/ASP/TG/cim_jobdetail.asp?jobid=217790&partnerid=25152&siteid=5244").
      to_return(:status => 200, :body => fixture('job_details.html'), :headers => {})
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
    assert_equal "\302\240\302\240Looking for a stable position with flexible shifts at one of America's most respected apartment companies? Our Full-time Door Attendant position is a perfect opportunity for someone who enjoys the balance between customer service and periods of quiet. This job can be a great first step to a bright future, or it can be a perfect job for anyone looking for a friendly, low-stress job.\302\240Job Description\302\240Responsibilities include opening the door for all residents and guests; warmly greeting everyone entering and leaving the building; hailing taxi cabs; answering resident questions; helping elderly or others in need of assistance into cars or taxi cabs; maintaining a clean front entry to the building; notifying residents of the arrival of cars, packages or visitors; preventing unwelcome individuals from entering the building; and any other services required for maintaining a first-class level of resident service, care and safety. Must enjoy helping people. A professional, friendly attitude is important.\302\240Requirements Be willing to join the local union Exceptional communication and people skills (you love interacting with a range of personalities!) Friendly, polite personality Self-motivated; can work independently Willingess to join local union Must be willing and able to work the following schedule: Saturday/Sunday 6:30 a.m. - 3:00 p.m., Monday/Tuesday 2:30 p.m. - 11:00 p.m., Wednesday 10:30 p.m. - 7:00 a.m.Why You'd Want This Job Low stress, steady work with set shifts Great benefits, including excellent health care and paid vacation Opportunities for advancement with a well-respected national company (One of America's Most Admired Companies - Fortune magazine 2004) To learn more about Archstone, visit our website at ArchstoneApartments.com.\302\240Archstone is an Equal Opportunity Employer. As a condition of employment, a satisfactory hair follicle drug test and background check are required. Make your talents known! Apply today!\302\240\302\240", job.description
  end

end
