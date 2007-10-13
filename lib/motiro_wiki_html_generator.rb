require 'mediacloth/mediawikiwalker'
require 'mediacloth/mediawikiparams'

#HTML generator for a MediaWiki parse tree
#
#Typical use case:
# parser = MediaWikiParser.new
# parser.lexer = MediaWikiLexer.new
# ast = parser.parse(input)
# walker = MediaWikiHTMLGenerator.new
# walker.parse(ast)
# puts walker.html
class MotiroWikiHTMLGenerator < MediaWikiHTMLGenerator

  def initialize(url_generator)
    @url_generator = url_generator
  end

protected

  def formatting_to_tag(ast)
    if ast.formatting == :Link or ast.formatting == :InternalLink
      links = ast.contents.split
      link = links[0]
      link_name = links[1, links.length-1].join(" ")
      link_name = link if link_name.empty?
      ast.contents = link_name
      if ast.formatting == :InternalLink
        params = @url_generator.page_link_params_for(link)
        tag = ["a", params.to_a.map {|a| " #{a[0]}=\"#{a[1]}\""}.join]
      else
        tag = ["a", " href=\"#{link}\" rel=\"nofollow\""]
      end
    else
      tag = super(ast)
    end
    tag
  end    

end
