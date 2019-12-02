aklsdfjsldafj

pretty_xml
===============

This is pre-1.0 and probably unstable. Use at your own risk

I don't recommend using this unless you are sure a human will have to read your XML file.

Non-features:

  - `pretty_xml` does not support namespaced nodes yet.
  - deletes all linebreaks from input

## Use

`pretty_xml` expects that three main parameters be passed:

  1. `block`: elements that should have internal and external linebreaks
  2. `compact`: elements that should have external linebreaks
  3. `inline`: elements that should have neither internal not external linebreaks

Additional parameters are:

  1. `preserve_whitespace`: retain standalone whitespace only text nodes within compact and inline elements
  2. `tab`: specifies the kind of space that should be used for indenting the output.

Less common parameters:

  1. `close_tags`: a list of tags that need explicit closing tags in the output (as in HTML5, `<a id="something"></a>` is correct, but a self-closing `<a id="something"/>` will not be parsed correctly in all cases)
  2. `control_chars`: options are `:named` or `:hex` for `<`, `>`, and `&` as literal characters in output; defaults to `:named`

Use these parameters within a hash to initialize an instance of the `PrettyXML::PrettyPrint` class. To prettyprint a document, pass a `Nokogiri::XML::Document` or a string as an argument to the `pp` method.

## Example

    doc = '<root>  <block>
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

    puts PrettyXML::PrettyPrint.new(options).pp(doc)

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

## Pretty HTML
