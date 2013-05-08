/****
* mdown -- A haxe port of Markdown.
* 
* Based on the Showdown, Copyright (c) 2007 John Fraser.
*   <http://www.attacklab.net/>
* 
* Original Markdown Copyright (c) 2004-2005 John Gruber
*   <http://daringfireball.net/projects/markdown/>
****/

interface MarkdownExtension {
	var inst : Markdown;
    var type : Int;
    var priority : Int;
    function filter(text : String) : String;
}

class MarkdownExtensionType 
{
	public static inline var SPAN = 0;
	public static inline var BLOCK = 1;
}