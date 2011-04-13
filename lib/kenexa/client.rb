require 'net/http'
require 'uri'
require 'open-uri'
require 'erb'
require 'date'
require 'nokogiri'

module Kenexa

  class Client

    DEFAULT_ENDPOINT = 'http://import.brassring.com/WebRouter/WebRouter.asmx/route'

    TEMPLATE_PATH = File.dirname(__FILE__) + "/templates"

    def initialize(endpoint = DEFAULT_ENDPOINT)
      @uri = URI.parse(endpoint)
    end

    def jobs(options = {})
      page = options[:page] || 1
      template = ERB.new(File.read(TEMPLATE_PATH + "/request.erb"))
      inputXml = template.result(binding)
      response = Net::HTTP.post_form(@uri, "inputXml" => inputXml)
      doc = Nokogiri::XML response.body

      # i'm not sure what is up with the response that comes back, but
      # it appears to be an escaped string of XML. We need to get that
      # string an parse it with Nokogiri to be able to parse the
      # interesting pieces.
      envelope = Nokogiri::XML doc.children.first.text

      JobCollectionProxy.new(envelope)
    end

    def each_job
      page = 1
      loop {
        jobs = jobs(:page => page)
        max_pages ||= jobs.max_pages

        jobs.each { |job|
          yield job
        }

        page += 1
        break if page > max_pages
      }
    end

  end

end
