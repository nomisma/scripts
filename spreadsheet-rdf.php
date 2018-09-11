<?php 

/*****
 * Author: Ethan Gruber
 * Date: September 2018 
 * Function: Process the Google spreadsheet of Nomisma spreadsheet uploads into the simple RDF model for spreadsheet metadata
 ****/

$data = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vSzEJwjXIPApTOTCCjGTU9F2_r2QL7qZB-2iv3WIW8_8jDGsyqKNskQzLQ5bfjsTf7J1xoKcneEXngE/pub?output=csv');

//use XML writer to generate RDF
$writer = new XMLWriter();
$writer->openURI("spreadsheets.rdf");
//$writer->openURI('php://output');
$writer->startDocument('1.0','UTF-8');
$writer->setIndent(true);
//now we need to define our Indent string,which is basically how many blank spaces we want to have for the indent
$writer->setIndentString("    ");

$writer->startElement('rdf:RDF');
$writer->writeAttribute('xmlns:xsd', 'http://www.w3.org/2001/XMLSchema#');
$writer->writeAttribute('xmlns:dcterms', "http://purl.org/dc/terms/");
$writer->writeAttribute('xmlns:foaf', "http://xmlns.com/foaf/0.1/");
$writer->writeAttribute('xmlns:rdf', "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
$writer->writeAttribute('xmlns:prov', 'http://www.w3.org/ns/prov#');

foreach ($data as $row){
	$writer->startElement('prov:Entity');
		$writer->writeAttribute('rdf:about', "https://docs.google.com/spreadsheets/d/{$row['spreadsheet_key']}/pubhtml");
		$writer->startElement('dcterms:description');
			$writer->writeAttribute('xml:lang', 'en');
			$writer->text($row['description']);
		$writer->endElement();
		$writer->startElement('dcterms:creator');
			$writer->writeAttribute('rdf:resource', $row['creator']);			
		$writer->endElement();
		if (strlen($row['contributor1']) > 0){
			$writer->startElement('dcterms:contributor');
				$writer->writeAttribute('rdf:resource', $row['contributor1']);
			$writer->endElement();
		}
		if (strlen($row['contributor2']) > 0){
			$writer->startElement('dcterms:contributor');
				$writer->writeAttribute('rdf:resource', $row['contributor2']);
			$writer->endElement();
		}
		if (strlen($row['contributor3']) > 0){
			$writer->startElement('dcterms:contributor');
				$writer->writeAttribute('rdf:resource', $row['contributor3']);
			$writer->endElement();
		}
	$writer->endElement();
}

//end RDF file
$writer->endElement();
$writer->flush();

/***** FUNCTIONS *****/
function generate_json($doc){
	$keys = array();
	$geoData = array();
	
	$data = csvToArray($doc, ',');
	
	// Set number of elements (minus 1 because we shift off the first row)
	$count = count($data) - 1;
	
	//Use first row for names
	$labels = array_shift($data);
	
	foreach ($labels as $label) {
		$keys[] = $label;
	}
	
	// Bring it all together
	for ($j = 0; $j < $count; $j++) {
		$d = array_combine($keys, $data[$j]);
		$geoData[$j] = $d;
	}
	return $geoData;
}

// Function to convert CSV into associative array
function csvToArray($file, $delimiter) {
	if (($handle = fopen($file, 'r')) !== FALSE) {
		$i = 0;
		while (($lineArray = fgetcsv($handle, 4000, $delimiter, '"')) !== FALSE) {
			for ($j = 0; $j < count($lineArray); $j++) {
				$arr[$i][$j] = $lineArray[$j];
			}
			$i++;
		}
		fclose($handle);
	}
	return $arr;
}

?>