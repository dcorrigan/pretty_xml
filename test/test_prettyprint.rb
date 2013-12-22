# encoding: UTF-8
require 'nokogiri'
require 'minitest/autorun'
require_relative '../lib/prettyprint'

class PrettyPrintTests < Minitest::Test

  OP1 = {
    :block => %w(root block structure div),
    :compact => %w(p),
    :inline => %w(i),
    :preserve_whitespace => true,
    :tab => '  '
  }

  OP2 = {
    :block => %w(root),
    :compact => %w(p),
    :inline => %w(i),
    :preserve_whitespace => false,
    :tab => '  '
  }

  OP3 = {
    :block => %w(root),
    :compact => %w(p),
    :inline => %w(i),
    :tab => '  '
  }

  def setup_and_exercise options
    @parsed = Nokogiri.XML @input
    @pp = PrettyPrint.new(@parsed, options).pp
  end

  def test_strips_basic_whitespace_from_block_when_ws_is_true
    @input = "<root>  <p>stuff</p>  </root>"
    setup_and_exercise OP1
    assert @pp.match /\n  <p>/
  end

  def test_leaves_inline_and_compact_space_when_ws_is_true
    @input = "<root>  <p> </p><p>stuff<i> </i></p>  </root>"
    setup_and_exercise OP1
    assert @pp =~ /<p> <\/p>/
    assert @pp =~ /<i> <\/i>/
    assert @pp !~ /<root>  <p>/
  end

  def test_strips_inline_and_compact_space_when_ws_is_false
    @input = "<root>  <p> </p><p>stuff<i> </i></p>  </root>"
    setup_and_exercise OP2
    assert @pp =~ /<p\/>/
    assert @pp =~ /<i\/>/
    assert @pp !~ /<root>  <p>/
  end

  def test_ws_preserve_defaults_to_true_if_not_given
    @input = "<root>  <p> </p><p>stuff<i> </i></p>  </root>"
    setup_and_exercise OP3
    assert @pp =~ /<p> <\/p>/
    assert @pp =~ /<i> <\/i>/
    assert @pp !~ /<root>  <p>/
  end

  def test_pp_blocks
    @input = "<root>  <block><p> </p></block><p>stuff<i> </i></p>  </root>"
    setup_and_exercise OP1
    assert @pp.match /<root>\n  <block>\n    <p>/
  end

  def test_more_complex_example
    @input = "<root>  <block>
 <p> </p>
    
    </block><p>stuff<i> </i></p>  
    
    <structure>
                       <div>
                       <p>yo yo<i/></p>
</div>
</structure></root>"
    setup_and_exercise OP1
expected = '<?xml version="1.0"?>
<root>
  <block>
    <p> </p>
  </block>
  <p>stuff<i> </i></p>
  <structure>
    <div>
      <p>yo yo<i/></p>
    </div>
  </structure>
</root>
'
assert @pp == expected
  end

end
