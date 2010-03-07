There are two known public C# libraries for using CouchDB:
 1. [[http://github.com/foretagsplatsen/Divan|Divan]]
 2. [[http://code.google.com/p/couchbrowse|SharpCouch]]

== Divan ==
The git repository at http://github.com/foretagsplatsen/Divan has a relatively complete C# library for CouchDB using Newtonsoft.JSON and NUnit as its only external dependencies. Divan is actively maintained and in use at Foretagsplatsen (a swedish company using it in their core system). Being the author of Divan I claim it to be much more complete than !SharpCouch :)

For more information see the [[http://github.com/foretagsplatsen/Divan|README]]. 
{{{
git clone git://github.com/foretagsplatsen/Divan.git
}}}

== SharpCouch ==
The project at http://code.google.com/p/couchbrowse contains a simple wrapper library for CouchDB, called !SharpCouch, and a GUI client which makes use of the library. The GUI client code should serve as a good usage example, although the wrapper class is documented and fairly self-explanatory anyway.

You can get the source by issuing the following SVN command:

{{{
svn checkout http://couchbrowse.googlecode.com/svn/trunk/ couchbrowse
}}}

The project was built with !SharpDevelop 2.2, but should work out of the box with Visual Studio 2005. Getting it to work with !MonoDevelop should be reasonably easy, but has not been tried yet.
