package filters;
import MarkdownExtension;

/**
* Process Github-style code blocks
* Example:
* ```ruby
* def hello_world(x)
*   puts "Hello, #{x}"
* end
* ```
*/ 
class GithubCodeBlocks implements MarkdownExtension
{
	public var inst:Markdown;
	public var type = MarkdownExtensionType.BLOCK;
	public var priority = 49;

	public function filter(text:String):String
	{

		// attacklab: sentinel workarounds for lack of \A and \Z, safari\khtml bug
		text += "~0";
		
		text = ~/\n```(.*)\n([^`]+)\n```/g.customReplace(text, function (re: EReg) {
			var language = re.matched(1);
			var codeblock = re.matched(2);
		
			codeblock = inst.encodeCode(codeblock);
			codeblock = inst.detab(codeblock);
			codeblock = ~/^\n+/g.replace(codeblock, ""); // trim leading newlines
			codeblock = ~/\n+$/g.replace(codeblock,""); // trim trailing whitespace

			codeblock = "<pre><code class='" + language + "'>" + codeblock + "\n</code></pre>";

			return inst.hashBlock(codeblock);
		});

		// attacklab: strip sentinel
		text = ~/~0/.replace(text, "");

		return text;
	}
}