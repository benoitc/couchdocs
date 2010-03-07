== Basics ==

CouchDB (0.10 and up) has the ability to allow server-side processing of an incoming document before it's committed. This feature allows a range of use cases such as providing a server-side last modified timestamp, etc.

== Implementation ==

This functionality is implemented via document update handlers defined in a design doc. Specifically, in a design doc one defines an "updates" attribute that contains any number of document update handlers. The follow handlers should be self-explanatory as to what they accomplish. 

{{{
    updates: {

      "hello" : function(doc, req) {
        if (!doc) {
          if (req.docId) {
            return [{
              _id : req.docId
            }, "New World"]
          }
          return [null, "Empty World"];          
        }
        doc.world = "hello";
        doc.edited_by = req.userCtx;
        return [doc, "hello doc"];
      },

      "in-place" : function(doc, req) {
        var field = req.query.field;
        var value = req.query.value;
        var message = "set "+field+" to "+value;
        doc[field] = value;
        return [doc, message];
      },

      "bump-counter" : function(doc, req) {
        if (!doc.counter) doc.counter = 0;
        doc.counter += 1;
        var message = "<h1>bumped it!</h1>";
        return [doc, message];
      },

      "error" : function(doc, req) {
        superFail.badCrash;
      },

      "xml" : function(doc, req) {
        var xml = new XML('<xml></xml>');
        xml.title = doc.title;
        var posted_xml = new XML(req.body);
        doc.via_xml = posted_xml.foo.toString();
        var resp =  {
          "headers" : {
            "Content-Type" : "application/xml"
          },
          "body" : xml
        };
         
         return [doc, resp];
       }
    }
}}}

The handler function takes the document and the http request as parameters. It returns a two-element array: the first element is the (updated) document, which is committed to the database. The second element is the response that will be sent back to the caller.

== Usage ==

To invoke a handler, one must "PUT" the document against the handler function itself (POST does not seem to be supported). Using the canonical document URL won't invoke any handlers.

For example, to invoke the "in-place" handler defined above, the URL to use is:

{{{
http://127.0.0.1:5984/<my_database>/_design/<my_designdoc>/_update/in-place/<mydocId>?field=title&value=test
}}}

This means that unlike document validators, the user's intent must be clear by calling this individual handler explicitly. In this sense, you should think about an ''_update'' handler as complementary to ''_show'' functions, not to ''validate_doc_update'' functions.
