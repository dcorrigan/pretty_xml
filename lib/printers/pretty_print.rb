module PrettyXML
  class PrettyPrint
    attr_reader :printer, :handler

    def initialize(options)
      @handler = SaxPrinter.new(options)
      @printer = Nokogiri::XML::SAX::Parser.new(handler)
    end

    def pp(doc)
      d = verify_doc(doc)
      dn = doctype_node(doc)
      instrs = []
      pretty = ''
      handler.pretty = pretty
      handler.instructions = instrs
      printer.parse(d)
      instrs << dn if dn
      instrs.empty? ? pretty : "#{instrs.join("\n")}\n#{pretty}"
    end

    def verify_doc(doc)
      doc.is_a?(Nokogiri::XML::Document) ? doc.to_xml : doc
    end

    def doctype_node(doc)
      doc[/<!DOCTYPE[^>]*>/]
    end
  end
end
