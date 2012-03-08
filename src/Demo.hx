import Markdown;

class Demo 
{
	static public function main()
	{
		var r:String;

		var r = Markdown.convert(
"This is my file
================

Small header
------------

 * List Item 1
 * List Item 2

Is a thing in the middle okay?

Howdy?
"
		);
		trace (r);
	}
}