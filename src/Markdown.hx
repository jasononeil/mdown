//
// mdown -- A haxe port of Markdown.
//
// Based on the Showdown, Copyright (c) 2007 John Fraser.
//   <http://www.attacklab.net/>
//
// Original Markdown Copyright (c) 2004-2005 John Gruber
//   <http://daringfireball.net/projects/markdown/>
//

//
// Mdown usage:
//
//   var text = "Markdown *rocks*.";
//   alert(mdown(text));
//


class Markdown {
    
  static var instance:Markdown;
    
  // Global hashes, used by various utility routines
  var g_urls: Hash<String>;
  var g_titles: Hash<String>;
  var g_html_blocks: Array<String>;
  
  // Global filter lists
  var g_block_filters: FilterList;
  var g_span_filters: FilterList;
  
  // main creates a Markdown instance
  static function initiate () { instance = new Markdown(); }
  
  // create a static function to convert to html
  public static function convert (s:String)
  {
  	if (instance == null) initiate();
  	return Markdown.instance.makeHtml(s);
  }
  
  function init () {
  
    g_block_filters=new FilterList();
    
    g_block_filters.add(10, doHeaders);
    g_block_filters.add(20, doHorizontalRules);
    g_block_filters.add(30, doLists);
    g_block_filters.add(40, doHeaders);
    g_block_filters.add(50, doCodeBlocks);
    g_block_filters.add(60, doBlockQuotes);
    g_block_filters.add(70, hashHTMLBlocks);
    g_block_filters.add(80, formParagraphs);
    
    g_span_filters=new FilterList();
    
    g_span_filters.add(10, doCodeSpans);
    g_span_filters.add(20, escapeSpecialInAttributes);
    g_span_filters.add(30, encodeBackslashEscapes);
    g_span_filters.add(40, doImages);
    g_span_filters.add(50, doAnchors);
    g_span_filters.add(60, doAutoLinks);
    g_span_filters.add(70, encodeAmpsAndAngles);
    g_span_filters.add(80, doItalicsAndBold);
    g_span_filters.add(90, doHardBreaks);
    
  }
  
  
  // constructor
  function new () {
    init();
  }
  
  //
  // Main function. The order in which other subs are called here is
  // essential. Link and image substitutions need to happen before
  // escapeSpecialInAttributes(), so that any *'s or _'s in the <a>
  // and <img> tags get encoded.
  //
  public function makeHtml (text: String): String {

    // Clear the global hashes. If we don't clear these, you get conflicts
    // from other articles when generating a page which contains more than
    // one article (e.g. an index page that shows the N most recent
    // articles):
    g_urls = new Hash();
    g_titles = new Hash();
    g_html_blocks = new Array();

    // attacklab: Replace ~ with ~T
    // This lets us use tilde as an escape char to avoid md5 hashes
    // The choice of character is arbitray; anything that isn't
      // magic in Markdown will work.
    text = replaceText(text,~/~/g,"~T");

    // attacklab: Replace $ with ~D
    // RegExp interprets $ as a special character
    // when it's in a replacement string
    text = replaceText(text,~/\$/g,"~D");

    // Standardize line endings
    text = replaceText(text,~/\r\n/g,"\n"); // DOS to Unix
    text = replaceText(text,~/\r/g,"\n"); // Mac to Unix

    // Make sure text begins and ends with a couple of newlines:
    text = "\n\n" + text + "\n\n";

    // Convert all tabs to spaces.
    text = detab(text);

    // Strip any lines consisting only of spaces and tabs.
    // This makes subsequent regexen easier to write, because we can
    // match consecutive blank lines with /\n+/ instead of something
    // contorted like /[ \t]*\n+/ .
    text = replaceText(text,~/^[ \t]+$/mg,"");

    // Turn block-level HTML blocks into hash entries
    text = hashHTMLBlocks(text);

    // Strip link definitions, store in hashes.
    text = stripLinkDefs(text);

    text = runBlockGamut(text);

    text = unescapeSpecial(text);

    // attacklab: Restore dollar signs
    text = replaceText(text,~/~D/g,"$$");

    // attacklab: Restore tildes
    text = replaceText(text,~/~T/g,"~");

    return text;
  }

  //
  // Globals:
  //


  // Used to track when we're inside an ordered or unordered list
  // (see processListItems() for details):
  var g_list_level : Int;



  function stripLinkDefs (text) {
  //
  // Strips link definitions from text, stores the URLs and titles in
  // hash references.
  //

    // Link defs are in the form: ^[id]: url "optional title"

    /*
      var text = replaceText(text,/
          ^[ ]{0,3}\[(.+)\]:  // id = $1  attacklab: g_tab_width - 1
            [ \t]*
            \n?        // maybe *one* newline
            [ \t]*
          <?(\S+?)>?      // url = $2
            [ \t]*
            \n?        // maybe one newline
            [ \t]*
          (?:
            (\n*)        // any lines skipped = $3 attacklab: lookbehind removed
            ["(]
            (.+?)        // title = $4
            [")]
            [ \t]*
          )?          // title is optional
          (?:\n+|$)
          /gm,
          function(){...});
    */
    var text = replaceFn(
      text,
      ~/^[ ]{0,3}\[(.+)\]:[ \t]*\n?[ \t]*<?(\S+?)>?[ \t]*\n?[ \t]*(?:(\n*)["(](.+?)[")][ \t]*)?(?:\n+)/m,
      stripLinkDefs_cb
    );

    return text;
  }
  
  function stripLinkDefs_cb (re: EReg): String {
    var m1 = re.matched(1).toLowerCase();
    var m3 = re.matched(3);
    var m4 = re.matched(4);
    g_urls.set(m1, encodeAmpsAndAngles(re.matched(2)));  // Link IDs are case-insensitive
    if (m3!='') {
      // Oops, found blank lines, so it's not a title.
      // Put back the parenthetical statement we stole.
      return m3+m4;
    } else if (m4!='') {
      g_titles.set(m1, replaceText(m4, ~/"/g,"&quot;"));
    }
    
    // Completely remove the definition from the text
    return "";
  }

  function hashHTMLBlocks (text) {
    // attacklab: Double up blank lines to reduce lookaround
    text = replaceText(text,~/\n/g,"\n\n");

    // Hashify HTML blocks:
    // We only want to do this for block-level HTML tags, such as headers,
    // lists, and tables. That's because we still want to wrap <p>s around
    // "paragraphs" that are wrapped in non-block-level tags, such as anchors,
    // phrase emphasis, and spans. The list of tags we're looking for is
    // hard-coded:
    var block_tags_a = "p|div|h[1-6]|blockquote|pre|table|dl|ol|ul|script|noscript|form|fieldset|iframe|math|ins|del";
    var block_tags_b = "p|div|h[1-6]|blockquote|pre|table|dl|ol|ul|script|noscript|form|fieldset|iframe|math";

    // First, look for nested blocks, e.g.:
    //   <div>
    //     <div>
    //     tags for inner block must be indented.
    //     </div>
    //   </div>
    //
    // The outermost tags must start at the left margin for this to match, and
    // the inner nested divs must be indented.
    // We need to do this before the next, more liberal match, because the next
    // match will start at the first `<div>` and stop at the first `</div>`.

    // attacklab: This regex can be expensive when it fails.
    /*
      var text = replaceText(text,/
      (            // save in $1
        ^          // start of line  (with /m)
        <($block_tags_a)  // start tag = $2
        \b          // word break
                  // attacklab: hack around khtml/pcre bug...
        [^\r]*?\n      // any number of lines, minimally matching
        </\2>        // the matching end tag
        [ \t]*        // trailing spaces/tabs
        (?=\n+)        // followed by a newline
      )            // attacklab: there are sentinel newlines at end of document
      /gm,function(){...}};
    */
    text = replaceFn(text,~/^(<(p|div|h[1-6]|blockquote|pre|table|dl|ol|ul|script|noscript|form|fieldset|iframe|math|ins|del)\b[^\r]*?\n<\/\2>[ \t]*(?=\n+))/m,hashElement);

    //
    // Now match more liberally, simply from `\n<tag>` to `</tag>\n`
    //

    /*
      var text = replaceText(text,/
      (            // save in $1
        ^          // start of line  (with /m)
        <($block_tags_b)  // start tag = $2
        \b          // word break
                  // attacklab: hack around khtml/pcre bug...
        [^\r]*?        // any number of lines, minimally matching
        .*</\2>        // the matching end tag
        [ \t]*        // trailing spaces/tabs
        (?=\n+)        // followed by a newline
      )            // attacklab: there are sentinel newlines at end of document
      /gm,function(){...}};
    */
    text = replaceFn(text,~/^(<(p|div|h[1-6]|blockquote|pre|table|dl|ol|ul|script|noscript|form|fieldset|iframe|math)\b[^\r]*?.*<\/\2>[ \t]*(?=\n+)\n)/m,hashElement);

    // Special case just for <hr />. It was easier to make a special case than
    // to make the other regex more complicated.  

    /*
      text = replaceText(text,/
      (            // save in $1
        \n\n        // Starting after a blank line
        [ ]{0,3}
        (<(hr)        // start tag = $2
        \b          // word break
        ([^<>])*?      //
        \/?>)        // the matching end tag
        [ \t]*
        (?=\n{2,})      // followed by a blank line
      )
      /g,hashElement);
    */
    text = replaceFn(text,~/(\n[ ]{0,3}(<(hr)\b([^<>])*?\/?>)[ \t]*(?=\n{2,}))/,hashElement);

    // Special case for standalone HTML comments:

    /*
      text = replaceText(text,/
      (            // save in $1
        \n\n        // Starting after a blank line
        [ ]{0,3}      // attacklab: g_tab_width - 1
        <!
        (--[^\r]*?--\s*)+
        >
        [ \t]*
        (?=\n{2,})      // followed by a blank line
      )
      /g,hashElement);
    */
    text = replaceFn(text,~/(\n\n[ ]{0,3}<!(--[^\r]*?--\s*)+>[ \t]*(?=\n{2,}))/,hashElement);

    // PHP and ASP-style processor instructions (<?...?> and <%...%>)

    /*
      text = replaceText(text,/
      (?:
        \n\n        // Starting after a blank line
      )
      (            // save in $1
        [ ]{0,3}      // attacklab: g_tab_width - 1
        (?:
          <([?%])      // $2
          [^\r]*?
          \2>
        )
        [ \t]*
        (?=\n{2,})      // followed by a blank line
      )
      /g,hashElement);
    */
    text = replaceFn(text,~/(?:\n\n)([ ]{0,3}(?:<([?%])[^\r]*?\2>)[ \t]*(?=\n{2,}))/,hashElement);

    // attacklab: Undo double lines (see comment at top of this function)
    text = replaceText(text,~/\n\n/g,"\n");
    return text;
  }

  function hashElement (re: EReg): String {
    var blockText=re.matched(1);
    // Undo double lines
    blockText = replaceText(blockText,~/\n\n/g,"\n");
    blockText = replaceText(blockText,~/^\n/,"");
    
    // strip trailing blank lines
    blockText = replaceText(blockText,~/\n+$/g,"");
    
    // Replace the element text with a marker ("~KxK" where x is its key)
    g_html_blocks.push(blockText);
    blockText = "\n\n~K" + (g_html_blocks.length-1) + "K\n\n";
    
    return blockText;
  }

  function runBlockGamut (text: String) {
    return g_block_filters.run(text);
    /*
  // var text=re.matched(0);
    
  //
  // These are all the transformations that form block-level
  // tags like paragraphs, headers, and list items.
  //
    text = doHeaders(text);

    // Do Horizontal Rules:
    var key = hashBlock("<hr />");
    text = replaceText(text,~/^[ ]{0,2}([ ]?\*[ ]?){3,}[ \t]*$/gm,key);
    text = replaceText(text,~/^[ ]{0,2}([ ]?-[ ]?){3,}[ \t]*$/gm,key);
    text = replaceText(text,~/^[ ]{0,2}([ ]?_[ ]?){3,}[ \t]*$/gm,key);

    text = doLists(text);
    text = doCodeBlocks(text);
    text = doBlockQuotes(text);

    // We already ran hashHTMLBlocks() before, in Markdown(), but that
    // was to escape raw HTML in the original Markdown source. This time,
    // we're escaping the markup we've just created, so that we don't wrap
    // <p> tags around block-level tags.
    text = hashHTMLBlocks(text);
    text = formParagraphs(text);

    return text;
    */
  }


  function runSpanGamut (text) {
    return g_span_filters.run(text);
    /*
  //
  // These are all the transformations that occur *within* block-level
  // tags like paragraphs, headers, and list items.
  //

    text = doCodeSpans(text);
    text = escapeSpecialInAttributes(text);
    text = encodeBackslashEscapes(text);

    // Process anchor and image tags. Images must come first,
    // because ![foo][f] looks like an anchor.
    text = doImages(text);
    text = doAnchors(text);

    // Make links out of things like `<http://example.com/>`
    // Must come after doAnchors(), because you can use < and >
    // delimiters in inline links like [this](<url>).
    text = doAutoLinks(text);
    text = encodeAmpsAndAngles(text);
    text = doItalicsAndBold(text);

    // Do hard breaks:
    text = replaceText(text,~/  +\n/g," <br />\n");

    return text;
    */
  }

  function escapeSpecialInAttributes (text) {
  //
  // Within tags -- meaning between < and > -- encode [\ ` * _] so they
  // don't conflict with their use in Markdown for code, italics and strong.
  //

    // Build a regex to find HTML tags and comments.  See Friedl's
    // "Mastering Regular Expressions", 2nd Ed., pp. 200-201.
    var regex = ~/(<[a-z\/!$]("[^"]*"|'[^']*'|[^'">])*>|<!(--.*?--\s*)+>)/i;

    text = replaceFn(text, regex, escapeSpecialInAttributes_cb);

    return text;
  }
  
  function escapeSpecialInAttributes_cb (re: EReg): String {
    var tag = replaceText(re.matched(0),~/(.)<\/?code>(?=.)/g,"$1`");
    tag = escapeCharacters(tag,"\\`*_");
    return tag;
  }

  function doAnchors (text) {
  //
  // Turn Markdown link shortcuts into XHTML <a> tags.
  //
    //
    // First, handle reference-style links: [link text] [id]
    //

    /*
      text = replaceText(text,/
      (              // wrap whole match in $1
        \[
        (
          (?:
            \[[^\]]*\]    // allow brackets nested one level
            |
            [^\[]      // or anything else
          )*
        )
        \]

        [ ]?          // one optional space
        (?:\n[ ]*)?        // one optional newline followed by spaces

        \[
        (.*?)          // id = $3
        \]
      )()()()()          // pad remaining backreferences
      /g,doAnchors_callback);
    */
    text = replaceFn(text,~/(\[((?:\[[^\]]*\]|[^\[\]])*)\][ ]?(?:\n[ ]*)?\[(.*?)\])()()()()/,writeAnchorTag);

    //
    // Next, inline-style links: [link text](url "optional title")
    //

    /*
      text = replaceText(text,/
        (            // wrap whole match in $1
          \[
          (
            (?:
              \[[^\]]*\]  // allow brackets nested one level
            |
            [^\[\]]      // or anything else
          )
        )
        \]
        \(            // literal paren
        [ \t]*
        ()            // no id, so leave $3 empty
        <?(.*?)>?        // href = $4
        [ \t]*
        (            // $5
          (['"])        // quote char = $6
          (.*?)        // Title = $7
          \6          // matching quote
          [ \t]*        // ignore any spaces/tabs between closing quote and )
        )?            // title is optional
        \)
      )
      /g,writeAnchorTag);
    */
    text = replaceFn(text,~/(\[((?:\[[^\]]*\]|[^\[\]])*)\]\([ \t]*()<?(.*?)>?[ \t]*((['"])(.*?)\6[ \t]*)?\))/,writeAnchorTag);

    //
    // Last, handle reference-style shortcuts: [link text]
    // These must come last in case you've also got [link test][1]
    // or [link test](/foo)
    //

    /*
      text = replaceText(text,/
      (               // wrap whole match in $1
        \[
        ([^\[\]]+)        // link text = $2; can't contain '[' or ']'
        \]
      )()()()()()          // pad rest of backreferences
      /g, writeAnchorTag);
    */
    text = replaceFn(text,~/(\[([^\[\]]+)\])()()()()()/, writeAnchorTag);

    return text;
  }

  function writeAnchorTag (re: EReg): String {
    // if (m7 == undefined) m7 = "";
    var whole_match: String = re.matched(1);
    var link_text: String   = re.matched(2);
    var link_id: String   = re.matched(3).toLowerCase();
    var url: String    = re.matched(4);
    var title: String  = new String(re.matched(7));
    
    if (url == "") {
      if (link_id == "") {
        // lower-case and turn embedded newlines into spaces
        link_id = replaceText(link_text.toLowerCase(), ~/ ?\n/g," ");
      }
      url = "#"+link_id;
      
      if (g_urls.exists(link_id)) {
        url = g_urls.get(link_id);
        if (g_titles.exists(link_id)) {
          title = g_titles.get(link_id);
        }
      }
      else {
        if (~/\(\s*\)$/m.match(whole_match)) {
          // Special case for explicit empty url
          url = "";
        } else {
          return whole_match;
        }
      }
    }  
    
    url = escapeCharacters(url,"*_");
    var result = "<a href=\"" + url + "\"";
    
    if (title != "") {
      title = replaceText(title,~/"/g,"&quot;");
      title = escapeCharacters(title,"*_");
      result +=  " title=\"" + title + "\"";
    }
    
    result += ">" + link_text + "</a>";
    
    return result;
  }


  function doImages (text) {
  //
  // Turn Markdown image shortcuts into <img> tags.
  //

    //
    // First, handle reference-style labeled images: ![alt text][id]
    //

    /*
      text = replaceText(text,/
      (            // wrap whole match in $1
        !\[
        (.*?)        // alt text = $2
        \]

        [ ]?        // one optional space
        (?:\n[ ]*)?      // one optional newline followed by spaces

        \[
        (.*?)        // id = $3
        \]
      )()()()()        // pad rest of backreferences
      /g,writeImageTag);
    */
    text = replaceFn(text,~/(!\[(.*?)\][ ]?(?:\n[ ]*)?\[(.*?)\])()()()()/,writeImageTag);

    //
    // Next, handle inline images:  ![alt text](url "optional title")
    // Don't forget: encode * and _

    /*
      text = replaceText(text,/
      (            // wrap whole match in $1
        !\[
        (.*?)        // alt text = $2
        \]
        \s?          // One optional whitespace character
        \(          // literal paren
        [ \t]*
        ()          // no id, so leave $3 empty
        <?(\S+?)>?      // src url = $4
        [ \t]*
        (          // $5
          (['"])      // quote char = $6
          (.*?)      // title = $7
          \6        // matching quote
          [ \t]*
        )?          // title is optional
      \)
      )
      /g,writeImageTag);
    */
    text = replaceFn(text,~/(!\[(.*?)\]\s?\([ \t]*()<?(\S+?)>?[ \t]*((['"])(.*?)\6[ \t]*)?\))/,writeImageTag);

    return text;
  }

  function writeImageTag (re: EReg): String {
    var whole_match: String = re.matched(1);
    var alt_text: String   = re.matched(2);
    var link_id: String   = re.matched(3).toLowerCase();
    var url: String    = re.matched(4);
    var title: String  = new String(re.matched(7));
    
    if (url == "") {
      if (link_id == "") {
        // lower-case and turn embedded newlines into spaces
        link_id = replaceText(alt_text.toLowerCase(), ~/ ?\n/g," ");
      }
      url = "#"+link_id;
      
      if (g_urls.exists(link_id)) {
        url = g_urls.get(link_id);
        if (g_titles.exists(link_id)) {
          title = g_titles.get(link_id);
        }
      }
      else {
        return whole_match;
      }
    }  
    
    alt_text = replaceText(alt_text ,~/"/g,"&quot;");
    url = escapeCharacters(url,"*_");
    var result = "<img src=\"" + url + "\" alt=\"" + alt_text + "\"";

    // attacklab: Markdown.pl adds empty title attributes to images.
    // Replicate this bug.

    //if (title != "") {
      title = replaceText(title, ~/"/g,"&quot;");
      title = escapeCharacters(title,"*_");
      result +=  " title=\"" + title + "\"";
    //}
    
    result += " />";
    
    return result;
  }


  function doHeaders (text: String): String {
    
    // Setext-style headers:
    //  Header 1
    //  ========
    //  
    //  Header 2
    //  --------
    //
    text = replaceFn(text, ~/^(.+)[ \t]*\n=+[ \t]*\n+/m, doHeaders_h1_cb);

    text = replaceFn(text, ~/^(.+)[ \t]*\n-+[ \t]*\n+/m, doHeaders_h2_cb);

    // atx-style headers:
    //  # Header 1
    //  ## Header 2
    //  ## Header 2 with closing hashes ##
    //  ...
    //  ###### Header 6
    //

    /*
      text = replaceText(text,/
        ^(\#{1,6})        // $1 = string of #'s
        [ \t]*
        (.+?)          // $2 = Header text
        [ \t]*
        \#*            // optional closing #'s (not counted)
        \n+
      /gm, function() {...});
    */

    text = replaceFn(text, ~/^(#{1,6})[ \t]*(.+?)[ \t]*#*\n+/m, doHeaders_atx_cb);

    return text;
  }
  
  function doHeaders_h1_cb (re: EReg): String{
    return hashBlock("<h1>" + runSpanGamut(re.matched(1)) + "</h1>");
  }
  function doHeaders_h2_cb (re: EReg): String{
    return hashBlock("<h2>" + runSpanGamut(re.matched(1)) + "</h2>");
  }
  function doHeaders_atx_cb (re: EReg): String {
    var h_level = re.matched(1).length;
    return hashBlock("<h" + h_level + ">" + runSpanGamut(re.matched(2)) + "</h" + h_level + ">");
  }


  function doLists (text) {
  //
  // Form HTML ordered (numbered) and unordered (bulleted) lists.
  //

    // attacklab: add sentinel to hack around khtml/safari bug:
    // http://bugs.webkit.org/show_bug.cgi?id=11231
    text += "~0";

    // Re-usable pattern to match any entirel ul or ol list:

    /*
      var whole_list = /
      (                  // $1 = whole list
        (                // $2
          [ ]{0,3}          // attacklab: g_tab_width - 1
          ([*+-]|\d+[.])        // $3 = first list item marker
          [ \t]+
        )
        [^\r]+?
        (                // $4
          ~0              // sentinel for workaround; should be $
        |
          \n{2,}
          (?=\S)
          (?!              // Negative lookahead for another list item marker
            [ \t]*
            (?:[*+-]|\d+[.])[ \t]+
          )
        )
      )/g
    */
    var whole_list = ~/^(([ ]{0,3}([*+-]|\d+[.])[ \t]+)[^\r]+?(~0|\n{2,}(?=\S)(?![ \t]*(?:[*+-]|\d+[.])[ \t]+)))/m;

    if (g_list_level>0) {
      text = replaceFn(text, whole_list, doLists_outer_cb);
    } else {
      whole_list = ~/(\n\n|^\n?)(([ ]{0,3}([*+-]|\d+[.])[ \t]+)[^\r]+?(~0|\n{2,}(?=\S)(?![ \t]*(?:[*+-]|\d+[.])[ \t]+)))/;
      text = replaceFn(text, whole_list, doLists_inner_cb);
    }

    // attacklab: strip sentinel
    text = replaceText(text,~/~0/,"");

    return text;
  }
  
  function doHorizontalRules (text) {
    var key = hashBlock("<hr />");
    text = replaceText(text,~/^[ ]{0,2}([ ]?\*[ ]?){3,}[ \t]*$/gm,key);
    text = replaceText(text,~/^[ ]{0,2}([ ]?-[ ]?){3,}[ \t]*$/gm,key);
    text = replaceText(text,~/^[ ]{0,2}([ ]?_[ ]?){3,}[ \t]*$/gm,key);
    return text;
  }
  
  function doLists_outer_cb (re: EReg): String {
    var list: String = re.matched(1);
    var list_type: String = (~/[*+-]/.match(re.matched(2))) ? "ul" : "ol";

    // Turn double returns into triple returns, so that we can make a
    // paragraph for the last item in a list, if necessary:
    list = replaceText(list, ~/\n{2,}/g,"\n\n\n");
    var result = processListItems(list);

    // Trim any trailing whitespace, to put the closing `</$list_type>`
    // up on the preceding line, to get it past the current stupid
    // HTML block parser. This is a hack to work around the terrible
    // hack that is the HTML block parser.
    result = replaceText(result, ~/\s+$/,"");
    result = "<"+list_type+">" + result + "</"+list_type+">\n";
    return result;
  }
  
  function doLists_inner_cb (re: EReg): String {
    var runup = re.matched(1);
    var list = re.matched(2);

    var list_type = (~/[*+-]/g.match(re.matched(3))) ? "ul" : "ol";
    // Turn double returns into triple returns, so that we can make a
    // paragraph for the last item in a list, if necessary:
    var list = replaceText(list, ~/\n{2,}/g,"\n\n\n");
    var result = processListItems(list);
    result = runup + "<"+list_type+">\n" + result + "</"+list_type+">\n";  
    return result;
  }

  function processListItems (list_str) {
  //
  //  Process the contents of a single ordered or unordered list, splitting it
  //  into individual list items.
  //
    // The $g_list_level global keeps track of when we're inside a list.
    // Each time we enter a list, we increment it; when we leave a list,
    // we decrement. If it's zero, we're not in a list anymore.
    //
    // We do this because when we're not inside a list, we want to treat
    // something like this:
    //
    //    I recommend upgrading to version
    //    8. Oops, now this line is treated
    //    as a sub-list.
    //
    // As a single paragraph, despite the fact that the second line starts
    // with a digit-period-space sequence.
    //
    // Whereas when we're inside a list (or sub-list), that line will be
    // treated as the start of a sub-list. What a kludge, huh? This is
    // an aspect of Markdown's syntax that's hard to parse perfectly
    // without resorting to mind-reading. Perhaps the solution is to
    // change the syntax rules such that sub-lists must start with a
    // starting cardinal number; e.g. "1." or "a.".

    g_list_level++;

    // trim trailing blank lines:
    list_str = replaceText(list_str,~/\n{2,}$/,"\n");

    // attacklab: add sentinel to emulate \z
    list_str += "~0";

    /*
      list_str = list_str.replace(/
        (\n)?              // leading line = $1
        (^[ \t]*)            // leading whitespace = $2
        ([*+-]|\d+[.]) [ \t]+      // list marker = $3
        ([^\r]+?            // list item text   = $4
        (\n{1,2}))
        (?= \n* (~0 | \2 ([*+-]|\d+[.]) [ \t]+))
      /gm, function(){...});
    */
    list_str = replaceFn(list_str, ~/(\n)?(^[ \t]*)([*+-]|\d+[.])[ \t]+([^\r]+?(\n{1,2}))(?=\n*(~0|\2([*+-]|\d+[.])[ \t]+))/m, processListItems_cb);

    // attacklab: strip sentinel
    list_str = replaceText(list_str, ~/~0/g,"");

    g_list_level--;
    return list_str;
  }

  function processListItems_cb (re: EReg): String{
    var item = re.matched(4);
    var leading_line = re.matched(1);
    var leading_space = re.matched(2);

    if (leading_line=='' || (~/\n{2,}/.match(item))) {
      item = runBlockGamut(outdent(item));
    }
    else {
      // Recursion for sub-lists:
      item = doLists(outdent(item));
      item = replaceText(item, ~/\n$/,""); // chomp(item)
      item = runSpanGamut(item);
    }

    return  "<li>" + item + "</li>\n";
  }

  function doCodeBlocks (text) {
  //
  //  Process Markdown `<pre><code>` blocks.
  //  

    /*
      text = replaceText(text,text,
        /(?:\n\n|^)
        (                // $1 = the code block -- one or more lines, starting with a space/tab
          (?:
            (?:[ ]{4}|\t)      // Lines must start with a tab or a tab-width of spaces - attacklab: g_tab_width
            .*\n+
          )+
        )
        (\n*[ ]{0,3}[^ \t\n]|(?=~0))  // attacklab: g_tab_width
      /g,function(){...});
    */

    // attacklab: sentinel workarounds for lack of \A and \Z, safari\khtml bug
    text += "~0";
    
    text = replaceFn(text, ~/(?:\n\n|^)((?:(?:[ ]{4}|\t).*\n+)+)(\n*[ ]{0,3}[^ \t\n]|(?=~0))/, doCodeBlocks_cb);

    // attacklab: strip sentinel
    text = replaceText(text,~/~0/,"");

    return text;
  }
  
  function doCodeBlocks_cb(re: EReg): String {
    var codeblock = re.matched(1);
    var nextChar = re.matched(2);
  
    codeblock = encodeCode( outdent(codeblock));
    codeblock = detab(codeblock);
    codeblock = replaceText(codeblock,~/^\n+/g,""); // trim leading newlines
    codeblock = replaceText(codeblock ,~/\n+$/g,""); // trim trailing whitespace

    codeblock = "<pre><code>" + codeblock + "\n</code></pre>";

    return hashBlock(codeblock) + nextChar;
  }

  function hashBlock (text) {
    text = replaceText(text,~/(^\n+|\n+$)/g,"");
    g_html_blocks.push(text);
    return "\n\n~K" + (g_html_blocks.length-1) + "K\n\n";
  }


  function doCodeSpans (text) {
  //
  //   *  Backtick quotes are used for <code></code> spans.
  //
  //   *  You can use multiple backticks as the delimiters if you want to
  //   include literal backticks in the code span. So, this input:
  //   
  //     Just type ``foo `bar` baz`` at the prompt.
  //   
  //     Will translate to:
  //   
  //     <p>Just type <code>foo `bar` baz</code> at the prompt.</p>
  //   
  //  There's no arbitrary limit to the number of backticks you
  //  can use as delimters. If you need three consecutive backticks
  //  in your code, use four for delimiters, etc.
  //
  //  *  You can use spaces to get literal backticks at the edges:
  //   
  //     ... type `` `bar` `` ...
  //   
  //     Turns to:
  //   
  //     ... type <code>`bar`</code> ...
  //

    /*
      text = replaceText(text,/
        (^|[^\])          // Character before opening ` can't be a backslash
        (`+)            // $2 = Opening run of `
        (              // $3 = The code block
          [^\r]*?
          [^`]          // attacklab: work around lack of lookbehind
        )
        \2              // Matching closer
        (?!`)
      /gm, function(){...});
    */

    text = replaceFn(text, ~/(^|[^\\])(`+)([^\r]*?[^`])\2(?!`)/m, doCodeSpans_cb);

    return text;
  }

  function doCodeSpans_cb (re: EReg): String {
    var c = re.matched(3);
    c = replaceText(c,~/^([ \t]*)/g,"");  // leading whitespace
    c = replaceText(c,~/[ \t]*$/g,"");  // trailing whitespace
    c = encodeCode(c);
    return re.matched(1)+"<code>"+c+"</code>";
  }

  function encodeCode (text) {
  //
  // Encode/escape certain characters inside Markdown code runs.
  // The point is that in code, these characters are literals,
  // and lose their special Markdown meanings.
  //
    // Encode all ampersands; HTML entities are not
    // entities within a Markdown code span.
    text = replaceText(text,~/&/g,"&amp;");

    // Do the angle bracket song and dance:
    text = replaceText(text,~/</g,"&lt;");
    text = replaceText(text,~/>/g,"&gt;");

    // Now, escape characters that are magic in Markdown:
    text = escapeCharacters(text,"*_{}[]\\",false);

  // jj the line above breaks this:
  //---

  //* Item

  //   1. Subitem

  //            special char: *
  //---

    return text;
  }


  function doItalicsAndBold (text) {

    // <strong> must go first:
    text = replaceText(text,~/(\*\*|__)(?=\S)([^\r]*?\S[\*_]*)\1/g,"<strong>$2</strong>");

    text = replaceText(text,~/(\*|_)(?=\S)([^\r]*?\S)\1/g,"<em>$2</em>");

    return text;
  }

  function doHardBreaks (text) {
    return replaceText(text,~/  +\n/g," <br />\n");
  }
    
  function doBlockQuotes (text) {

    /*
      text = replaceText(text,/
      (                // Wrap whole match in $1
        (
          ^[ \t]*>[ \t]?      // '>' at the start of a line
          .+\n          // rest of the first line
          (.+\n)*          // subsequent consecutive lines
          \n*            // blanks
        )+
      )
      /gm, function(){...});
    */

    text = replaceFn(text, ~/((^[ \t]*>[ \t]?.+\n(.+\n)*\n*)+)/m, doBlockQuotes_cb);
    return text;
  }

  function doBlockQuotes_cb (re: EReg): String {
    var bq = re.matched(1);

    // attacklab: hack around Konqueror 3.5.4 bug:
    // "----------bug".replace(/^-/g,"") == "bug"

    bq = replaceText(bq,~/^[ \t]*>[ \t]?/gm,"~0");  // trim one level of quoting

    // attacklab: clean up hack
    bq = replaceText(bq,~/~0/g,"");

    bq = replaceText(bq,~/^[ \t]+$/gm,"");    // trim whitespace-only lines
    bq = runBlockGamut(bq);        // recurse
    
    bq = replaceText(bq,~/(^|\n)/g,"$1  ");
    // These leading spaces screw with <pre> content, so we need to fix that:
    bq = replaceFn(bq, ~/(\s*<pre>[^\r]+?<\/pre>)/m, doBlockQuotes_cb_cb);
    
    return hashBlock("<blockquote>\n" + bq + "\n</blockquote>");
  }
  
  function doBlockQuotes_cb_cb (re) {
    var pre = re.matched(1);
    // attacklab: hack around Konqueror 3.5.4 bug:
    pre = replaceText(pre,~/^  /mg,"~0");
    pre = replaceText(pre,~/~0/g,"");
    return pre;
  }

  function formParagraphs (text) {
  //
  //  Params:
  //    $text - string to process with html <p> tags
  //

    // Strip leading and trailing lines:
    text = replaceText(text,~/^\n+/g,"");
    text = replaceText(text,~/\n+$/g,"");

    var grafs = ~/\n{2,}/g.split(text);
    var grafsOut = new Array();

    //
    // Wrap <p> tags.
    //
    var end = grafs.length;
    for (i in 0...end) {
      var str = grafs[i];

      // if this is an HTML marker, copy it
      if (~/~K(\d+)K/g.match(str)) {
        grafsOut.push(str);
      }
      else if (~/\S/.match(str)) {
        str = runSpanGamut(str);
        str = replaceText(str,~/^([ \t]*)/g,"<p>");
        str += "</p>";
        grafsOut.push(str);
      }

    }

    //
    // Unhashify HTML blocks
    //
    end = grafsOut.length;
    for (i in 0...end) {
      // if this is a marker for an html block...
      var re = ~/~K(\d+)K/;
      while (re.match(grafsOut[i])) {
        var blockText = g_html_blocks[Std.parseInt(re.matched(1))];
        blockText = replaceText(blockText,~/\$/g,"$$$$"); // Escape any dollar signs
        grafsOut[i] = replaceText(grafsOut[i],~/~K\d+K/,blockText);
      }
    }

    return grafsOut.join("\n\n");
  }


  function encodeAmpsAndAngles (text) {
  // Smart processing for ampersands and angle brackets that need to be encoded.
    
    // Ampersand-encoding based entirely on Nat Irons's Amputator MT plugin:
    //   http://bumppo.net/projects/amputator/
    text = replaceText(text,~/&(?!#?[xX]?(?:[0-9a-fA-F]+|\w+);)/g,"&amp;");
    
    // Encode naked <'s
    text = replaceText(text,~/<(?![a-z\/?\$!])/gi,"&lt;");
    
    return text;
  }


  function encodeBackslashEscapes (text) {
  //
  //   Parameter:  String.
  //   Returns:  The string, with after processing the following backslash
  //         escape sequences.
  //

    // attacklab: The polite way to do this is with the new
    // escapeCharacters() function:
    //
    //   text = escapeCharacters(text,"\",true);
    //   text = escapeCharacters(text,"`*_{}[]()>#+-.!",true);
    //
    // ...but we're sidestepping its use of the (slow) RegExp constructor
    // as an optimization for Firefox.  This function gets called a LOT.

    text = replaceFn(text,~/\\(\\)/,escapeCharactersCallback);
    text = replaceFn(text,~/\\([`*_{}\[\]()>#+-.!])/,escapeCharactersCallback);
    return text;
  }


  function doAutoLinks (text) {

    text = replaceText(text,~/<((https?|ftp|dict):[^'">\s]+)>/gi,"<a href=\"$1\">$1</a>");    

    // Email addresses: <address@domain.foo>

    /*
      text = replaceText(text,/
        <
        (?:mailto:)?
        (
          [-.\w]+
          \@
          [-a-z0-9]+(\.[-a-z0-9]+)*\.[a-z]+
        )
        >
      /gi, doAutoLinks_callback());
    */
    text = replaceFn(text, ~/<(?:mailto:)?([-.\w]+@[-a-z0-9]+(\.[-a-z0-9]+)*\.[a-z]+)>/i, doAutoLinks_cb);

    return text;
  }
  
  function doAutoLinks_cb (re) {
    return encodeEmail( unescapeSpecial(re.matched(1)) );
  }

  function encodeEmail (addr) {
  //
  //  Input: an email address, e.g. "foo@example.com"
  //
  //  Output: the email address as a mailto link, with each character
  //  of the address encoded as either a decimal or hex entity, in
  //  the hopes of foiling most address harvesting spam bots. E.g.:
  //
  //  <a href="&#x6D;&#97;&#105;&#108;&#x74;&#111;:&#102;&#111;&#111;&#64;&#101;
  //     x&#x61;&#109;&#x70;&#108;&#x65;&#x2E;&#99;&#111;&#109;">&#102;&#111;&#111;
  //     &#64;&#101;x&#x61;&#109;&#x70;&#108;&#x65;&#x2E;&#99;&#111;&#109;</a>
  //
  //  Based on a filter by Matthew Wickline, posted to the BBEdit-Talk
  //  mailing list: <http://tinyurl.com/yu7ue>
  //

    // attacklab: why can't javascript speak hex?


    addr = "mailto:" + addr;

    addr = replaceFn(addr, ~/./, encodeEmail_cb);

    addr = "<a href=\"" + addr + "\">" + addr + "</a>";
    addr = replaceText(addr, ~/">.+:/g,"\">"); // strip the mailto: from the visible part

    return addr;
  }


  function encodeEmail_cb (re: EReg): String {
    var char2hex = function (ch) {
      var hexDigits = '0123456789ABCDEF';
      var dec = ch.charCodeAt(0);
      return(hexDigits.charAt(dec>>4) + hexDigits.charAt(dec&15));
    };
    var encode = [
      function(ch){return "&#"+ch.charCodeAt(0)+";";},
      function(ch){return "&#x"+char2hex(ch)+";";},
      function(ch){return ch;}
    ];
    var ch = re.matched(0);
    if (ch == "@") {
        // this *must* be encoded. I insist.
      ch = encode[Math.floor(Math.random()*2)](ch);
    } else if (ch !=":") {
      // leave ':' alone (to spot mailto: later)
      var r = Math.random();
      // roughly 10% raw, 45% hex, 45% dec
      ch =  (
          r > .9  ?  encode[2](ch)   :
          r > .45 ?  encode[1](ch)   :
                encode[0](ch)
        );
    }
    return ch;
  }

  function unescapeSpecial (text) {
  //
  // Swap back in all the special characters we've hidden.
  //
    text = replaceFn(text, ~/~E(\d+)E/, unescapeSpecial_cb);
    return text;
  }

  function unescapeSpecial_cb (re: EReg): String {
    var charCodeToReplace: Int = Std.parseInt(re.matched(1));
    return  String.fromCharCode(charCodeToReplace);
  }

  function outdent (text) {
  //
  // Remove one level of line-leading tabs or spaces
  //

    // attacklab: hack around Konqueror 3.5.4 bug:
    // "----------bug".replace(/^-/g,"") == "bug"

    text = replaceText(text,~/^(\t|[ ]{1,4})/gm,"~0"); // attacklab: g_tab_width

    // attacklab: clean up hack
    text = replaceText(text,~/~0/g,"");

    return text;
  }

  function detab (text) {
  // attacklab: Detab's completely rewritten for speed.
  // In perl we could fix it by anchoring the regexp with \G.
  // In javascript we're less fortunate.

    // expand first n-1 tabs
    text = replaceText(text,~/\t(?=\t)/g,"    "); // attacklab: g_tab_width

    // replace the nth with two sentinels
    text = replaceText(text,~/\t/g,"~A~B");

    // use the sentinel to anchor our regex so it doesn't explode
    text = replaceFn(text,~/~B(.+?)~A/, detab_cb);

    // clean up sentinels
    text = replaceText(text,~/~A/g,"    ");  // attacklab: g_tab_width
    text = replaceText(text,~/~B/g,"");

    return text;
  }
  
  function detab_cb (re: EReg):String {
    var leadingText: String = re.matched(1);
    var numSpaces: Int = 4 - leadingText.length % 4;  // attacklab: g_tab_width

    // there *must* be a better way to do this:
    for (i in 0...numSpaces) leadingText+=" ";

    return leadingText;
  }

  //
  //  attacklab: Utility functions
  //

  function escapeCharacters (text: String, charsToEscape: String, ?afterBackslash: Bool) {
    // First we have to escape the escape characters so that
    // we can build a character class out of them
    var regexString = "([" + replaceText(charsToEscape,~/([\[\]\\])/g,"\\$1") + "])";

    if (afterBackslash) {
      regexString = "\\\\" + regexString;
    }

    var regex = new EReg(regexString, "");
    text = replaceFn(text,regex,escapeCharactersCallback);

    return text;
  }

  function escapeCharactersCallback (re: EReg): String {
    var charCodeToEscape = re.matched(1).charCodeAt(0);
    return "~E"+charCodeToEscape+"E";
  }

  //
  //  mdown: More utility functions
  //
  function replaceText (orig: String, regex: EReg, replacement: String) {
    return regex.replace(orig, replacement);
  }
  
  function replaceFn (orig: String, regex: EReg, fn) {
    return regex.customReplace(orig, fn);
  }

}

class FilterList {
  public var filters:Array<Filter>;
  private var sorted:Bool;
  // constructor
  public function new () {
    filters=[];
  }
  public function add (p:Int, f:String->String) {
    sorted=false;
    filters.push(new Filter(p, f));
  }
  public function run (text:String): String {
    if (!sorted) {
      sorted=true;
      filters.sort(sort);
    }
    var end=filters.length;
    for (i in 0...end) {
      text = filters[i].fn(text);
    }
    return text;
  }
  private function sort (a:Filter, b:Filter):Int {
    return a.priority > b.priority ? 1 : -1;
  }
}

class Filter {
  public var priority:Int;
  public var fn:String->String;
  // constructor
  public function new (p:Int, f:String->String) {
    priority=p;
    fn=f;
  }
}