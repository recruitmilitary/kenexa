module Kenexa

  class JobCollectionProxy

    instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^object_id$)/ }

    def initialize(envelope)
      @envelope = envelope
      @jobs = JobParser.new.parse(envelope)
    end

    def total
      @total ||= @envelope.at("//OtherInformation/TotalRecordsFound").text.to_i
    end

    def max_pages
      @max_pages ||= @envelope.at("//OtherInformation/MaxPages").text.to_i
    end

    def method_missing(meth, *args, &block)
      @jobs.send(meth, *args, &block)
    end

  end

end
