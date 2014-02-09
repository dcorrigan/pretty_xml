require 'nokogiri'
require 'andand'

class PrettyPrint

  def initialize options
    @preserve_whitespace = true
    set_options_as_ivars options
  end

  # expected params: block, compact, inline, tab
  # optional params: preserve_whitespace, delete_all_linebreaks
  def set_options_as_ivars options
    options.each do |name, value|
      instance_variable_set("@#{name}", value)
    end
  end

  def pp doc
    verify_doc doc
    strip_whitespace doc
    pp_blocks doc
    pp_compact doc
    doc.serialize(:save_with => 0)
  end

  def verify_doc doc
    root = doc.root.name
    raise ArgumentError.new('The root node may not be specified as compact or inline.') if (@compact + @inline).include? root
  end

  def strip_whitespace doc
    doc.css(ws_accessor).each do |node|
      eliminate_ws_nodes_from node
    end
    strip_extra_linebreaks doc if  @delete_all_linebreaks
  end

  def strip_extra_linebreaks doc
    non_block_selector = (@compact + @inline).join(',')
    doc.css(non_block_selector).each do |node|
      node.children.each do |child|
        next unless child.text?
        child.content = child.text.gsub(/[\r\n]/,'')
      end
    end
  end

  def ws_accessor
    ws_accessor = @preserve_whitespace ? @block : @block + @compact + @inline
    ws_accessor.join(',')
  end

  def eliminate_ws_nodes_from node
    node.children.each do |child|
      next unless child.text?
      child.remove if child.text.match /^\s*$/
    end
  end

  def pp_blocks doc
    doc.css(@block.join(',')).each do |block|
      unless block == doc.root
        block.add_previous_sibling "\n" if needs_hard_return? block
        add_left_space block
      end
      add_internal_space block
    end
  end

  def needs_hard_return? block
    return true if block.previous_element.nil?
    return true if (@compact + @block).include? block.previous_element.name
  end

  def pp_compact doc
    doc.css(@compact.join(',')).each do |compact|
      compact.add_previous_sibling "\n"
      add_left_space compact
    end
  end

  def add_left_space node
    node.add_previous_sibling space_for(node)
  end

  def add_internal_space node
    node.add_child "\n"
    node.add_child space_for(node)
  end

  def space_for node
    space_multiplier = node.ancestors.size - 1
    @tab * space_multiplier
  end

end
