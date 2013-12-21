require 'nokogiri'

class PrettyPrint

  def initialize doc, options
    @doc = doc
    options.each do |name, value|
      instance_variable_set("@#{name}", value)
    end
  end

  def pp
    strip_whitespace
    @doc.serialize(:save_with => 0)
  end

  def strip_whitespace
    ws_accessor = get_ws_accessor
    @doc.css(ws_accessor).each do |node|
      eliminate_ws_nodes_from node
    end
  end

  def get_ws_accessor
    ws_accessor = @preserve_whitespace ? @block : @block + @compact + @inline
    ws_accessor.join(',')
  end

  def eliminate_ws_nodes_from node
    node.children.each do |child|
      next unless child.text?
      child.remove if child.text.match /^\s*$/
    end
  end


end
