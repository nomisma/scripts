<?php 

/*****
 * Author: Ethan Gruber
 * Date: September 2018 
 * Function: Process the Google spreadsheet of Nomisma editors into the RDF model
 ****/

$data = generate_json('https://docs.google.com/spreadsheets/d/e/2PACX-1vSNgEib08U9T8e9NTMs_lG24c9vVEZoUk3gejCme6CWJ5MZQRWwv66cfOOHxADZtvyvgp381eb8wzR6/pub?output=csv');


foreach ($data as $row){
	$id = $row['id'];
	
	//use XML writer to generate RDF
	$writer = new XMLWriter();
	$writer->openURI("editor/{$id}.rdf");
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
	$writer->writeAttribute('xmlns:skos', 'http://www.w3.org/2004/02/skos/core#');
	
		$writer->startElement('foaf:Person');
			$writer->writeAttribute('rdf:about', "http://nomisma.org/editor/{$id}");
			$writer->startElement('rdf:type');
				$writer->writeAttribute('rdf:resource', 'http://www.w3.org/ns/prov#Agent');
			$writer->endElement();
			$writer->startElement('rdf:type');
				$writer->writeAttribute('rdf:resource', 'http://www.w3.org/2004/02/skos/core#Concept');
			$writer->endElement();
			$writer->writeElement('skos:prefLabel', $row['name']);
			
			//matching URIs
			if (strlen($row['orcid']) > 0){
				$writer->startElement('skos:exactMatch');
					$writer->writeAttribute('rdf:resource', $row['orcid']);
				$writer->endElement();
			}
			if (strlen($row['viaf']) > 0){
				$writer->startElement('skos:exactMatch');
					$writer->writeAttribute('rdf:resource', $row['viaf']);
				$writer->endElement();
			}	
			if (strlen($row['otherURI1']) > 0){
				$writer->startElement('skos:exactMatch');
					$writer->writeAttribute('rdf:resource', $row['otherURI1']);
				$writer->endElement();
			}	
			if (strlen($row['otherURI2']) > 0){
				$writer->startElement('skos:exactMatch');
					$writer->writeAttribute('rdf:resource', $row['otherURI2']);
				$writer->endElement();
			}
			
			$writer->startElement('skos:inScheme');
				$writer->writeAttribute('rdf:resource', 'http://nomisma.org/editor/');
			$writer->endElement();
		$writer->endElement();
	
	//end RDF file
	$writer->endElement();
	$writer->flush();
}

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