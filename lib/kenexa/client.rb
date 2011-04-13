require 'net/http'
require 'uri'
require 'open-uri'
require 'erb'
require 'nokogiri'

module Kenexa

  class Client

    DEFAULT_ENDPOINT = 'http://import.brassring.com/WebRouter/WebRouter.asmx/route'
    TEMPLATE_PATH = File.dirname(__FILE__) + "/templates"

    def initialize(endpoint = DEFAULT_ENDPOINT)
      @uri = URI.parse(endpoint)
    end

    def jobs
      page = 1
      template = ERB.new(File.read(TEMPLATE_PATH + "/request.erb"))
      inputXml = template.result(binding)
      response = Net::HTTP.post_form(@uri, "inputXml" => inputXml)

      doc = Nokogiri::XML response.body
      envelope = Nokogiri::XML doc.children.first.text

      envelope.search("//Job").map { |node|
        attributes = {
          :url          => extract_text(node, "//JobDetailLink"),
          :last_updated => extract_date(node, "//LastUpdated"),
        }

        QUESTION_MAP.keys.each do |attribute|
          attributes[attribute] = extract_question(node, attribute)
        end

        attributes[:description] = description_from_url(attributes[:url])
        Job.new(attributes)
      }
    end

    QUESTION_MAP = {
      :title        => 7996,
      :city         => 15615,
      :state        => 15616,
      :internal_id  => 7972,
    }.freeze

    private

    def description_from_url(url)
      doc = Nokogiri::HTML(open(url))

      parser = JobDetailParser.new
      details = parser.parse(doc)

      details['Job Description']
    end

    def extract_date(node, name)
      Date.parse extract_text(node, name)
    end

    def extract_question(node, name)
      if question_id = QUESTION_MAP[name]
        extract_text(node, "//Question[@Id='#{question_id}']")
      else
        raise ArgumentError, "missing question mapping for #{name}"
      end
    end

    def extract_text(node, xpath)
      node.at(xpath).text.strip
    end

  end

end
