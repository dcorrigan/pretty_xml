module PrettyXML
  class XHTML < PrettyXML::PrettyPrint
    VOID = %w(area base br col embed hr img input keygen link meta param source track wbr)

    def initialize(options)
      @elements = PrettyXML.load_config('xhtml.yml')
      options[:close_tags] = explicit_closing_tags
      options[:control_chars] = :hex
      options.merge!(@elements)
      super
    end

    def explicit_closing_tags
      @elements.values.flatten - VOID
    end

    def parsed_doc?(doc)
      doc.is_a?(Nokogiri::HTML::Document) or doc.is_a?(Nokogiri::XML::Document)
    end

    def verify_doc(doc)
      parsed_doc?(doc) ? doc.to_xml : doc
    end
  end
end
