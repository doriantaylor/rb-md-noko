require 'md/noko/version'
require 'redcarpet'
require 'xml-mixup'

class MD::Noko
  include XML::Mixup

  private

  XHTML_BP = <<-BP
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title/>
    <base href="%s"/>
  </head>
  <body>
%s
  </body>
</html>
  BP

  XPATH_NS = { html: 'http://www.w3.org/1999/xhtml' }.freeze

  @@markdown = Redcarpet::Markdown.new(
    Redcarpet::Render::XHTML.new(prettify: false),
    tables: true, fenced_code_blocks: true, quote: true, highlight: true)

  def h1_title body
    heads = body.xpath('html:h1', XPATH_NS)

    # set the title to the first and only h1 if it's the first element
    if heads.length == 1 and not heads[0].previous_element
      h1 = heads[0]

      # assign document title to the header content
      d = body.document
      t = d.at_xpath('/html:html/html:head/html:title[1]', XPATH_NS)
      t.content = h1.content

      # unlink redundant h1 if it has no children (ie unformatted)
      h1.unlink unless h1.at_xpath('*')
      
      # only do h2 through h6
      return true
    end

    # otherwise do nothing
    false
  end

  def make_sections node, ranks=1..6
    raise 'fail range' if ranks.nil? or ranks.size < 1

    h = "html:h#{ranks.first}"

    ranks = Range.new(ranks.first + 1, ranks.last)

    headers = node.xpath(h, XPATH_NS).to_a
    if headers.empty?
      return make_sections node, ranks if ranks.size > 0
    else
      headers.each_index do |i|
        hdr = headers[i]
        xp = "following-sibling::node()[not(self::#{h})]"
        if i < headers.length - 1
          # note that this is always 1 because all preceding
          # siblings prior to that will have been removed
          xp += "[following-sibling::#{h}" +
            "[count(preceding-sibling::#{h}) = #{1}]]"
        end

        # duplicate and nuke these elements
        siblings = hdr.xpath(xp, XPATH_NS).to_a.map do |s|
          # note that :unlink returns the node, but with a
          # garbaged-up set of namespaces
          o = s.dup; s.unlink; o
        end

        # add the header to the front of the list
        siblings.unshift hdr.dup
        siblings.unshift "\n"

        # now construct the section
        section = markup replace: hdr, spec: { nil => :section }
        markup after:  section, spec: "\n"
        markup parent: section, spec: siblings

        # now recurse
        make_sections section, ranks
      end
    end
  end

  def bq_aside body
    x = './/%s[not(parent::%s)][%s][count(*) = 1]' % (%w{html:blockquote} * 3)
    body.xpath(x, XPATH_NS).each do |node|
      fc = node.first_element_child
      fc.name = 'aside'
      fc[:role] = 'note'
      node.replace fc
    end
  end

  def img_figure body
    body.xpath('.//html:p[html:img][count(*) = 1]', XPATH_NS).each do |node|
      node.name = 'figure'
    end
  end

  def prune_text body
    doc = body.document
    doc.xpath('//text()[not(ancestor::html:pre)]', XPATH_NS).each do |n|
      n.content = n.content.gsub(/(?: |\t|\r|\n)+/, ' ')
      # might as well fix the damn indentation while we're here
      if n.content == ' '
        a = n.ancestors.count - 1
        if (p = n.previous_sibling)
          # nth text node
          if p.text? and p.content =~ /^\s+$/
            n.unlink
          else
            a -= 1 unless n.next_sibling
            n.content = "\n" + ('  ' * a)
          end
        else
          # first text node
          n.content = "\n" + ('  ' * a)
        end
      end
    end
  end

  public

  # Ingest a markdown file, with sensible defaults
  #
  # @param obj [String, IO] the content to be ingested
  #
  # @param uri [String, #to_s, nil] the document's base URI
  #
  # @return [Nokogiri::XML::Document]

  def ingest obj, uri=nil
    doc = obj.respond_to?(:read) ? obj.read : obj
    doc = XHTML_BP % [uri ? uri.to_s : '', @@markdown.render(doc)]
    doc = Nokogiri::XML.parse doc, uri

    body = doc.at_xpath('/html:html/html:body[1]', XPATH_NS)

    # default all six headers unless there's a lone h1
    ranks = h1_title(body) ? 2..6 : 1..6

    # markdown just makes a flat list of elements so let's plump it up
    make_sections body, ranks

    # redo double blockquotes as <aside role="note">
    bq_aside body

    # redo paragraphs containing only images as figures
    img_figure body

    # fix the damn text nodes
    prune_text body

    doc
  end
end
