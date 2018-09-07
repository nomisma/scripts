<?php 

/*****
 * Author: Ethan Gruber
 * Date: August 2018
 * Function: Iterate through RDF files for Nomisma.org in order to get a list of modifications with `git log` 
 *      The first date will be a prov:Create and most recent prov:Modify. Original *.xml files are ignored
 *      The modification dates will be outputted to an XML file to be processed with XSLT later
 *****/

//commit for XHTML fragments stored in .txt files: a72d91ea70c7ea9e5c77b4cbaafeaecbd6e7afa5

$path = '/usr/local/projects/nomisma-data/id';
$files = scandir($path);

$writer = new XMLWriter();
$writer->openURI("rdf-modifications.xml");
//$writer->openURI('php://output');
$writer->startDocument('1.0','UTF-8');
$writer->setIndent(true);
//now we need to define our Indent string,which is basically how many blank spaces we want to have for the indent
$writer->setIndentString("    ");

$writer->startElement('nodes');

foreach ($files as $file){
    
    if (strpos($file, '.rdf') !== FALSE){
        echo "\nProcessing {$file}\n";
        
        $writer->startElement('file');
            $writer->writeAttribute('id', str_replace('.rdf', '', $file));
        
            chdir($path);
            exec("git log --date=format:'%Y-%m-%dT%H:%M:%S%zZ' -- " . escapeshellarg($file), $output);
            
            foreach($output as $k=>$line){
            	//find commit at the beginning of the line, calculate date and description based on the first line of a commit in the log
            	if (preg_match('/^commit/', $line)){            		
            		$dateTime = preg_replace('/(.*)(\d{2})(\d{2})Z/i', '$1$2:$3', str_replace('Date:   ', '', $output[$k + 2]));
            		$desc = substr($output[$k + 4], 4);
            		
            		echo "{$dateTime}: {$desc}\n";
            		$writer->startElement('date');
	            		$writer->writeAttribute('desc', $desc);
	            		$writer->text($dateTime);
            		$writer->endElement();
            	}
            }
            unset($output);
        $writer->endElement();
    }
}

//close XML file
$writer->endElement();
$writer->flush();


?>