## page was renamed from ServingAppsFromCouchDb
You can write applications that are written entirely in HTML/CSS and JavaScript and that is stored within CouchDB document attachments. Here's a short script that makes it easy to wrap up a bunch of files and put them into a database.

This is a quick'n'dirty hack. All you need to do is fill the {{{$files}}} array with entries of {{{$file}}} arrays that contain the filename and content-type of that file.

Run with: 
$ curl -X PUT http://server:5984/database/document -d "\`php upload.php\`"

{{{
<?php
$file["name"] = "main.html";
$file["contentType"] = "text/html";
$files[] = $file;

$file["name"] = "thread.html";
$file["contentType"] = "text/html";
$files[] = $file;

$file["name"] = "styles.css";
$file["contentType"] = "text/css";
$files[] = $file;

$file["name"] = "DetectWebkit.js";
$file["contentType"] = "application/javascript";
$files[] = $file;

foreach($files AS $file) {
	$file["data"] = base64_encode(file_get_contents($file["name"]));
	
	$attachments[] = <<<EOF
		"$file[name]": {
			"content_type":"$file[contentType]",
			"data":"$file[data]"
		}
EOF;
}

$attachments = implode(",\n\n", $attachments);

$document = <<<EOF
{
	"_attachments": {
		$attachments

	}
}

EOF;
echo $document;
?>
}}}
