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
    :delete_all_linebreaks => true,
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
    @pp = PrettyPrint.new(options).pp(@parsed)
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

  def test_nonsensical_content_model_does_not_explode
    @input = "<root>  <i>stuff<p> </p></i>  </root>"
    setup_and_exercise OP1
    assert @pp
  end

  def test_badly_specified_root_node_raises_error
    @input = "<p>  <i>stuff<root> </root></i>  </p>"
    parsed = Nokogiri.XML @input
    pp = PrettyPrint.new(OP1)
    assert_raises(ArgumentError){
      pp.pp(parsed)
    }
  end

  def test_internal_linebreak_strip_works
    @input = "<root>  <p>linebreak goes 
here</p>  </root>"
    setup_and_exercise OP1
    assert @pp !~ /<p>[^<]*\n/
  end

  def test_more_complex_example
    @input = Examples.example1[:in]
    setup_and_exercise OP1
    expected = Examples.example1[:out]
    assert @pp == expected, "It looked like this: #{@pp}"
  end

  module Examples

    def self.example1
      {:in => '<root>  <block>
 <p> </p>
    
    </block><p>stuff<i> </i></p>  
    
    <structure>
                       <div>
                       <p>yo yo<i/></p>
</div>
</structure> <structure>
                       <div>
                       <p>yo yo<i/></p>
</div>
</structure></root>',
      :out => '<?xml version="1.0"?>
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
  <structure>
    <div>
      <p>yo yo<i/></p>
    </div>
  </structure>
</root>
'
      }
    end
  end

end
