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

    QUESTION_MAP = {
      :title        => 7996,
      :city         => 15615,
      :state        => 15616,
      :internal_id  => 7972,
    }.freeze

    def initialize(endpoint = DEFAULT_ENDPOINT)
      @uri = URI.parse(endpoint)
    end

    def jobs(options = {})
      page = options[:page] || 1
      template = ERB.new(File.read(TEMPLATE_PATH + "/request.erb"))
      inputXml = template.result(binding)
      response = Net::HTTP.post_form(@uri, "inputXml" => inputXml)

      doc = Nokogiri::XML response.body
      envelope = Nokogiri::XML doc.children.first.text

      envelope.search("//Job").map { |node|
        attributes = {
          :url          => extract_text(node, ".//JobDetailLink"),
          :last_updated => extract_date(node, ".//LastUpdated"),
        }

        QUESTION_MAP.keys.each do |attribute|
          attributes[attribute] = extract_question(node, attribute)
        end

        Job.new(attributes)
      }
    end

    def each_job
      page = 0
      loop {
        page += 1
        jobs = jobs(:page => page)

        break if jobs.empty?

        jobs.each { |job|
          yield job
        }
      }
    end

    private

    def extract_date(node, name)
      Date.parse extract_text(node, name)
    end

    def extract_question(node, name)
      if question_id = QUESTION_MAP[name]
        extract_text(node, ".//Question[@Id='#{question_id}']")
      else
        raise ArgumentError, "missing question mapping for #{name}"
      end
    end

    def extract_text(node, xpath)
      node.at(xpath).text.strip
    end

  end

end
