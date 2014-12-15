class SaxPrinter < Nokogiri::XML::SAX::Document
  attr_accessor :pretty

  CCS = {
    amp: {named: '&amp;', hex: '&x26;'},
    lt: {named: '&lt;', hex: '&x3c;'},
    gt: {named: '&gt;', hex: '&x3e;'},
  }

  def initialize(options)
    set_options_as_ivars(options)
  end

  def xmldecl(version, encoding, standalone)
    opts = ''
    opts << " version=\"#{version}\"" if version
    opts << " encoding=\"#{encoding}\"" if encoding
    opts << " standalone=\"#{standalone}\"" if standalone
    pretty << "<?xml#{opts}?>"
  end

  def processing_instruction(name, content)
    pretty << "<?#{name} #{content}?>"
  end

  def start_document
    @open_tag = ''
    @depth = 0
  end

  def set_options_as_ivars(options)
    @block = Set.new(options[:block])
    @compact = Set.new(options[:compact])
    @inline = Set.new(options[:inline])
    @whitespace = options.include?(:preserve_whitespace) ?  options[:preserve_whitespace] : true
    @close_tags = options[:close_tags] ? Set.new(options[:close_tags]) : []
    @ccs = options[:control_chars] || :named
    @tab = options[:tab] || '  '
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

  def ws_adder
    ws = @tab * (@depth - 1)
    pretty.empty? ? ws : "\n#{ws}"
  end

  def start_element(name, attributes)
    @depth += 1
    set_context(name)
    ws = space_before_open(name)
    pretty << space_before_open(name)
    add_opening_tag(name, attributes)
    @open_tag = name
  end

  def space_before_open(name)
    if block?(name)
      pretty.sub!(/\s*$/, '')
      ws_adder
    elsif compact?(name)
      pretty.sub!(/\s*$/, '')
      ws_adder
    else
      ''
    end
  end

  def set_context(name)
    if block?(name)
      @in_block = true
      @in_compact = false
      @in_inline = false
    elsif compact?(name)
      @in_block = false
      @in_compact = true
      @in_inline = false
    elsif inline?(name)
      @in_block = false
      @in_compact = false
      @in_inline = true
    end
  end

  def end_element(name)
    pretty << space_before_close(name) unless @depth == 0
    self_closing?(name) ? pretty[-1] = '/>' : pretty << "</#{name}>"
    @depth -= 1
    @open_tag = nil
  end

  def self_closing?(name)
    @open_tag == name and !@close_tags.include?(name)
  end

  def space_before_close(name)
    if block?(name)
      pretty.sub!(/\s*$/, '')
      ws_adder
    else
      ''
    end
  end

  def add_opening_tag(name, attrs)
    attr_str = attrs.map { |n, v| "#{n}=\"#{v}\""}.join(' ')
    tag = attrs.empty? ? "<#{name}>" : "<#{name} #{attr_str}>"
    pretty << tag
  end

  def end_document
    pretty.gsub!(/\s*\n/, "\n")
    @xmldec = ''
  end

  def characters(string)
    @open = nil
    strc = handle_whitespace(string)
    unless strc.empty?
      @open_tag = nil
      pretty << sanitize(strc)
    end
  end

  def whitespace?
    @whitespace and @in_inline
  end

  def handle_whitespace(string)
    strc = string.gsub(/[\r\n]/, '')
    strc = strc.gsub(/^\s+|\s+$/, '') unless @whitespace
    strc
  end

  def comment(string)
    pretty << "<!--#{string}-->"
  end

  def sanitize(string)
    text = string.gsub(/&/, CCS[:amp][@ccs])
    text = text.gsub(/</, CCS[:lt][@ccs])
    text.gsub(/>/, CCS[:gt][@ccs])
  end

  def error(string)
    fail Nokogiri::XML::SyntaxError.new(string)
  end
end
