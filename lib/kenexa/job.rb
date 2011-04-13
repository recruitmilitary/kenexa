module Kenexa

  class Job < Struct.new(:title, :url, :city, :state)

    def initialize(attributes = {})
      attributes.each do |attribute, value|
        send("#{attribute}=", value)
      end
    end

  end

end
