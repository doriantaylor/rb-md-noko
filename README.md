# MD::Noko: in goes Markdown, out comes Nokogiri

## Synopsis

```ruby
require 'md-noko'

mdnk = MD::Noko.new
doc  = mdnk.ingest File.open('lolwut.md')

# or

doc  = mdnk.ingest <<EOT
# Hi

Markdown here!

![lulz](meme.jpeg)

EOT

# doc is a Nokogiri::XML::Document
```

## Description

This is a simple module that encapsulates a set of desirable
manipulations to the (X)HTML output
of [Redcarpet](https://www.rubydoc.info/gems/redcarpet/). It exposes
(for now) a single method, `ingest`, which returns a [`Nokogiri::XML::Document`](https://www.rubydoc.info/gems/nokogiri/Nokogiri/XML/Document), for further manipulation. In particular, this module:

* Adds HTML preamble to produce a valid document,
* Creates a `<base href=""/>` element which you can pass a URL,
* Creates a hierarchy of `<section>` elements and places headings
  and content inside,
* If the document contains a single `<h1>` at the beginning, this is
  copied into the `<title>`, and removed from the document body if
  determined to be redundant (i.e. unless it contains markup elements),
* Nested `<blockquote>` elements are converted into `<aside role="note">`,
* Images on their own paragraph are transformed into a `<figure>`,
* Text nodes not descendants of `<pre>` are whitespace-normalized and
  indentation is repaired.
  
The embedded `Redcarpet::Markdown` instance has the following flags set:

* `:tables`
* `:fenced_code_blocks`
* `:quote`
* `:highlight`

These are currently not exposed.

## Installation

The usual:

    $ gem install md-noko

Or, [download it off rubygems.org](https://rubygems.org/gems/md-noko).

## Contributing

Bug reports and pull requests are welcome at
[the GitHub repository](https://github.com/doriantaylor/rb-md-noko).

## Copyright & License

©2018 [Dorian Taylor](https://doriantaylor.com/)

This software is provided under
the [Apache License, 2.0](https://www.apache.org/licenses/LICENSE-2.0).
