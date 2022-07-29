<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xsl xs" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:bio="http://purl.org/vocab/bio/0.1/"
    xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
    xmlns:nm="http://nomisma.org/id/"
    xmlns:nmo="http://nomisma.org/ontology#"
    xmlns:org="http://www.w3.org/ns/org#"
    xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/"
    xmlns:prov="http://www.w3.org/ns/prov#"
    xmlns:rdac="http://www.rdaregistry.info/Elements/c/"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:wordnet="http://ontologi.es/WordNet/class/"
    xmlns:crmdig="http://www.ics.forth.gr/isl/CRMdig/" version="2.0">

    <xsl:strip-space elements="*"/>
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <!-- Atom feed of spreadsheet -->
    <xsl:variable name="concordance" as="document-node()">
        <xsl:copy-of select="document('ndp-nomisma.xml')"/>
    </xsl:variable>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="rdf:RDF">
        <rdf:RDF xmlns:bio="http://purl.org/vocab/bio/0.1/"
            xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/"
            xmlns:dcterms="http://purl.org/dc/terms/"
            xmlns:foaf="http://xmlns.com/foaf/0.1/"
            xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"
            xmlns:nm="http://nomisma.org/id/"
            xmlns:nmo="http://nomisma.org/ontology#"
            xmlns:org="http://www.w3.org/ns/org#"
            xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/"
            xmlns:prov="http://www.w3.org/ns/prov#"
            xmlns:rdac="http://www.rdaregistry.info/Elements/c/"
            xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
            xmlns:skos="http://www.w3.org/2004/02/skos/core#"
            xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#"
            xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
            xmlns:wordnet="http://ontologi.es/WordNet/class/"
            xmlns:crmdig="http://www.ics.forth.gr/isl/CRMdig/">
            <xsl:apply-templates/>
        </rdf:RDF>
    </xsl:template>
    
    <!-- first pass -->
    <!--<xsl:template match="rdf:RDF/*[1]">
        <xsl:variable name="class" select="name()"/>        
        <xsl:variable name="id" select="tokenize(@rdf:about, '/')[last()]"/>
        
        <xsl:element name="{name()}">
            <xsl:attribute name="rdf:about" select="@rdf:about"/>
            
            <xsl:apply-templates/>
            
            <xsl:if test="$concordance//row[id = $id]">
                <xsl:if test="not($concordance//row[id = $id]/uri = skos:exactMatch/@rdf:resource)">                    
                    <skos:exactMatch rdf:resource="{$concordance//row[id = $id]/uri}"/>
                </xsl:if>
            </xsl:if>
        </xsl:element>
    </xsl:template>-->
    
    <!-- second pass: replace skos:exactMatch with skos:closeMatch for mints -->
    <xsl:template match="nmo:Mint">
        <xsl:element name="{name()}">
            <xsl:attribute name="rdf:about" select="@rdf:about"/>
            
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="skos:exactMatch[contains(@rdf:resource, 'ikmk.smb.museum')]">
        <skos:closeMatch rdf:resource="{@rdf:resource}"/>
    </xsl:template>
    
</xsl:stylesheet>
