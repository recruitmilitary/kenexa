module Kenexa

  class Job < Struct.new(:title, :url, :city, :state, :internal_id, :last_updated)

    def initialize(attributes = {})
      attributes.each do |attribute, value|
        send("#{attribute}=", value)
      end
    end

    def description
      @description ||= begin
                         doc = Nokogiri::HTML(open(url))

                         parser = JobDetailParser.new
                         details = parser.parse(doc)

                         details['Job Description']
                       end
    end

  end

end
