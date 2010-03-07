Here're the quick procedures for building dependency libraries of couchDB on Windows with Visual C++ Express edition SP1:

You will need the following software installed on your system:

 *[[http://www.microsoft.com/express/vc/|Visual C++ Express Edition SP1]]
 *[[http://activestate.com|ActivePerl]]

== Buildeing libeay32.dll ==

Download OpenSSL source file from [[http://www.openssl.org/source|OpenSSL]].
Extract the source archive to working directory.

open Visual Studio's command prompt from Start menu. Change directory to the working directory.
do cofiguration :
{{{
perl Configure VC-WIN32
}}}

You have options here to use some assembler like MASM or NASM to get better performance.
But we don't them neither to make the story simple: 

{{{
ms\do_ms
}}}

Then build.

{{{
nmake -f ms\ntdll.mak
}}}

If you want to confirm that the build went went right, you can test:

{{{
nmake -f ms\ntdll.mak test
}}}

Now you'll find libeay32.dll in <working directory>\out32dll.
Please rememver that this procedure is one of the quickest one only to get libeay32.dll.
Refer to official documemts for the build options or installing OpenSSL to your system.

== Buildeing js32.dll (Spider Monkey) ==

Download Spider Monkey source file from [[http://www.mozilla.org/js/spidermonkey/|Here]].
From mirrors or the download URL, download something like js-1.7.0.tar and extract 
the archive to working directory.

open Visual Sudio's command prompt from Start menu. Change directory to the working directory.

Now you must be ready to build, but actually not. According to [[http://blog.endflow.net/?p=55&lang=en|this site]], you must fix
js.mak before you start building the binary.

After fixing (or replacing js.mak), do build:

{{{
nmake -f "js.mak" CFG="jsshell - Win32 Debug"
}}}

And you will find js32.dll and jsshell.exe in the Debug directory under the working directory.
