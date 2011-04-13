require "net/http"
require "uri"
require 'nokogiri'

module Kenexa

  class Client

    DEFAULT_ENDPOINT = 'http://import.brassring.com/WebRouter/WebRouter.asmx/route'

    def initialize(endpoint = DEFAULT_ENDPOINT)
      @uri = URI.parse(endpoint)
    end

    def jobs
      inputXml = <<-EOF
<Envelope version="01.00">
  <Sender>
    <Id>12345</Id>
    <Credential>25152</Credential>
  </Sender>
  <TransactInfo transactId="1" transactType="data">
    <TransactId>01/27/2010</TransactId>
    <TimeStamp>12:00:00 AM</TimeStamp>
  </TransactInfo>
  <Unit UnitProcessor="SearchAPI">
    <Packet>
      <PacketInfo packetType="data">
        <packetId>1</packetId>
      </PacketInfo>
      <Payload>
        <InputString>
          <ClientId>25152</ClientId>
          <SiteId>5244</SiteId>
          <PageNumber>1</PageNumber>
          <OutputXMLFormat>0</OutputXMLFormat>
          <AuthenticationToken/>
          <HotJobs/>
          <ProximitySearch>
            <Distance/>
            <Measurement/>
            <Country/>
            <State/>
            <City/>
            <zipCode/>
          </ProximitySearch>
          <JobMatchCriteriaText/>
          <SelectedSearchLocaleId/>
          <Questions>
            <Question Sortorder="ASC" Sort="No">
              <Id>7982</Id>
              <Value><![CDATA[TG_SEARCH_ALL]]></Value>
            </Question>
          </Questions>
          <Questions>
            <Question Sortorder="ASC" Sort="No">
              <Id>15616</Id>
              <Value><![CDATA[TG_SEARCH_ALL]]></Value>
            </Question>
          </Questions>
        </InputString>
      </Payload>
    </Packet>
  </Unit>
</Envelope>
EOF
      response = Net::HTTP.post_form(@uri, "inputXml" => inputXml)

      doc = Nokogiri::XML response.body
      envelope = Nokogiri::XML doc.children.first.text

      envelope.search("//Job").map { |node|
        title = node.at("//Question[@Id='7996']").text
        url   = node.at("//JobDetailLink").text
        city  = node.at("//Question[@Id='15615']").text.strip

        Job.new(title, url, city)
      }
    end

  end

end
