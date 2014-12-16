# encoding: UTF-8
require_relative 'test_helper'

class XHTMLPrettyPrintTests < Minitest::Test
  EXT = '.html'

  OP1 = {
    :preserve_whitespace => true,
    :tab => '  '
  }

  def prettify(options, content)
    PrettyXML::XHTML.new(options).pp(content)
  end

  def sample_dir(subdir)
    File.join(File.dirname(__FILE__), "samples", subdir)
  end

  def read_sample(subdir, type)
    File.read(File.join(sample_dir(subdir), "#{type}#{EXT}"))
  end

  def load_in_and_out(subdir)
    @in = read_sample(subdir, 'in')
    @out = read_sample(subdir, 'out')
  end

  def test_example_one
    load_in_and_out('xhtml1')
    pp = prettify(OP1, @in)
    assert pp == @out, "\nNope, got:\n#{pp}"
  end
end
