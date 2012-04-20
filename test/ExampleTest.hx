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



}