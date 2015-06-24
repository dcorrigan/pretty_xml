class SaxPrinter < Nokogiri::XML::SAX::Document
  attr_accessor :pretty, :instructions

  CCS = {
    amp: {named: '&amp;', hex: '&#x26;'},
    lt: {named: '&lt;', hex: '&#x3c;'},
    gt: {named: '&gt;', hex: '&#x3e;'},
  }
  XMLDEC_ATTRS = %w(version encoding standalone)

  def initialize(options)
    set_options_as_ivars(options)
  end

  def start_element_namespace(name, attrs = [], prefix = nil, uri = nil, ns = [])
    if @use_ns
      super
    else
      start_element(name, attrs.map { |a| [a.localname, a.value] })
    end
  end

  def xmldec_attrs(args)
    XMLDEC_ATTRS.each_with_index.to_a.map { |t, i| " #{t}=\"#{args[i]}\"" if args[i] }.compact.join
  end

  def xmldecl(*args)
    opts = xmldec_attrs(args)
    instructions << "<?xml#{opts}?>"
  end

  def processing_instruction(name, content)
    instructions << "<?#{name} #{content}?>"
  end

  def start_document
    @depth = 0
    @opens = []
  end

  def set_element_types(options)
    @block = Set.new(options[:block])
    @compact = Set.new(options[:compact])
    @inline = Set.new(options[:inline])
  end

  def set_control_vars(options)
    @whitespace = options.include?(:preserve_whitespace) ?  options[:preserve_whitespace] : true
    @close_tags = options[:close_tags] ? Set.new(options[:close_tags]) : []
    @preserve_linebreaks = options[:preserve_linebreaks] ? Set.new(options[:preserve_linebreaks]) : []
    @ccs = options[:control_chars] || :named
    @use_ns = options[:use_namespaces]
    @tab = options[:tab] || '  '
  end

  def set_options_as_ivars(options)
    set_element_types(options)
    set_control_vars(options)
  end

  def block?(name)
    @block.include?(name)
  end

  def compact?(name)
    @compact.include?(name)
  end

  def inline?(name)
    @inline.include?(name)
  end

  def in_inline?
    inline?(@opens[-1])
  end

  def in_compact?
    compact?(@opens[-1])
  end

  def in_block?
    block?(@opens[-1])
  end

  def ws_adder
    ws = @tab * (@depth - 1)
    pretty.empty? ? ws : "\n#{ws}"
  end

  def start_element(name, attributes)
    @depth += 1
    space_before_open(name)
    add_opening_tag(name, attributes)
    @opens << name
    @open_tag = name
  end

  def space_before_open(name)
    increment_space if block?(name) or compact?(name)
  end

  def increment_space
    pretty << ws_adder
  end

  def end_element(name)
    if self_closing?(name)
      pretty[-1] = '/>'
    else
      space_before_close(name)
      pretty << "</#{name}>"
    end
    @depth -= 1
    @open_tag = nil
    @opens.pop
  end

  def self_closing?(name)
    @open_tag == name and !@close_tags.include?(name)
  end

  def space_before_close(name)
    increment_space if block?(name) and @depth != 0
  end

  def add_opening_tag(name, attrs)
    tag = attrs.empty? ? "<#{name}>" : tag_with_attrs(name, attrs)
    pretty << tag
  end

  def tag_with_attrs(name, attrs)
    attr_str = attrs.map { |n, v| "#{n}=\"#{v}\""}.join(' ')
    "<#{name} #{attr_str}>"
  end

  def end_document
  end

  def characters(string)
    return false if ws_only_in_block?(string)
    handle_whitespace(string)
    unless string.empty?
      @open_tag = nil
      sanitize(string)
      pretty << string
    end
  end

  def ws_only_in_block?(string)
    string[/\A\s*\Z/] and in_block?
  end

  def whitespace?
    @whitespace and below_block?
  end

  def keep_linebreaks?
    @preserve_linebreaks.include?(@open_tag)
  end

  def below_block?
    in_inline? or in_compact?
  end

  def handle_whitespace(string)
    string.gsub!(/[\r\n]/, '') unless keep_linebreaks?
    string.gsub!(/^\s+|\s+$/, '') unless whitespace?
  end

  def comment(string)
    pretty << "<!--#{string}-->"
    @open_tag = nil
  end

  def sanitize(string)
    string.gsub!(/&/, CCS[:amp][@ccs])
    string.gsub!(/</, CCS[:lt][@ccs])
    string.gsub!(/>/, CCS[:gt][@ccs])
  end

  def error(string)
    fail Nokogiri::XML::SyntaxError.new(string)
  end
end
