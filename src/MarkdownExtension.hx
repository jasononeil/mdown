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