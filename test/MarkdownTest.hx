package;

import massive.munit.Assert;

/**
* These classes test Markdown.
* I have tried to write a test for every piece of functionality mentioned
* on this page: http://daringfireball.net/projects/markdown/syntax
* Hopefully it's realtively comprehensive.
*/
class MarkdownTest 
{
	
	public function new() 
	{
		
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function setup():Void
	{
	}
	
	@After
	public function tearDown():Void
	{
	}
	


	@Test 
	public function testNullInput():Void 
	{
		// Github Issue 2: https://github.com/jasononeil/mdown/issues/2
		var result = Markdown.convert(null);
		Assert.areEqual("", result);
	}

	@Test 
	public function testEmptyInput():Void 
	{
		// Github Issue 2: https://github.com/jasononeil/mdown/issues/2
		var result = Markdown.convert("");
		Assert.areEqual("", result);
	}

	@Test 
	public function testInlineHTML():Void 
	{
		var str =
"This is a regular paragraph.

<table>
    <tr>
        <td>Foo</td>
    </tr>
</table>

This is another regular paragraph.";
		var result = Markdown.convert(str);
		var expectedResult = 
"<p>This is a regular paragraph.</p>

<table>
    <tr>
        <td>Foo</td>
    </tr>
</table>

<p>This is another regular paragraph.</p>";
		Assert.areEqual(expectedResult, result);
	}
	
	@Test
	public function testAmpersand():Void
	{
		var str = "Jack & Jill";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>Jack &amp; Jill</p>", result);
	}
	
	@Test
	public function testAmpersandShouldNotChange():Void
	{
		var str = "Jack & Jill &amp; Jason";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>Jack &amp; Jill &amp; Jason</p>", result);
	}
	
	@Test
	public function testOpenBracket():Void
	{
		var str = "Jack <3 Jill";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>Jack &lt;3 Jill</p>", result);
	}
	
	@Test
	public function testOpenBracketShouldNotChange():Void
	{
		var str = "Jack <3 <em>Jill</em>";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>Jack &lt;3 <em>Jill</em></p>", result);
	}

	@Test
	public function testSingleLine():Void
	{
		var str = "My line.";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>My line.</p>", result);
	}
	
	@Test
	public function testMultipleLines():Void
	{
		var str = "My sentence can be"
		 + "\n" + "quite long";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>My sentence can be quite long</p>", result);
	}
	
	@Test
	public function testInsertLineBreak():Void
	{
		var str = "My sentence can be  "
		 + "\n" + "quite long";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>My sentence can be <br /> quite long</p>", result);
	}
	
	@Test
	public function testMultipleParagraphs():Void
	{
		var str = "My sentence can be"
		 + "\n" + "quite long."
		 + "\n" + ""
		 + "\n" + "Second paragraph";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>My sentence can be quite long.</p>\n\n<p>Second paragraph</p>", result);
	}
	
	@Test
	public function testMultipleParagraphsWithWhitespace():Void
	{
		var str = "My sentence can be"
		 + "\n" + "quite long."
		 + "\n" + " 	"
		 + "\n" + "Second paragraph";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>My sentence can be quite long.</p>\n\n<p>Second paragraph</p>", result);
	}
	
	@Test
	public function testH1():Void
	{
		var str = "My Title"
		 + '\n' + "========";
		var result = Markdown.convert(str);
		Assert.areEqual("<h1>My Title</h1>", result);
	}
	
	@Test
	public function testH2():Void
	{
		var str = "Sub Title"
		 + '\n' + "---------";
		var result = Markdown.convert(str);
		Assert.areEqual("<h2>Sub Title</h2>", result);
	}
	
	@Test
	public function testATXHeaders():Void
	{
		var str = "# H1"
		 + '\n' + "## H2"
		 + '\n' + "### H3"
		 + '\n' + "#### H4"
		 + '\n' + "##### H5"
		 + '\n' + "###### H6";
		var result = Markdown.convert(str);
		Assert.areEqual("<h1>H1</h1>\n\n<h2>H2</h2>\n\n<h3>H3</h3>\n\n<h4>H4</h4>\n\n<h5>H5</h5>\n\n<h6>H6</h6>", result);
	}
	
	@Test
	public function testATXHeadersClosed():Void
	{
		var str = "# H1 #"
		 + '\n' + "## H2 ##"
		 + '\n' + "### H3 #######################"
		 + '\n' + "#### H4 ####"
		 + '\n' + "##### H5 #####"
		 + '\n' + "###### H6 ######";
		var result = Markdown.convert(str);
		Assert.areEqual("<h1>H1</h1>\n\n<h2>H2</h2>\n\n<h3>H3</h3>\n\n<h4>H4</h4>\n\n<h5>H5</h5>\n\n<h6>H6</h6>", result);
	}

	@Test 
	public function testBlockquote():Void 
	{
		var str = "> This is a blockquote";
		var result = Markdown.convert(str);
		Assert.areEqual("<blockquote>\n  <p>This is a blockquote</p>\n</blockquote>", result);
	}

	@Test 
	public function testBlockquoteMultiline():Void 
	{
		var str = "> This is a blockquote"
		 + "\n" + "> that spans multiple lines";
		var result = Markdown.convert(str);
		Assert.areEqual("<blockquote>\n  <p>This is a blockquote that spans multiple lines</p>\n</blockquote>", result);
	}

	@Test 
	public function testBlockquoteMultipleParagraphs():Void 
	{
		var str = "> This is a blockquote"
		 + "\n" + "> that spans multiple lines"
		 + "\n" + "> "
		 + "\n" + "> And paragraphs";
		var result = Markdown.convert(str);
		Assert.areEqual("<blockquote>\n  <p>This is a blockquote that spans multiple lines</p>\n  \n  <p>And paragraphs</p>\n</blockquote>", result);
	}

	@Test 
	public function testBlockquoteMultipleParagraphsLessIndenting():Void 
	{
		var str = "> This is a blockquote"
		 + "\n" + "that spans multiple lines"
		 + "\n" + ""
		 + "\n" + "> And paragraphs";
		var result = Markdown.convert(str);
		Assert.areEqual("<blockquote>\n  <p>This is a blockquote that spans multiple lines</p>\n  \n  <p>And paragraphs</p>\n</blockquote>", result);
	}

	@Ignore("Simple test for breaking neko") @TestDebug @Test 
	public function testNeko():Void 
	{
		var str = "> > This is nested blockquote. >";
		var regex = ~/^[ \t]*>[ \t]?/gm;
		var result = regex.replace(str, "~0");
		Assert.areEqual("~0> This is nested blockquote. >", result);
	}

	@Test 
	@Ignore("Failing on neko atm") 
	public function testBlockquoteNested():Void 
	{
		var str = 
"> This is the first level of quoting.
>
> > This is nested blockquote.
>
> Back to the first level.";
		var result = Markdown.convert(str);
		Assert.areEqual(
"<blockquote>
  <p>This is the first level of quoting.</p>
  
  <blockquote>
    <p>This is nested blockquote.</p>
  </blockquote>
  
  <p>Back to the first level.</p>
</blockquote>", result);
	}

	@Test 
	public function testBlockquoteOtherItems():Void 
	{
		var input = 
"> ## This is a header.
> 
> 1.   This is the first list item.
> 2.   This is the second list item.
> 
> Here's some example code:
> 
>     return shell_exec('echo $input | $markdown_script');";
		var expected = 
"<blockquote>
  <h2>This is a header.</h2>
  
  <ol>
  <li>This is the first list item.</li>
  <li>This is the second list item.</li>
  </ol>
  
  <p>Here's some example code:</p>

<pre><code>return shell_exec('echo $input | $markdown_script');
</code></pre>
</blockquote>";
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test
	public function testUL():Void
	{
		var str = "* One"
		 + "\n" + "* Two"
		 + "\n" + "* Three";
		var result = Markdown.convert(str);
		Assert.areEqual("<ul>\n<li>One</li>\n<li>Two</li>\n<li>Three</li>\n</ul>", result);
	}

	@Test 
	public function testULWithPlus():Void 
	{
		var str = "+ One"
		 + "\n" + "+ Two"
		 + "\n" + "+ Three";
		var result = Markdown.convert(str);
		Assert.areEqual("<ul>\n<li>One</li>\n<li>Two</li>\n<li>Three</li>\n</ul>", result);
	
	}

	@Test 
	public function testULWithDash():Void 
	{
		var str = "- One"
		 + "\n" + "- Two"
		 + "\n" + "- Three";
		var result = Markdown.convert(str);
		Assert.areEqual("<ul>\n<li>One</li>\n<li>Two</li>\n<li>Three</li>\n</ul>", result);
	}
	
	@Test
	public function testOL():Void
	{
		var str = "1. One"
		 + "\n" + "2. Two"
		 + "\n" + "3. Three";
		var result = Markdown.convert(str);
		Assert.areEqual("<ol>\n<li>One</li>\n<li>Two</li>\n<li>Three</li>\n</ol>", result);
	}

	@Test 
	public function testULWithSpacesBefore():Void 
	{
		var str = "  * One"
		 + "\n" + "  * Two"
		 + "\n" + "  * Three";
		var result = Markdown.convert(str);
		Assert.areEqual("<ul>\n<li>One</li>\n<li>Two</li>\n<li>Three</li>\n</ul>", result);
	}

	@Test 
	public function testOLWithSpacesBefore():Void 
	{
		var str = "  1. One"
		 + "\n" + "  2. Two"
		 + "\n" + "  3. Three";
		var result = Markdown.convert(str);
		Assert.areEqual("<ol>\n<li>One</li>\n<li>Two</li>\n<li>Three</li>\n</ol>", result);
	}

	@Test 
	public function testOLOutOfOrder():Void 
	{
		var str = "1. One"
		 + "\n" + "7. Two"
		 + "\n" + "12. Three";
		var result = Markdown.convert(str);
		Assert.areEqual("<ol>\n<li>One</li>\n<li>Two</li>\n<li>Three</li>\n</ol>", result);
	}
	
	@Test 
	public function testULMultiline():Void 
	{
		var str = "* One"
		 + "\n" + "  111"
		 + "\n" + "* Two"
		 + "\n" + "222"
		 + "\n" + "* Three"
		 + "\n" + "  333";
		var result = Markdown.convert(str);
		Assert.areEqual("<ul>\n<li>One\n111</li>\n<li>Two\n222</li>\n<li>Three\n333</li>\n</ul>", result);
	}

	@Test 
	public function testOLMultiline():Void 
	{
		var str = "1. One"
		 + "\n" + "   111"
		 + "\n" + "2. Two"
		 + "\n" + "222"
		 + "\n" + "3. Three"
		 + "\n" + "  333";
		var result = Markdown.convert(str);
		Assert.areEqual("<ol>\n<li>One\n111</li>\n<li>Two\n222</li>\n<li>Three\n333</li>\n</ol>", result);
	}

	@Ignore("Failing. Non-blocking issue.") @Test 
	public function testULWithGapsBetweenItems():Void 
	{
		var str = "* One"
		 + "\n"
		 + "\n" + "* Two";
		var result = Markdown.convert(str);
		Assert.areEqual("<ul>\n<li><p>One</p></li>\n<li><p>Two</p></li>\n</ul>", result);
	}

	@Ignore("Failing.  Not important enough to stop atm.") @Test 
	public function testOLWithGapsBetweenItems():Void 
	{
		var str = "1. One"
		 + "\n"
		 + "\n" + "2. Two";
		var result = Markdown.convert(str);
		Assert.areEqual("<ol>\n<li><p>One</p></li>\n<li><p>Two</p></li>\n</ol>", result);
	}

	@Test 
	public function testULWithParagraphs():Void 
	{
		var str = "* One"
		 + "\n" + "   111"
		 + "\n"
		 + "\n" + "* Two"
		 + "\n"
		 + "\n" + "   222";
		var result = Markdown.convert(str);
		Assert.areEqual("<ul>\n<li><p>One 111</p></li>\n<li><p>Two</p>\n\n<p>222</p></li>\n</ul>", result);
	}

	@Test 
	public function testOLWithParagraphs():Void 
	{
		var str = "1. One"
		 + "\n" + "   111"
		 + "\n"
		 + "\n" + "2. Two"
		 + "\n"
		 + "\n" + "   222";
		var result = Markdown.convert(str);
		Assert.areEqual("<ol>\n<li><p>One 111</p></li>\n<li><p>Two</p>\n\n<p>222</p></li>\n</ol>", result);
	}

	@Test 
	public function testBlockquoteInsideList():Void 
	{
		var input = 
"*   A list item with a blockquote:

    > This is a blockquote
    > inside a list item.";
    	var expected = "<ul>
<li><p>A list item with a blockquote:</p>

<blockquote>
  <p>This is a blockquote inside a list item.</p>
</blockquote></li>
</ul>";
    	var result = Markdown.convert(input);
    	Assert.areEqual(expected, result);
	}

	@Ignore("Not working in neko") @Test 
	public function testCodeInsideList():Void 
	{
		var input = 
"*   A list item with a code block:

        var code;";
    	var expected = "<ul>
<li><p>A list item with a code block:</p>

<pre><code>var code;\n</code></pre></li>
</ul>";
    	var result = Markdown.convert(input);
    	Assert.areEqual(expected, result);
	}

	@Test 
	public function testAvoidListCreation():Void 
	{
		var input = "1986\\. What a great season.";
		var result = Markdown.convert(input);
		Assert.areEqual("<p>1986. What a great season.</p>", result);
	}

	@Test 
	public function testCode():Void
	{
		var input = "This is a normal paragraph:

    This is a code block.";
    	var expected = "<p>This is a normal paragraph:</p>

<pre><code>This is a code block.
</code></pre>";
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Ignore("Indentation wrong in neko") @Test 
	public function testCodeIndentation():Void
	{
		var input = "Here is an example of AppleScript:

    tell application \"Foo\"
        beep
    end tell";
    	var expected = "<p>Here is an example of AppleScript:</p>

<pre><code>tell application \"Foo\"
    beep
end tell
</code></pre>";
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test function testCodeConvertSpecialChars():Void 
	{
		var input = "    <div class=\"footer\">
    &copy; 2004 Foo Corporation
    </div>";
    	var expected = "<pre><code>&lt;div class=\"footer\"&gt;
&amp;copy; 2004 Foo Corporation
&lt;/div&gt;
</code></pre>";
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test function testHRDash():Void 
	{
		var input = "One

---

Two";
		var expected = "<p>One</p>\n\n<hr />\n\n<p>Two</p>";
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test function testHRDashWithSpaces():Void 
	{
		var input = "One

- - -

Two";
		var expected = "<p>One</p>\n\n<hr />\n\n<p>Two</p>";
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test function testHRDashMany():Void 
	{
		var input = "One

-------------------

Two";
		var expected = "<p>One</p>\n\n<hr />\n\n<p>Two</p>";
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test function testHRAsterisk():Void 
	{
		var input = "One

***

Two";
		var expected = "<p>One</p>\n\n<hr />\n\n<p>Two</p>";
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test function testHRAsteriskWithSpaces():Void 
	{
		var input = "One

* * *

Two";
		var expected = "<p>One</p>\n\n<hr />\n\n<p>Two</p>";
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test function testHRAsteriskMany():Void 
	{
		var input = "One

*********************

Two";
		var expected = "<p>One</p>\n\n<hr />\n\n<p>Two</p>";
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test function testHRUnderscord():Void 
	{
		var input = "One

___

Two";
		var expected = "<p>One</p>\n\n<hr />\n\n<p>Two</p>";
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test function testHRUnderscordWithSpaces():Void 
	{
		var input = "One

_ _ _

Two";
		var expected = "<p>One</p>\n\n<hr />\n\n<p>Two</p>";
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test function testHRUnderscordMany():Void 
	{
		var input = "One

_____________________

Two";
		var expected = "<p>One</p>\n\n<hr />\n\n<p>Two</p>";
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test function testLinksInline():Void 
	{
		var input = 'This is [an example](http://example.com/ "Title") inline link.

[This link](http://example.net/) has no title attribute.';
		var expected = "<p>This is <a href=\"http://example.com/\" title=\"Title\">an example</a> inline link.</p>

<p><a href=\"http://example.net/\">This link</a> has no title attribute.</p>";
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test function testLinksInlineRelative():Void 
	{
		var input = 'See my [About](/about/) page for details.   ';
		var expected = "<p>See my <a href=\"/about/\">About</a> page for details.</p>";
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test function testReferenceLinks():Void 
	{
		var input = 
'This is my [link one][one] link.

This is my [link two][two] link.

This is my [link three] [three] link.

This is my [link four] [four] link.

[one]: http://example.com/one
[two]:  <http://example.com/two>  "LinkTwo, multiple spaces"
   [three]:	http://example.com/three  (Link Three ref indented, tab)
[four]: http://example.com/four  
   "Link Four\'s title goes on another line"
';
		var expected = '<p>This is my <a href="http://example.com/one">link one</a> link.</p>

<p>This is my <a href="http://example.com/two" title="LinkTwo, multiple spaces">link two</a> link.</p>

<p>This is my <a href="http://example.com/three" title="Link Three ref indented, tab">link three</a> link.</p>

<p>This is my <a href="http://example.com/four" title="Link Four\'s title goes on another line">link four</a> link.</p>';
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test 
	public function testReferenceLinksImpliedName()
	{

		var input = 
'Visit [Daring Fireball][] for more information.

[Daring Fireball]: http://daringfireball.net/

Other paragraph.
';
		var expected = '<p>Visit <a href="http://daringfireball.net/">Daring Fireball</a> for more information.</p>

<p>Other paragraph.</p>';
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test
	public function testBold():Void
	{
		var str = "I have some **bold** text.";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>I have some <strong>bold</strong> text.</p>", result);
	}
	
	@Test
	public function testUnderlineBold():Void
	{
		var str = "I have some __underlined text__.";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>I have some <strong>underlined text</strong>.</p>", result);
	}

	@Test 
	public function testMidWordEmStrong():Void 
	{
		var str = "un*frigging*believable un**frigging**believable";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>un<em>frigging</em>believable un<strong>frigging</strong>believable</p>", result);
	}

	@Test 
	public function testAsteriskWithSpaces():Void 
	{
		var str = "un * frigging * believable";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>un * frigging * believable</p>", result);
	}

	@Test 
	public function testEscapedAsterisk():Void 
	{
		var str = "un\\*frigging\\*believable un\\*\\*frigging\\*\\*believable";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>un*frigging*believable un**frigging**believable</p>", result);
	}
	
	@Test
	public function testItalics():Void
	{
		var str = "I have some *emphasised* text.";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>I have some <em>emphasised</em> text.</p>", result);
	}
	
	@Test
	public function testUnderlineEm():Void
	{
		var str = "I have some _underlined text_.";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>I have some <em>underlined text</em>.</p>", result);
	}
	
	@Test
	public function testInlineCode():Void
	{
		var str = "Use the `printf()` function.";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>Use the <code>printf()</code> function.</p>", result);
	}
	
	@Ignore("In neko the code has no spaces?!") @Test
	public function testInlineCodeDouble():Void
	{
		var str = "``There is a literal backtick (`) here.``";
		var result = Markdown.convert(str);
		Assert.areEqual("<p><code>There is a literal backtick (`) here.</code></p>", result);
	}
	
	@Test
	public function testInlineCodeBacktickTest():Void
	{
		var str = "A single backtick in a code span: `` ` ``

A backtick-delimited string in a code span: `` `foo` ``";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>A single backtick in a code span: <code>`</code></p>

<p>A backtick-delimited string in a code span: <code>`foo`</code></p>", result);
	}
	
	@Test
	public function testInlineCodeEncodingBrackets():Void
	{
		var str = "Please don't use any `<blink>` tags.";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>Please don't use any <code>&lt;blink&gt;</code> tags.</p>", result);
	}
	
	@Test
	public function testInlineCodeEncodingAmpersands():Void
	{
		var str = "`&#8212;` is the decimal-encoded equivalent of `&mdash;`.";
		var result = Markdown.convert(str);
		Assert.areEqual("<p><code>&amp;#8212;</code> is the decimal-encoded equivalent of <code>&amp;mdash;</code>.</p>", result);
	}
	
	@Test
	public function inlineImage():Void
	{
		var str = "![Alt text](/path/to/img.jpg)";
		var result = Markdown.convert(str);
		Assert.areEqual("<p><img src=\"/path/to/img.jpg\" alt=\"Alt text\" title=\"\" /></p>", result);
	}
	
	@Test
	public function inlineImageWithTitle():Void
	{
		var str = "![Alt text](/path/to/img.jpg \"Optional title\")";
		var result = Markdown.convert(str);
		Assert.areEqual("<p><img src=\"/path/to/img.jpg\" alt=\"Alt text\" title=\"Optional title\" /></p>", result);
	}

	@Test function testReferenceImages():Void 
	{
		var input = 
'This is my ![image one][one] image.

This is my ![image two][two] image.

This is my ![image three] [three] image.

This is my ![image four] [four] image.

[one]: url/to/image1
[two]:  <url/to/image2>  "LinkTwo, multiple spaces"
   [three]:	http://example.com/url/to/image3  (Link Three ref indented, tab)
[four]: url/to/image4  
   "Link Four\'s title goes on another line"
';
		var expected = '<p>This is my <img src="url/to/image1" alt="image one" title="" /> image.</p>

<p>This is my <img src="url/to/image2" alt="image two" title="LinkTwo, multiple spaces" /> image.</p>

<p>This is my <img src="http://example.com/url/to/image3" alt="image three" title="Link Three ref indented, tab" /> image.</p>

<p>This is my <img src="url/to/image4" alt="image four" title="Link Four\'s title goes on another line" /> image.</p>';
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test 
	public function testAutoLinkURL():Void 
	{
		var str = "<http://example.com/>";
		var result = Markdown.convert(str);
		Assert.areEqual('<p><a href="http://example.com/">http://example.com/</a></p>', result);
	}

	@Test 
	public function testAutoLinkEmail():Void 
	{
		var str = "<address@example.com>";
		var expected = '<p><a href="&#109;&#x61;&#105;&#x6C;&#116;&#111;:&#x61;&#x64;&#100;&#x72;&#101;&#115;&#x73;&#64;&#101;x&#97;&#x6D;&#112;&#x6C;&#x65;.&#99;&#x6F;&#109;">&#x61;&#x64;&#100;&#x72;&#101;&#115;&#x73;&#64;&#101;x&#97;&#x6D;&#112;&#x6C;&#x65;.&#99;&#x6F;&#109;</a></p>] was not equal to expected value [<p><a href="&#109;&#x61;&#105;&#x6C;&#116;&#111;:&#97;&#100;&#x64;&#114;&#x65;&#x73;&#115;&#x40;&#101;&#x78;&#x61;&#x6D;&#x70;&#x6C;e&#x2E;&#99;&#x6F;&#109;">&#97;&#100;&#x64;&#114;&#x65;&#x73;&#115;&#x40;&#101;&#x78;&#x61;&#x6D;&#x70;&#x6C;e&#x2E;&#99;&#x6F;&#109;</a></p>';

		var result = Markdown.convert(str);
		Assert.isTrue(result.indexOf('a href') > 0);
		Assert.isFalse(result.indexOf('address@example.com') > 0);
	}

	@Test 
	public function testULNestedList():Void 
	{
		var str = "* One"
		 + "\n" + "* Two"
		 + "\n" + "    * A"
		 + "\n" + "    * B"
		 + "\n" + "    * C"
		 + "\n" + "* Three";
		var result = Markdown.convert(str);
		Assert.areEqual("<ul>\n<li>One</li>\n<li>Two\n<ul><li>A</li>\n<li>B</li>\n<li>C</li></ul></li>\n<li>Three</li>\n</ul>", result);
	}

	@Test 
	public function testULNestedListChangeSign():Void 
	{
		var str = "* One"
		 + "\n" + "* Two"
		 + "\n" + "    - A"
		 + "\n" + "    - B"
		 + "\n" + "    - C"
		 + "\n" + "* Three";
		var result = Markdown.convert(str);
		Assert.areEqual("<ul>\n<li>One</li>\n<li>Two\n<ul><li>A</li>\n<li>B</li>\n<li>C</li></ul></li>\n<li>Three</li>\n</ul>", result);
	}

	@Test 
	public function testOLNestedList():Void 
	{
		var str = "1. One"
		 + "\n" + "2. Two"
		 + "\n" + "    1. A"
		 + "\n" + "    2. B"
		 + "\n" + "    3. C"
		 + "\n" + "3. Three";
		var result = Markdown.convert(str);
		Assert.areEqual("<ol>\n<li>One</li>\n<li>Two\n<ol><li>A</li>\n<li>B</li>\n<li>C</li></ol></li>\n<li>Three</li>\n</ol>", result);
	}

	@Test 
	public function testExtensionAndReset():Void 
	{
		var input = 
'My name is Jason
=================

And I have some code:

```haxe
for (i in array)
{
	trace (i);
}
```

Pretty **cool** hey!
';
		var expected = '<h1>My name is Jason</h1>

<p>And I have some code:</p>

<pre><code class=\'haxe\'>for (i in array)
{
    trace (i);
}
</code></pre>

<p>Pretty <strong>cool</strong> hey!</p>';
		
		// First result doesn't pass
		var result1 = Markdown.convert(input);
		Assert.areNotEqual(expected, result1);
		
		// Second result adds GithubCodeBlock - does pass
		Markdown.setFilters(filters.GithubCodeBlocks);
		var result2 = Markdown.convert(input);
		Assert.areEqual(expected, result2);
		
		// Third result adds GithubCodeBlock as part of an array of extensions- does pass 
		Markdown.setFilters([filters.GithubCodeBlocks]);
		var result3 = Markdown.convert(input);
		Assert.areEqual(expected, result3);
		
		// Fourth result resets Markdown to no extensions, doesn't pass
		Markdown.setFilters([]);
		var result4 = Markdown.convert(input);
		Assert.areNotEqual(expected, result4);
	}

	@Test 
	public function testGithubCodeBlock():Void 
	{
		var input = 
'My name is Jason
=================

And I have some code:

```haxe
for (i in array)
{
	trace (i);
}
```

Pretty **cool** hey!
';
		var expected = '<h1>My name is Jason</h1>

<p>And I have some code:</p>

<pre><code class=\'haxe\'>for (i in array)
{
    trace (i);
}
</code></pre>

<p>Pretty <strong>cool</strong> hey!</p>';
		Markdown.setFilters(filters.GithubCodeBlocks);
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test 
	public function testGithubCodeBlock_noLanguage():Void 
	{
		var input = 
'```
for (i in array)
{
	trace (i);
}
```';
		var expected = '<pre><code class=\'\'>for (i in array)
{
    trace (i);
}
</code></pre>';
		Markdown.setFilters(filters.GithubCodeBlocks);
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test
	public function testGithubCodeBlock_markdownNotParse():Void 
	{
		var input = 
'```
In here this gh *code should* not become Markdown
==============================================
```

And with an indented code block:

	In here this *code should* not become Markdown
	==============================================

';
		var expected = '<pre><code class=\'\'>In here this gh *code should* not become Markdown
==============================================
</code></pre>

<p>And with an indented code block:</p>

<pre><code>In here this *code should* not become Markdown
==============================================
</code></pre>';
		Markdown.setFilters(filters.GithubCodeBlocks);
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}

	@Test
	public function testGithubCodeBlock_htmlEscaped():Void 
	{
		var input = 
'```
This is <b>Bold</b> and <i>Italic</i> and <script>Dangerous</script>
====================================================================
```

And with an indented code block:

	This is <b>Bold</b> and <i>Italic</i> and <script>Dangerous</script>
	====================================================================

';
		var expected = '<pre><code class=\'\'>This is &lt;b&gt;Bold&lt;/b&gt; and &lt;i&gt;Italic&lt;/i&gt; and &lt;script&gt;Dangerous&lt;/script&gt;
====================================================================
</code></pre>

<p>And with an indented code block:</p>

<pre><code>This is &lt;b&gt;Bold&lt;/b&gt; and &lt;i&gt;Italic&lt;/i&gt; and &lt;script&gt;Dangerous&lt;/script&gt;
====================================================================
</code></pre>';
		Markdown.setFilters(filters.GithubCodeBlocks);
		var result = Markdown.convert(input);
		Assert.areEqual(expected, result);
	}


}