MDown
=====

This is a port of Markdown for haxe.  

If you don't know what Markdown is, it's a really easy way to write documents using nothing but a text editor.  They look fine in normal text, but then you can convert it into pretty HTML with little effort.  See this link: http://daringfireball.net/projects/markdown/

If you don't know what haxe is, and you're a programmer, then you should.  It's a language that can target JS, PHP, CPP (and mobile!), C#, Java and Neko all from the same codebase.  This library is designed to work exactly the same no matter which platform you are targetting.  That is the genious of haxe.  See http://haxe.org/

Installation
------------

I haven't uploaded this to haxelib yet.  Hopefully I will soon.  In the meantime you can just copy "Markdown.hx" directly into your project.

Usage
-----

There's really only one static function you need to know, Markdown.convert():

~~~
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
~~~

And then when you compile, remember to add the Markdown lib to your haxe project:

`haxe -neko main.n -lib mdown -main Main`

Or have a hxml file like this:

~~~
-main Main
-lib mdown
-neko main.n
~~~

And you're set to go!

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

 * Stop ignoring testULWithParagraphs() and testOLWithParagraphs().  These tests are failing, and I am ignoring them for now.
 * Test on CPP, PHP.
 * Make a haxelib command line tool to convert a static file.

 All contributions welcome.  I'm using github so it's relatively easy to make a copy, make some changes, and do a pull request.

 It seems the original mdown on google code hasn't been touched in years.  If the original author wants me to contribute back my changes I'll try figure out how to do that :)


