## page was renamed from GettingStartedWithC

If you want to operate CouchDB with C, you must use HTTP requests. You can directly invoke socket to do that, or accomplish it with a library that encapsulates HTTP. CURL is one such library. To obtain a copy of the CURL library or information on it like its usage, just access its website http://curl.haxx.se/.

After CURL is installed, simply include its C header file as below
{{{
#include <curl/curl.h>
}}}
and link its library file (the file name of which contains string "libcurl") into the executable file.

The following code segment shows an example of operating CouchDB with CURL.
{{{
CURL *curl;
FILE *fp;
struct stat file_info;

/* the name of the file containing json data */
const char *const file_name = "data_source";

curl_global_init(CURL_GLOBAL_ALL);

stat(file_name, &file_info);
fp = fopen(file_name, "r");

curl = curl_easy_init();
if(curl) {
  /* uses HTTP PUT */
  curl_easy_setopt(curl, CURLOPT_UPLOAD, 1L);

  /* URL */
  curl_easy_setopt(curl, CURLOPT_URL, "http://192.168.0.40:5984/test_db/test_doc");

  /* input file */
  curl_easy_setopt(curl, CURLOPT_READDATA, fp);

  /* file size */
  curl_easy_setopt(curl, CURLOPT_INFILESIZE, (long)file_info.st_size);

  /* data type */
  struct curl_slist *slist = NULL;
  slist = curl_slist_append(slist, "Content-Type: application/json");
  curl_easy_setopt(curl, CURLOPT_HTTPHEADER, slist);

  /* makes the request */
  curl_easy_perform(curl);

  curl_slist_free_all(slist);

  curl_easy_cleanup(curl);
}

fclose(fp);

curl_global_cleanup();
}}}

This one is horribly out of date. Don't read it. If you need a C API, you've got to write one. Then update this page accordingly, thanks :)



Getting started with C and the CouchDB API.

== Startup ==

This HOWTO aims to show you how you can easily use the CouchDB C API. You should have basic knowledge of how CouchDB and pointers/structures in C work. Generally the C API should build on every POSIX Operating System (Windows support might be added later). It depends on two important libraries: libcurl and libxml2 (every common GNU/Linux, BSD distribution and Mac OS X ship these libraries). Okay, let's try to compile to API:

{{{
cd /home/user/couchdb/CouchProjects/Libraries/c/src/
make
make install (as root)
}}}

If you get errors like libxml2 or curl support missing, have a look at the Makefile.inc in the src/ directory (some distributions might install these libs in /usr/local..). These two files must now be present on your system: /usr/local/include/libcouchdb.h and /usr/local/lib/libcouchdb.so

== Ready To Go ==

Okay, now let's come to the fun part, using couchdb in your C program. Here is an example that shows you the general usage:

{{{
#include <libcouchdb.h>

int main ( void )
{
	Couch *c = NULL;
	CouchDocument *doc = NULL;

	/* Initialize the couch-api.
	 * The first parameter is the adresse of the server
	 * with the port number. You can use either a full qualified domain name or just
	 * the ip address.
	 * The second parameter allows you to set the database that should be used for
	 * further actions, if you want to do that later on (because you want to create a
	 * database first as we do here) you can set this to NULL.
	 */
	c = couch_init ( "mycouchserver.mynetwork.net:5984", NULL );

	/* Our connection is ready, so create our first database "mydb" */
	couch_db_create ( c, "mydb" );

	/* In order to make further actions possible (creating/deleting databases is not
	 * that thrilling ;-) ) you have to select, which database we want to use.
	 * If you want to work with more than one database just init as many couches as you
	 * need.
	 */
	couch_db_use ( c, "mydb" );

	/* Good, we are now ready to create documents in our database "mydb". The following
	 * function will not instantly create the document but provide us a way to handle
	 * them easily. The creation of the document is done by couch_doc_save() (see below).
	 * You can give your document either a static name or let couchdb generated an
	 * uniue document id for you (this is recommended) with the first parameter.
	 * NULL will let the couchdb generate an id for you.
	 */
	doc = couch_doc_create ( NULL );

	/* Okay, give the document some content.
	 * You will (hopefully) notice two important things: you can give a field
	 * ("Subject", "Body, "Access") more than one value and the last parameter has
	 * always to be NULL. Your program will die a horrible death if you don't use
	 * NULL as the last parameter, so simply do it ;-)
	 */
	couch_doc_set ( doc, "Subject", "This is my first document", NULL );
	couch_doc_set ( doc, "Body", "Hello there. I'm currently working on the creation of my first document in C. It's really easy.", NULL );
	couch_doc_set ( doc, "Access", "joe", "foo", "bar", NULL );

	/* you can also give existing fields new values with the same function */
	couch_doc_set ( doc, "Subject", "This is my very first document", NULL );


	/* So the contents of the document is ready, now we need to send the document
	 * to the couchdb-server.
	 */
	couch_doc_save ( c, doc );


	/* We made it! The document should now be created in the database "mydb".
	 * The last thing we have to do is to cleanup some of the used memory (yes, it's
	 * still c and dynamic memory have to be free()d). Note that you have to use the
	 * reference to the pointer for the cleanup function, because they will set the
	 * doc and c pointers to NULL, just in case a lazy programmer forgets to do that
	 * ;-)
	 */
	couch_doc_cleanup ( &doc );
	couch_cleanup ( &c );


	return 1;
}
}}}

Please keep in mind that this simple example don't do any error handling, it shouldn't crash though, but better keep an eye on the return values of the different functions. There are two different possible error situations: A system error and a database error. System errors might occur if not enough free memory was available, the connection to the server was lost and such things. Our int functions will return -1 in that case, you can check errno what error exactly blew up the program. The database errors occur if you tried to do something silly. For example deleting the same document twice, try to alter a document with another revision and so on. The exact error code is stored in c->result->code (where c is a Couch structure), the error message is stored in c->result->error. Better check the result-code after each transaction with the database (couch_db_create(), couch_doc_save()...).

== Get Things Rolling ==

You now know the basics concept behind this API, most of the other available functions are quite self-explaining (couch_db_remove(), couch_doc_remove(), ...), but we are still missing two very important things: The built-in double-linked lists (returned by couch_db_get_all(), couch_doc_get_all() and couch_table_compute()) and the table handling. Because using tables also includes using the build-in list this is best topic to start with. Have a look at the code below (I only commented new stuff).

{{{
#include <libcouchdb.h>

int process_list ( void *data, void *data_user );
int process_list_content ( void *data, void *data_user );
int process_list_content_field ( void *data, void *data_user );

int main ( void )
{
	Couch *c = NULL;
	CouchDocument *doc = NULL;
	List *l = NULL;

	c = couch_init ( "mycouchserver.mynetwork.net:5984", "mydb" );

	/* Tables are just special documents, but don't forget to give them uniue names! */
	doc = couch_doc_create ( "tabletest" );

	/* Set the table statement. You can use the fabric language for that.
	 * Note that every field has to start with $table_ !
	 */
	couch_doc_set ( doc, "$table_all", "SELECT *;", NULL );
	couch_doc_set ( doc, "$table_private", "SELECT Access=Joe; COLUMN Subject;", NULL );

	/* Save the table. */
	couch_doc_save ( c, doc );

	/* now use the table to query the database */
	l = couch_table_compute ( c, "tabletest:private" );

	/* okay we have now a list with the result. in the most cases, we want to go
	 * through the list and look at it's entries. This is the best way to do that
	 * (though others are possible).
	 */
	list_foreach ( l, process_list, NULL );

	/* we're done, cleanup plz! */
	couch_list_cleanup ( &l );
	couch_doc_cleanup ( &doc );
	couch_cleanup ( &c );
}

/* return values might be:
 * -1: error -> terminate the loop
 *  0: don't jump to the next item -> process this item again
 *  1: everything is fine, go on
 *
 * parameters:
 *   data - pointer to the current item
 *   data_user - pointer to the data of the last parameter of list_foreach().
 *               this data is always the same for each item - unless you change it
 *               in this function of course ;-)
 */
int process_list ( void *data, void *data_user )
{
	CouchDocument *doc = NULL;

	if ( !data || data_user )
		return -1;

	/* the list don't know which item it holds, so we need to cast them.
	 * in the case of couch_table_compute(), we'll get a list of documents and their
	 * contents.
	 */
	doc = (CouchDocument *)data;

	/* now we can do cool things with the document. what about just print them to the
	 * screen? ;-)
	 */
	printf ( "Document: %s\n", doc->docid );

	/* what about the document fields? */
	list_foreach ( doc->content, process_list_content, NULL );

	/* everything is fine, go ahead */
	return 1;
}

int process_list_content ( void *data, void *data_user )
{
	CouchDocumentField *f = NULL;

	if ( !data || data_user )
		return -1;

	/* now the items are CouchDocumentFields. */
	f = (CouchDocumentField *)data;

	/* print the name of the field. */
	printf ( "  Field: %s\n", f->name );

	/* hey, what about the values of a field? yes, third loop ;-) */
	list_foreach ( f->values, process_list_content_field, NULL );

	/* go go! */
	return 1;
}

int process_list_content_field ( void *data, void *data_user )
{
	CouchDocumentFieldContent *c = NULL,

	if ( !data || data_user )
		return -1;

	/* see above ;-) */
	c = (CouchDocumentFieldContent *)data;

	/* print the values */
	printf ( "      Content: %s\n", c->value );

	/* what about... no, forget that ;-) */



	/* go to the next item */
	return 1;
}
}}}

You have a clean code that is separated in logical steps (not one big bloated function) and you can do much more things with a double-linked list than with for example an array. Take a look at the list.h in the inc/ directory of the C API source, there are quite some other possibilities (you can even put everything in one bloated function if you like). So, be sure that this was the most complex task that is possible with this API, if you did understand everything you're ready to write your first CouchDB application!
