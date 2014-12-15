require 'nokogiri'
require 'sax'

module PrettyXML
  class PrettyPrint
    attr_reader :printer, :handler

    def initialize(options)
      @handler = SaxPrinter.new(options)
      @printer = Nokogiri::XML::SAX::Parser.new(handler)
    end

    def pp(doc)
      d = verify_doc(doc)
      printer.parse(d)
      handler.pretty
    end

    def verify_doc(doc)
      doc.is_a?(Nokogiri::XML::Document) ? doc.to_xml : doc
    end
  end
end
