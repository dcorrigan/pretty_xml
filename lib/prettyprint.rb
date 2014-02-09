require 'nokogiri'
require 'andand'

class PrettyPrint

  def initialize options
    @preserve_whitespace = true
    set_options_as_ivars options
  end

  def set_options_as_ivars options
    options.each do |name, value|
      instance_variable_set("@#{name}", value)
    end
  end

  def pp doc
    strip_whitespace doc
    pp_blocks doc
    pp_compact doc
    doc.serialize(:save_with => 0)
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
    @compact.include? block.previous_element.andand.name or
    @block.include? block.previous_element.andand.name or
    block == block.parent.elements.first
  end

  def pp_compact doc
    doc.css(@compact.join(',')).each do |compact|
      compact.add_previous_sibling "\n"
      add_left_space compact
    end
  end

  def add_left_space node
    space_multiplier = node.ancestors.size - 1
    space_multiplier.times do |x|
      node.add_previous_sibling @tab
    end
  end

  def add_internal_space node
    space_multiplier = node.ancestors.size - 1
    node.add_child "\n"
    space_multiplier.times do |x|
      node.add_child @tab
    end
  end

end
