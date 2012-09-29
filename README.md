MDown
=====

This is a port of Markdown for haxe.  

If you don't know what Markdown is, it's a really easy way to write documents using nothing but a text editor.  They look fine in normal text, but then you can convert it into pretty HTML with little effort.  See this link: http://daringfireball.net/projects/markdown/

If you don't know what haxe is, and you're a programmer, then you should.  It's a language that can target JS, PHP, CPP (and mobile!), C#, Java and Neko all from the same codebase.  This library is designed to work exactly the same no matter which platform you are targetting.  That is the genious of haxe.  See http://haxe.org/

Currently this library has been tested and works on Neko, Flash9+, JS and CPP.

Installation
------------

I haven't uploaded this to haxelib yet.  Hopefully I will soon.  In the meantime you can just copy "Markdown.hx" directly into your project.

Usage
-----

There's really only one static function you need to know, Markdown.convert():

```haxe
import Markdown;

class Main
{
	static public function main()
	{
		var input = "This is **Markdown** text";
		var output = Markdown.convert(input);
		trace (output);
	}
}
```

And then when you compile, remember to add the Markdown lib to your haxe project:

`haxe -neko main.n -lib mdown -main Main`

Or have a hxml file like this:

~~~
-main Main
-lib mdown
-neko main.n
~~~

And you're set to go!

Extensions
----------

I have slightly restructured the project to allow you to insert Extensions into Markdown.  As a first example, I have added an extension which allows you to use [Github style code blocks](https://github.com/jasononeil/mdown/wiki/Github-Code-Blocks).  To use an extension in your code, you call `Markdown.setFilters()`.

```haxe
import filters.GithubCodeBlocks;

// And then in your code, import a single filter
Markdown.setFilters(GithubCodeBlocks);

// Or multiple filters
Markdown.setFilters([GithubCodeBlocks, my.custom.MarkdownFilter]);

// Reset to the default filters
Markdown.setFilters();
```

If you would like to build your own extensions, or port extensions from other markdown libraries (it's not hard to convert them to Haxe), you can look at the [filters/GithubCodeBlocks.hx](https://github.com/jasononeil/mdown/blob/master/src/filters/GithubCodeBlocks.hx) file for an example of how it works, or ask on the [Haxe mailing list](https://groups.google.com/forum/?hl=en&fromgroups#!forum/haxelang) and I'll try give some further instructions.  At some point I'll leave instructions on the wiki.  If anyone makes a cool extension and wants it included I'll take pull requests!

History
-------

  * This is a fork of mdown 
    http://code.google.com/p/mdown/
  * Which was based on Showdown, Copyright (c) 2007 John Fraser.
    http://www.attacklab.net/showdown/ 
  * Original Markdown Copyright (c) 2004-2005 John Gruber
    http://daringfireball.net/projects/markdown/

The main difference between this and the original "mdown" is that I am writing to target Haxe, not the haxe targets.  As a result, this will be released on haxelib and I am writing tests to ensure it will pass on multiple targets, particularly neko, which was failing originally.

TODO, Issues & Contributing
---------------------------

 * Stop ignoring testULWithParagraphs() and testOLWithParagraphs().  These tests are failing on all targets, and I am ignoring them for now.
 * Look into why Neko and CPP are failing some tests.  In particular:
 	* Nested blockquotes
 	* Code Indentation
 	* Inline code spans inside a list item
 * Test on PHP, Java, C#
 * Make a haxelib command line tool to convert a static file.

 All contributions welcome.  I'm using github so it's relatively easy to make a copy, make some changes, and do a pull request.

 It seems the original mdown on google code hasn't been touched in years.  If the original author wants me to contribute back my changes I'll try figure out how to do that :)


