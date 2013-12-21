# encoding: UTF-8
require 'nokogiri'
require 'minitest/autorun'
require_relative '../lib/prettyprint'

class PrettyPrintTests < Minitest::Test

  OP1 = {
    :block => %w(root),
    :compact => %w(p),
    :inline => %w(),
    :preserve_whitespace => false,
    :tab => '  '
  }

  def setup_and_exercise
    @parsed = Nokogiri.XML @input
    @pp = PrettyPrint.new(@parsed).pp
  end

  def test_basic_stuff
    @input = "<root><p>stuff</p></root>"
    assert @input == 'foo'
  end

end
