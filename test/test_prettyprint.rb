# encoding: UTF-8
require 'nokogiri'
require 'minitest/autorun'
require_relative '../lib/prettyprint'

class PrettyPrintTests < Minitest::Test

  OP1 = {
    :block => %w(root),
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

  def setup_and_exercise options
    @parsed = Nokogiri.XML @input
    @pp = PrettyPrint.new(@parsed, options).pp
  end

  def test_strips_basic_whitespace_from_block_when_ws_is_true
    @input = "<root>  <p>stuff</p>  </root>"
    setup_and_exercise OP1
    assert @pp !~ /  /
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

end
