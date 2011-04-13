module Kenexa

  class JobDetailParser

    def parse(doc)
      fields = doc.search(".Fieldlabel").map &:text
      values = doc.search(".TEXT").map &:text

      Hash[fields.zip(values)]
    end

  end

end
