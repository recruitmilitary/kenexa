module Kenexa

  class Job < Struct.new(:title, :url, :city, :state, :internal_id, :last_updated)

    def initialize(attributes = {})
      attributes.each do |attribute, value|
        send("#{attribute}=", value)
      end
    end

  end

end
