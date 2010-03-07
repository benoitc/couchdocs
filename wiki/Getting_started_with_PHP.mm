Getting started with PHP and the CouchDB API.

== CouchDB Libraries ==
 * PHPillow: http://arbitracker.org/phpillow.html
 * PHP Object_Freezer: https://github.com/sebastianbergmann/php-object-freezer/tree
 * PHP On Couch: http://github.com/dready92/PHP-on-Couch/tree/master
 * PHP CouchDB Extension: http://www.topdog.za.net/php_couchdb_extension

== Setup ==
To get this example code running you need to install CouchDB on your system and have it running on port 5984. If you use a different machine or port, change the first two lines of code to your specific values.

== What Does it Do? ==
This example first creates a !CouchSimple object that we're going to use for making connections to CouchDB on our machine, port 5984. Notice that this response is already encoded in JSON. CouchDB returns nothing but JSON wrapped in HTTP responses.

It then tries to make a simple GET request to the root of the data store.

We then look for a list of all databases in CouchDB and we find the one that ships with it, the ''test_suite_db''. CouchDB has all sorts of special URLs for specific tasks. The ''/_all_dbs'' URL gives us a list of all the databases.

Next, we create a new database ''test'' using the HTTP method ''PUT''. Creating databases is that easy.

Then we have a look all the documents in a database. To do so we send a GET request to the special URL ''/test/_all_docs''. We get an empty list.

Time for action. We are now storing actual data, wrapped in JSON, in CouchDB. To do so, we make POST request to the test database and include a JSON object that has the special attribute ''"_id": "123"''. This is unique identifier each document in CouchDB has. If you don't specify one here, CouchDB does it for you. In the response you see, that CouchDB then tells you what ''_id'' was created. There is also the ''_rev'' attribute which can be used to specify a document's revision, but this is beyond the scope of this introduction.

Assuming all goes well, we have another look at all the documents in the test database and 'lo and behold, our document is in.

We then proceed to getting it back out again with a simple GET request to ''/test/123''. All documents you put into CouchDB can be retrieved like this. With their database and ''_id'' as the URL.

At last, we delete our database. The HTTP DELETE method does the job. You can also DELETE single documents in the same way.

{{{
<?php

 $options['host'] = "localhost"; 
 $options['port'] = 5984;

 $couch = new CouchSimple($options); // See if we can make a connection
 $resp = $couch->send("GET", "/"); 
 var_dump($resp); // response: string(46) "{"couchdb": "Welcome", "version": "0.7.0a553"}"

 // Get a list of all databases in CouchDb 
 $resp = $couch->send("GET", "/_all_dbs"); 
 var_dump($resp); // string(17) "["test_suite_db"]" 

 // Create a new database "test"
 $resp = $couch->send("PUT", "/test"); 
 var_dump($resp); // string(12) "{"ok":true}" 
 
 // Get all documents in that database
 $resp = $couch->send("GET", "/test/_all_docs"); 
 var_dump($resp); // string(27) "{"total_rows":0,"rows":[]}" 

 // Create a new document in the database test with the id 123 and some data
 $resp = $couch->send("PUT", "/test/123", '{"_id":"123","data":"Foo"}'); 
 var_dump($resp); // string(42) "{"ok":true,"id":"123","rev":"2039697587"}"   

 // Get all documents in test again, seing doc 123 there
 $resp = $couch->send("GET", "/test/_all_docs"); 
 var_dump($resp); // string(91) "{"total_rows":1,"offset":0,"rows":[{"id":"123","key":"123","value":{"rev":"2039697587"}}]}" 

 // Get back document with the id 123
 $resp = $couch->send("GET", "/test/123"); 
 var_dump($resp); // string(47) "{"_id":"123","_rev":"2039697587","data":"Foo"}" 

 // Delete our "test" database
 $resp = $couch->send("DELETE", "/test/"); 
 var_dump($resp); // string(12) "{"ok":true}"

 class CouchSimple {
    function CouchSimple($options) {
       foreach($options AS $key => $value) {
          $this->$key = $value;
       }
    } 
   
   function send($method, $url, $post_data = NULL) {
      $s = fsockopen($this->host, $this->port, $errno, $errstr); 
      if(!$s) {
         echo "$errno: $errstr\n"; 
         return false;
      } 

      $request = "$method $url HTTP/1.0\r\nHost: localhost\r\n"; 

      if($post_data) {
         $request .= "Content-Length: ".strlen($post_data)."\r\n\r\n"; 
         $request .= "$post_data\r\n";
      } 
      else {
         $request .= "\r\n";
      }

      fwrite($s, $request); 
      $response = ""; 

      while(!feof($s)) {
         $response .= fgets($s);
      }

      list($this->headers, $this->body) = explode("\r\n\r\n", $response); 
      return $this->body;
   }
}
?>
}}}

== A CouchDB Response Class ==
We'll use the following class as a structure for storing and handling responses to our HTTP requests to the DB.  Instances of this will store response components, namely the headers and body, in appropriately named properties.  Eventually we might want to do more error checking based on the headers, etc.  For this example, we'll be most interested in ''CouchDBResponse::getBody()''.  It returns either the text of the response or the data structure derived from decoding the JSON response based on the method's only parameter, ''$decode_json''.  Inside the ''getBody'' method, we call a static method ''decode_json'' that lives in our as-yet-unwritten ''CouchDB'' class.  We'll get to that soon enough, but all it really does in this example is wrap a call to the PHP json extension's ''json_decode'' function.

{{{
class CouchDBResponse {

    private $raw_response = '';
    private $headers = '';
    private $body = '';

    function __construct($response = '') {
        $this->raw_response = $response;
        list($this->headers, $this->body) = explode("\r\n\r\n", $response);
    }

    function getRawResponse() {
        return $this->raw_response;
    }

    function getHeaders() {
        return $this->headers;
    }

    function getBody($decode_json = false) {
        return $decode_json ? CouchDB::decode_json($this->body) : $this->body;
    }
}
}}}
== A CouchDB Request Class ==
Now that we have a response class, we need something to organize our requests.  This class will 1) build request headers and assemble the request, 2) send the request and 3) give us the interesting part of the result.  Following [[GettingStartedWithPhp|Noah Slater's lead]], we make our requests using ''fsockopen'', which allows us to treat our connection to the CouchDB server as a file pointer.  When we execute the request, we pass the response on to a new ''CouchDBRequest'' object.

{{{
class CouchDBRequest {

    static $VALID_HTTP_METHODS = array('DELETE', 'GET', 'POST', 'PUT');

    private $method = 'GET';
    private $url = '';
    private $data = NULL;
    private $sock = NULL;
    private $username;
    private $password;

    function __construct($host, $port = 5984, $url, $method = 'GET', $data = NULL, $username = null, $password = null) {
        $method = strtoupper($method);
        $this->host = $host;
        $this->port = $port;
        $this->url = $url;
        $this->method = $method;
        $this->data = $data;
        $this->username = $username;
        $this->password = $password;

        if(!in_array($this->method, self::$VALID_HTTP_METHODS)) {
            throw new CouchDBException('Invalid HTTP method: '.$this->method);
        }
    }

    function getRequest() {
        $req = "{$this->method} {$this->url} HTTP/1.0\r\nHost: {$this->host}\r\n";

        if($this->username || $this->password)
            $req .= 'Authorization: Basic '.base64_encode($this->username.':'.$this->password)."\r\n";

        if($this->data) {
            $req .= 'Content-Length: '.strlen($this->data)."\r\n";
            $req .= 'Content-Type: application/json'."\r\n\r\n";
            $req .= $this->data."\r\n";
        } else {
            $req .= "\r\n";
        }

        return $req;
    }

    private function connect() {
        $this->sock = @fsockopen($this->host, $this->port, $err_num, $err_string);
        if(!$this->sock) {
            throw new CouchDBException('Could not open connection to '.$this->host.':'.$this->port.' ('.$err_string.')');
        }
    }

    private function disconnect() {
        fclose($this->sock);
        $this->sock = NULL;
    }

    private function execute() {
        fwrite($this->sock, $this->getRequest());
        $response = '';
        while(!feof($this->sock)) {
            $response .= fgets($this->sock);
        }
        $this->response = new CouchDBResponse($response);
        return $this->response;
    }

    function send() {
        $this->connect();
        $this->execute();
        $this->disconnect();
        return $this->response;
    }

    function getResponse() {
        return $this->response;
    }
}
}}}
== The CouchDB Class ==
The CouchDB class provides a ''send'' method for sending requests to the CouchDB server.  It uses the ''CouchDBRequest'' class above and returns a ''CouchDBResponse'' object.  This class also provides a method for fetching all documents in a database, using the ''_all_docs'' built-in view.  I've also included a ''get_item'' method for fetching a document with its id.  Clearly, further abstraction for different types of queries, etc. should follow, but this is enough for us to get at the data in our database.

Supports HTTP Basic Authentication for the whole session - just provide either the username, password, or both when creating this class. The pair is then sent to the CouchDBRequest to be included in the header.

{{{
class CouchDB {

    private $username;
    private $password;

    function __construct($db, $host = 'localhost', $port = 5984, $username = null, $password = null) {
        $this->db = $db;
        $this->host = $host;
        $this->port = $port;
        $this->username = $username;
        $this->password = $password;
    }

    static function decode_json($str) {
        return json_decode($str);
    }

    static function encode_json($str) {
        return json_encode($str);
    }

    function send($url, $method = 'get', $data = NULL) {
        $url = '/'.$this->db.(substr($url, 0, 1) == '/' ? $url : '/'.$url);
        $request = new CouchDBRequest($this->host, $this->port, $url, $method, $data, $this->username, $this->password);
        return $request->send();
    }

    function get_all_docs() {
        return $this->send('/_all_docs');
    }

    function get_item($id) {
        return $this->send('/'.$id);
    }
}
}}}
== Using Our CouchDB Class ==
The following is some code just playing around with our pastebin data, which we assume contains the fields title, body, created, and status.

{{{
// we get a new CouchDB object that will use the 'pastebin' db
$couchdb = new CouchDB('pastebin');
try {
    $result = $couchdb->get_all_docs();
} catch(CouchDBException $e) {
    die($e->errorMessage()."\n");
}
// here we get the decoded json from the response
$all_docs = $result->getBody(true);

// then we can iterate through the returned rows and fetch each item using its id.
foreach($all_docs->rows as $r => $row) {
    print_r($couchdb->get_item($row->id));
}

// if we want to find only pastebin items that are currently published, we need to do a little more.
// below, we create a view using a javascript function passed in the post data.
$map = <<<MAP
function(doc) {
    if(doc.status == 'published') {
        emit(doc.title, {docTitle: doc.title, docBody: doc.body});
    }
}
MAP;
$view = '{"map":"'.$map.'"}';

// we set the method to POST and send the request to couch db's /_temp_view. the text of the view is passed as post data.
// this javascript function will return documents whose 'status' field contains 'published'.
// note that we set the content type to 'text/javascript' for posts in our couchdb class.
$view_result = $couchdb->send('/_temp_view', 'post', $view);
print $view_result->getBody();
}}}
