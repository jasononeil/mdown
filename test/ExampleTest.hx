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



}