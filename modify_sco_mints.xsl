<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:gsx="http://schemas.google.com/spreadsheets/2006/extended"
    xmlns:atom="http://www.w3.org/2005/Atom" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:org="http://www.w3.org/ns/org#"
    xmlns:nmo="http://nomisma.org/ontology#" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#" xmlns:nm="http://nomisma.org/id/" xmlns:prov="http://www.w3.org/ns/prov#"
    xmlns:bio="http://purl.org/vocab/bio/0.1/" xmlns:rdac="http://www.rdaregistry.info/Elements/c/" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:crm="http://www.cidoc-crm.org/cidoc-crm/" exclude-result-prefixes="#all" version="2.0">

    <xsl:strip-space elements="*"/>
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:variable name="hasMatch" select="boolean(/rdf:RDF/*[1]/prov:alternateOf)" as="xs:boolean"/>

    <xsl:template match="@* | node()">
        <xsl:choose>
            <!-- normalize space of all text elements -->
            <xsl:when test="self::text()">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="nmo:Mint">
        <nmo:Mint rdf:about="{@rdf:about}">            
            <xsl:apply-templates select="*[not(name() = 'prov:alternateOf')]"/>
            
            <xsl:if test="$hasMatch = true()">
                <skos:related>
                    <rdf:Description>
                        <rdf:value rdf:resource="{prov:alternateOf/@rdf:resource}"/>
                        <un:hasUncertainty rdf:resource="http://nomisma.org/id/uncertain_value"/>
                    </rdf:Description>
                </skos:related>
            </xsl:if>
        </nmo:Mint>
    </xsl:template>
    
    <xsl:template match="geo:SpatialThing|geo:location">
        <xsl:if test="$hasMatch = false()">
            <xsl:apply-templates select="self::node()"/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
