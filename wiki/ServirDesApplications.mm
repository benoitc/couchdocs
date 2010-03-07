#language fr
Vous pouvez écrire des applications entièrement écrites en HTML/CSS et Javascript stockées dans des attachements de documents CouchDB. Voici un petit script qui facilite l'ajout de plusieurs fichiers dans la base de donnée.

C'est un hack rapide. Vous n'avez qu'à renseigner le tableau {{{$files}}} avec le nom et le content-type de chaque fichier.

Exécutez la commande : 
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
			"content-type":"$file[contentType]",
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
