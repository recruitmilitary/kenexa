module Kenexa

  class JobCollectionProxy

    instance_methods.each { |m| undef_method m unless m =~ /(^__|^send$|^object_id$)/ }

    QUESTION_MAP = {
      :title        => 7996,
      :city         => 15615,
      :state        => 15616,
      :internal_id  => 7972,
    }.freeze

    def initialize(envelope)
      @envelope = envelope
      @jobs = envelope.search("//Job").map { |node|
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

    def total
      @total ||= @envelope.at("//OtherInformation/TotalRecordsFound").text.to_i
    end

    def max_pages
      @max_pages ||= @envelope.at("//OtherInformation/MaxPages").text.to_i
    end

    def method_missing(meth, *args, &block)
      @jobs.send(meth, *args, &block)
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
