package;

import massive.munit.Assert;

/**
* Auto generated ExampleTest for MassiveUnit. 
* This is an example test class can be used as a template for writing normal and async tests 
* Refer to munit command line tool for more information (haxelib run munit)
*/
class ExampleTest 
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
	public function testSingleLine():Void
	{
		var str = "My line.";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>My line.</p>", result);
	}
	
	@Test
	public function testMultipleLines():Void
	{
		var str = "My sentance can be"
		 + "\n" + "quite long";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>My sentance can be quite long</p>", result);
	}
	
	@Test
	public function testMultipleParagraphs():Void
	{
		var str = "My sentance can be"
		 + "\n" + "quite long."
		 + "\n" + ""
		 + "\n" + "Second paragraph";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>My sentance can be quite long.</p>\n\n<p>Second paragraph</p>", result);
	}
	
	@Test
	public function testMultipleParagraphsWithWhitespace():Void
	{
		var str = "My sentance can be"
		 + "\n" + "quite long."
		 + "\n" + " 	"
		 + "\n" + "Second paragraph";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>My sentance can be quite long.</p>\n\n<p>Second paragraph</p>", result);
	}
	
	@Test
	public function testBold():Void
	{
		var str = "I have some **bold** text.";
		var result = Markdown.convert(str);
		Assert.areEqual("<p>I have some <strong>bold</strong> text.</p>", result);
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
	public function testUL():Void
	{
		var str = "* One"
		 + "\n" + "* Two"
		 + "\n" + "* Three";
		var result = Markdown.convert(str);
		Assert.areEqual("<ul>\n<li>One</li>\n<li>Two</li>\n<li>Three</li>\n</ul>", result);
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

	@Ignore("Failing. Non-blocking issue.") @Test 
	public function testULWithGapsBetweenItems():Void 
	{
		var str = "* One"
		 + "\n"
		 + "\n" + "* Two";
		var result = Markdown.convert(str);
		Assert.areEqual("<ul>\n<li><p>One</p></li>\n<li><p>Two</p></li>\n</ul>", result);
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
	public function testULWithSpacesBefore():Void 
	{
		var str = "  * One"
		 + "\n" + "  * Two"
		 + "\n" + "  * Three";
		var result = Markdown.convert(str);
		Assert.areEqual("<ul>\n<li>One</li>\n<li>Two</li>\n<li>Three</li>\n</ul>", result);
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
	public function testOL():Void
	{
		var str = "1. One"
		 + "\n" + "2. Two"
		 + "\n" + "3. Three";
		var result = Markdown.convert(str);
		Assert.areEqual("<ol>\n<li>One</li>\n<li>Two</li>\n<li>Three</li>\n</ol>", result);
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
	public function testOLOutOfOrder():Void 
	{
		var str = "1. One"
		 + "\n" + "7. Two"
		 + "\n" + "12. Three";
		var result = Markdown.convert(str);
		Assert.areEqual("<ol>\n<li>One</li>\n<li>Two</li>\n<li>Three</li>\n</ol>", result);
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

}