xml-prettyprint
===============

A Ruby re-write of Perl LibXML PrettyPrint.

I don't recommend using this unless you are absolutely sure a human will have to read your XML file. It is slow and resource-intensive.

xml-prettyprint does not support namespaced nodes yet.

## Use

xml-prettyprint expects that three main parameters be passed:

  1. block: elements that should have internal and external linebreaks
  2. compact: elements that should have external linebreaks
  3. inline: elements that should have neither internal not external linebreaks

A fourth parameter, tab, specifies the kind of space that should be used for indenting the output. Pass literal characters; for example, two spaces or a tab.

Additional parameters are:

  1. preserve_whitespace: retain standalone whitespace only text nodes within compact and inline elements 
  2. delete_all_linebreaks: delete linebreak characters within all text nodes, regardless of whether preserve_whitespace is set to true

## Example

require 'nokogiri'

    doc = Nokogiri.XML '<root>  <block>
     <p> 
    </p>
        
        </block><p>stuff<i> </i></p>  
        
        <structure>
                           <div>
                           <p>yo yo<i/></p>
    </div>
    </structure></root>'

    options = {
      :block => %w(root block structure div),
      :compact => %w(p),
      :inline => %w(i),
      :preserve_whitespace => true,
      :delete_all_linebreaks => true,
      :tab => '  '
    }

    puts PrettyPrint.new(options).pp(doc)

returns

    <?xml version="1.0"?>
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

