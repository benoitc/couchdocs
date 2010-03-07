= Using CouchDB For Storing Google Geocoded JSON Data =
Google provides a free service that takes any string as an input and returns a bunch of JSON encoded data if that string matches a physical location.  Check it out here: http://code.google.com/apis/maps/documentation/services.html#Geocoding

Unfortunately, Google's geocoding service is limited to 15k requests per day per IP.  Sounds like a lot, but for certain applications this limit can be reached very quickly.

The following small library can help you get around these limitations by storing a local repository of data in CouchDB.  This is a nice fit because CouchDB is JSON-native and the data returned from google is JSON-native.

The following is a rough and tumble library I put together called GeoCouch that you can use to easily handle geocoded data in CouchDB.  This lib has a narrow scope right now - the requirements are:

 * PHP 5+
 * CouchDB
 * A Google API Key (http://code.google.com/apis/maps/signup.html)

Download the file here: http://geocouch.googlecode.com/files/geocouch.php.  You can also find the full source at the bottom of the page.

== Usage ==
{{{
<?php
	require ('geocouch.php');
	
	/*
	 * Don't forget to edit the $GeoCouch->conf parameters!
	 */
	$GeoCouch = new GeoCouch();
	
	/*
	 * The all-in-one method.
	 * This geocodes the string and writes it to CouchDB
	 * The second parameter is any other fields other
	 * than the Google data that you want to save along
	 * with this document.
	 * 
	 * NOTE: if this address already exists in CouchDB
	 * a new revision is created.
	 * 
	 * Returns the CouchDB response, i.e.:
	 * {"ok" : true, "rev":"3825793742", "id" : "dallas-tx" }
	 */
	$GeoCouch->save('Dallas, TX', array('custom_field' => 'value')); 
	
	/*
	 * Simply geo coding.  
	 * Does not write to CouchDB.
	 * Returns an Google Geocoded Object.
	 */
	$geoObj = $GeoCouch->geoCode('Dallas, TX');
	
	/*
	 * Write some Geo JSON to CouchDB.
	 * First parameter is a unique name for the data
	 * Second parameter is the JSON - in 
	 * this case the json_encoded $geoObj from above.
	 */
	$GeoCouch->put('Dallas, TX', json_encode($geoObj));
	
	/*
	 * Get some existing geo data
	 */
	$geoObj = $GeoCouch->get('Dallas, TX');
?>
}}}

== GeoCouch Class ==
{{{
<?php

	class GeoCouch
	{
		var $conf = array(
			'host' => 'localhost',
			'port' => '5984',
			'db' => 'sf_geo',
			'geocoder' => array(
					'url' => 'http://maps.google.com/maps/geo?key=',
					'key' => 'Your Google API Key',
				),
		);
		
		var $address;
		var $geoJSONResponse;
		var $geoObj;
		
		function GeoCouch() {
			
		}
		
		function geoCode($address = null)
		{
			$this->address = $address;
			$url = $this->conf['geocoder']['url'].$this->conf['geocoder']['key'];
			$url .= '&q='.urlencode($address);
			
			$this->geoJSONResponse = $this->_geoCodeRequest($url);
			$this->geoObj = json_decode($this->geoJSONResponse);
			
			if(empty($this->geoObj->Status->code) || $this->geoObj->Status->code != 200) {
				return false;
			} else {
				return $this->geoJSONResponse;
			}	
		}
		
		function _geoCodeRequest($url) 
		{
			$ch = curl_init();
			curl_setopt ($ch, CURLOPT_URL, $url);
			curl_setopt ($ch, CURLOPT_HEADER, 0);
			ob_start();
			curl_exec ($ch);
			curl_close ($ch);
			$string = ob_get_contents();
			ob_end_clean();
			return $string;
		}
		
		function locationName($str) {
			return trim(preg_replace('/[^a-z0-9]+/i', '-', $str), '_');
		}
		
		function save($address, $extra = array())
		{
			$existing = $this->get($address);
			
			if($this->geoCode($address)) 
			{
				if(!empty($existing->_rev)) {
					$this->geoObj->_rev = $existing->_rev;
				}
				
				foreach($extra as $field => $value) {
					$this->geoObj->$field = $value;
				}
				
				return $this->put($address, json_encode($this->geoObj));
			}
			else {
				return false;
			}
		}
		
		function get($name = null)
		{
			$s = $this->openSock();
			
			$url = '/'.$this->conf['db'].'/'.$this->locationName($name);
			$request = 'GET '.$url.' HTTP/1.0'. "\r\n";
			$request .= 'Host: localhost'. "\r\n\r\n";
			fwrite($s, $request);
			
			return $this->parseCouchResponse($s);		
		}
		
		function put($name = null, $json = null)
		{
			$s = $this->openSock();
			
			$url = '/'.$this->conf['db'].'/'.$this->locationName($name);
			$request = 'PUT '.$url.' HTTP/1.0'. "\r\n";
			$request .= 'Host: localhost'. "\r\n";
			$request .= 'Content-Length: '.strlen($json)."\r\n\r\n";
			$request .= $json."\r\n";
			fwrite($s, $request);
			
			return $this->parseCouchResponse($s);	
		}
		
		function openSock() 
		{
			$s = fsockopen($this->conf['host'], $this->conf['port'], $errno, $errstr);
			if(!$s) {
				return $errno.':'.$errstr;
			} else {
				return $s;
			}
		}
		
		function parseCouchResponse($s) 
		{
			$response = '';
			while(!feof($s)) {
				$response .= fgets($s);
			}
			fclose($s);
			
			list($headers, $body) = explode("\r\n\r\n", $response);
			return json_decode($body);
		}
	}
?>
}}}
