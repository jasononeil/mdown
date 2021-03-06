/****
* mdown -- A haxe port of Markdown.
* 
* Based on the Showdown, Copyright (c) 2007 John Fraser.
*   <http://www.attacklab.net/>
* 
* Original Markdown Copyright (c) 2004-2005 John Gruber
*   <http://daringfireball.net/projects/markdown/>
****/

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
*
* Borrowed heavily from Showdown, specifically looking at this pull request:
* https://github.com/coreyti/showdown/pull/9/files
*/ 
class GithubCodeBlocks implements MarkdownExtension
{
	public var inst:Markdown;
	public var type = MarkdownExtensionType.BLOCK;
	public var priority = 9; // It needs to run before the block gamut

	public function filter(text:String):String
	{
		// attacklab: sentinel workarounds for lack of \A and \Z, safari\khtml bug
		text += "~0";
		
		text = ~/\n```(.*)\n([^`]+)\n```/g.customReplace(text, function (re: EReg) {
			if (text.indexOf("In here this gh *code should* not become Markdown") > -1)
			{
				//js.Lib.debug();
			}
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