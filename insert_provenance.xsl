<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:gsx="http://schemas.google.com/spreadsheets/2006/extended"
    xmlns:atom="http://www.w3.org/2005/Atom" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:org="http://www.w3.org/ns/org#"
    xmlns:nmo="http://nomisma.org/ontology#" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:un="http://www.owl-ontologies.com/Ontology1181490123.owl#" xmlns:nm="http://nomisma.org/id/" xmlns:prov="http://www.w3.org/ns/prov#"
    xmlns:bio="http://purl.org/vocab/bio/0.1/" xmlns:rdac="http://www.rdaregistry.info/Elements/c/" xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" exclude-result-prefixes="#all" version="2.0">

    <xsl:strip-space elements="*"/>
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:variable name="type" select="rdf:RDF/*[1]/name()"/>
    <xsl:variable name="uri" select="rdf:RDF/*[1]/@rdf:about"/>
    <xsl:variable name="id" select="tokenize($uri, '/')[last()]"/>

    <!-- see spreadsheet of Nomisma spreadsheets for list of associated Github commit dates : 
        https://docs.google.com/spreadsheets/d/e/2PACX-1vSzEJwjXIPApTOTCCjGTU9F2_r2QL7qZB-2iv3WIW8_8jDGsyqKNskQzLQ5bfjsTf7J1xoKcneEXngE/pubhtml -->

    <!-- Atom feed of spreadsheet -->
    <xsl:variable name="spreadsheets" as="document-node()">
        <xsl:copy-of select="document('https://spreadsheets.google.com/feeds/list/1ke1Vi8sy9j_D7mnAUA0jgE1po3__RUCQuD2cTW7U8ZQ/od6/public/full')"/>
    </xsl:variable>

    <!-- create a sequence of commit dates from the spreadsheet -->
    <xsl:variable name="dates" select="data($spreadsheets//gsx:commitdate)"/>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="rdf:RDF">
        <xsl:variable name="isDeprecated" select="count(*[1]/dcterms:isReplacedBy) = 1"/>



        <xsl:element name="rdf:RDF">
            <xsl:namespace name="rdf">http://www.w3.org/1999/02/22-rdf-syntax-ns#</xsl:namespace>
            <xsl:namespace name="bio">http://purl.org/vocab/bio/0.1/</xsl:namespace>
            <xsl:namespace name="crm">http://www.cidoc-crm.org/cidoc-crm/</xsl:namespace>
            <xsl:namespace name="dcterms">http://purl.org/dc/terms/</xsl:namespace>
            <xsl:namespace name="foaf">http://xmlns.com/foaf/0.1/</xsl:namespace>
            <xsl:namespace name="geo">http://www.w3.org/2003/01/geo/wgs84_pos#</xsl:namespace>
            <xsl:namespace name="nm">http://nomisma.org/id/</xsl:namespace>
            <xsl:namespace name="nmo">http://nomisma.org/ontology#</xsl:namespace>
            <xsl:namespace name="org">http://www.w3.org/ns/org#</xsl:namespace>
            <xsl:namespace name="osgeo">http://data.ordnancesurvey.co.uk/ontology/geometry/</xsl:namespace>
            <xsl:namespace name="prov">http://www.w3.org/ns/prov#</xsl:namespace>
            <xsl:namespace name="rdac">http://www.rdaregistry.info/Elements/c/</xsl:namespace>
            <xsl:namespace name="rdfs">http://www.w3.org/2000/01/rdf-schema#</xsl:namespace>
            <xsl:namespace name="skos">http://www.w3.org/2004/02/skos/core#</xsl:namespace>
            <xsl:namespace name="un">http://www.owl-ontologies.com/Ontology1181490123.owl#</xsl:namespace>
            <xsl:namespace name="xsd">http://www.w3.org/2001/XMLSchema#</xsl:namespace>
            <xsl:apply-templates/>

            <!-- insert provenance events -->
            <dcterms:ProvenanceStatement rdf:about="{concat($uri, '#provenance')}">
                <foaf:topic rdf:resource="{$uri}"/>

                <xsl:variable name="history" as="element()*">
                    <history>
                        <xsl:for-each select="document('xhtml-modifications.xml')//file[@id = $id]/date">
                            <xsl:sort order="ascending"/>
                            <xsl:copy-of select="self::node()"/>
                        </xsl:for-each>
                        <xsl:for-each select="document('rdf-modifications.xml')//file[@id = $id]/date">
                            <xsl:sort order="ascending"/>

                            <!-- ignore specific changes -->
                            <xsl:choose>
                                <xsl:when test="contains(., '2015-02-12')">
                                    <!-- replaced xsd:float with xsd:decimal -->
                                </xsl:when>
                                <xsl:when test="contains(., '2015-03-06')">
                                    <!-- added skos:Concept type into a few foaf:Person records that slipped through the cracks-->
                                </xsl:when>
                                <xsl:when test="contains(., '2015-07-16')">
                                    <!-- replaced relatedMatch and exactMatch with closeMatch in mints -->
                                </xsl:when>
                                <xsl:when test="@desc = 'added prov namespace into RDF files'">
                                    <!-- added prov namespace into RDF files -->
                                    <!-- note: Islamic mints also added on 2015-07-28 -->
                                </xsl:when>
                                <xsl:when test="contains(., '2016-04-13')">
                                    <!-- migrated CIDOC-CRM to canonical URI from Erlangen -->
                                </xsl:when>
                                <xsl:when test="contains(., '2016-06-13')">
                                    <!-- replaced http with https in wikidata URIs -->
                                </xsl:when>
                                <xsl:when test="contains(., '2018-08-28')">
                                    <!-- updated permissions -->
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:copy-of select="self::node()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </history>
                </xsl:variable>

                <!--<xsl:copy-of select="$history"/>-->

                <xsl:variable name="creation" select="substring-before($history/date[1], 'T')"/>

                <xsl:choose>
                    <xsl:when test="$creation = '2012-10-28'">
                        <prov:wasGeneratedBy>
                            <prov:Activity>
                                <rdf:type rdf:resource="http://www.w3.org/ns/prov#Create"/>
                                <prov:atTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                    <xsl:value-of select="$history/date[1]"/>
                                </prov:atTime>
                                <prov:wasAssociatedWith rdf:resource="http://nomisma.org/id/ameadows"/>
                                <prov:wasAssociatedWith rdf:resource="http://nomisma.org/id/sfsheath"/>
                                <dcterms:description xml:lang="en">
                                    <xsl:text>This is among the original Nomisma XHTML+RDFa fragments, most likely created between 2010-2012 by Sebastian Heath and/or Andy Meadows.</xsl:text>
                                </dcterms:description>
                            </prov:Activity>
                        </prov:wasGeneratedBy>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="index-of($dates, $creation) &gt; 0">
                                <xsl:apply-templates select="$history/date[index-of($dates, $creation) &gt; 0]" mode="spreadsheet">
                                    <xsl:with-param name="mode">Create</xsl:with-param>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                
                                <!-- extend the mode=modify template -->
                                
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>

                <!--<prov:wasGeneratedBy>
                    <prov:Activity>
                        <rdf:type rdf:resource="http://www.w3.org/ns/prov#Create"/>
                        <prov:atTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                            <xsl:value-of select="$history/date[1]"/>
                        </prov:atTime>

                        <xsl:choose>
                            <xsl:when test="$creation = '2012-10-28'">
                                <prov:wasAssociatedWith rdf:resource="http://nomisma.org/id/ameadows"/>
                                <prov:wasAssociatedWith rdf:resource="http://nomisma.org/id/sfsheath"/>
                                <dcterms:description xml:lang="en">
                                    <xsl:text>This is among the original Nomisma XHTML+RDFa fragments, most likely created between 2010-2012 by Sebastian Heath and/or Andy Meadows.</xsl:text>
                                </dcterms:description>
                            </xsl:when>
                            <xsl:otherwise>
                                <!-\- evaluate spreadsheet -\->
                                <xsl:choose>
                                    <xsl:when test="index-of($dates, $creation) &gt; 0">
                                        <xsl:variable name="creator" select="$spreadsheets//atom:entry[gsx:commitdate = $creation]/gsx:creator"/>
                                        
                                        <xsl:call-template name="uploader">
                                            <xsl:with-param name="creator" select="$creator"/>
                                        </xsl:call-template>
                                        
                                        <!-\- insert spreadsheet URL -\->
                                        <xsl:call-template name="generate-spreadsheet">
                                            <xsl:with-param name="date" select="$creation"/>
                                        </xsl:call-template>
                                        
                                        <dcterms:type>spreadsheet</dcterms:type>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        
                                        <!-\- to-do, figure out German IDs for Karsten -\->
                                        <dcterms:type>manual</dcterms:type>
                                    </xsl:otherwise>
                                </xsl:choose>                            
                            </xsl:otherwise>
                        </xsl:choose>
                    </prov:Activity>
                </prov:wasGeneratedBy>-->

                <!-- process deprecations before inserting modifications -->

                <xsl:choose>
                    <xsl:when test="$isDeprecated = true()">
                        <xsl:choose>
                            <xsl:when test="$history/date[@desc='committing igch deprecation']">
                                <!-- IGCH deprecation to coinhoards.org -->
                                <prov:wasInvalidatedBy>
                                    <prov:Activity>
                                        <rdf:type rdf:resource="http://www.w3.org/ns/prov#Replace"/>
                                        <prov:atTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                            <xsl:value-of select="$history/date[@desc='committing igch deprecation']"/>
                                        </prov:atTime>
                                        <prov:wasAssociatedWith rdf:resource="http://nomisma.org/id/egruber"/>
                                        <dcterms:type>manual</dcterms:type>
                                    </prov:Activity>
                                </prov:wasInvalidatedBy>
                            </xsl:when>
                            <xsl:when test="$history/date[contains(., '2015-02-03')] and (contains($id, 'rrc-') or contains($id, 'ric.2'))">
                                <!-- RRC deprecation to CRRO, RIC to OCRE -->

                                <prov:wasInvalidatedBy>
                                    <prov:Activity>
                                        <rdf:type rdf:resource="http://www.w3.org/ns/prov#Replace"/>
                                        <prov:atTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                            <xsl:value-of select="$history/date[contains(., '2015-02-03')][last()]"/>
                                        </prov:atTime>
                                        <prov:wasAssociatedWith rdf:resource="http://nomisma.org/id/egruber"/>
                                        <dcterms:type>manual</dcterms:type>
                                    </prov:Activity>
                                </prov:wasInvalidatedBy>
                            </xsl:when>
                            <xsl:otherwise>
                                <prov:wasInvalidatedBy>
                                    <prov:Activity>
                                        <rdf:type rdf:resource="http://www.w3.org/ns/prov#Replace"/>
                                        <prov:atTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                            <xsl:value-of select="$history/date[last()]"/>
                                        </prov:atTime>
                                        <prov:wasAssociatedWith rdf:resource="http://nomisma.org/id/egruber"/>
                                        <dcterms:type>manual</dcterms:type>
                                    </prov:Activity>
                                </prov:wasInvalidatedBy>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="count($history/date) &gt; 1">
                            <!-- insert modification events for any spreadsheet -->
                            <xsl:apply-templates select="$history/date[index-of($dates, substring-before(., 'T')) &gt; 0]" mode="spreadsheet">
                                <xsl:with-param name="mode">Modify</xsl:with-param>
                            </xsl:apply-templates>

                            <!-- call template on the final commit, but only evaluate whether it should exist within the template -->
                            <xsl:apply-templates select="$history/date[last()]" mode="modified">
                                <xsl:with-param name="mode">Modify</xsl:with-param>
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </dcterms:ProvenanceStatement>
        </xsl:element>
    </xsl:template>

    <xsl:template match="date" mode="modified">
        <xsl:variable name="date" select="substring-before(., 'T')"/>

        <xsl:if test="not(index-of($dates, $date))">
            <prov:activity>
                <prov:Activity>
                    <rdf:type rdf:resource="http://www.w3.org/ns/prov#Modify"/>
                    <prov:atTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                        <xsl:value-of select="."/>
                    </prov:atTime>
                    <!--<prov:wasAssociatedWith rdf:resource="http://nomisma.org/id/sfsheath"/>-->
                    <dcterms:type>manual</dcterms:type>
                </prov:Activity>
            </prov:activity>
        </xsl:if>
    </xsl:template>

    <xsl:template match="date" mode="spreadsheet">
        <xsl:param name="mode"/>
        
        <xsl:variable name="date" select="substring-before(., 'T')"/>
        
        <!-- ignore certain dates when the ID doesn't match a specific parameter -->
        <xsl:choose>
            <xsl:when test="$date = '2015-07-31' and not($type = 'foaf:Person')"/>
            <xsl:when test="$date = '2015-07-01' and not($type = 'foaf:Person')"/>
            <xsl:otherwise>
                
                    <!-- differentiate between new or modified activities -->
                    <xsl:choose>
                        <xsl:when test="$mode = 'Modify'">
                            <prov:activity>
                                <xsl:call-template name="activity">
                                    <xsl:with-param name="mode" select="$mode"/>
                                </xsl:call-template>
                            </prov:activity>
                        </xsl:when>
                        <xsl:otherwise>
                            <prov:wasGeneratedBy>
                                <xsl:call-template name="activity">
                                    <xsl:with-param name="mode" select="$mode"/>
                                </xsl:call-template>
                            </prov:wasGeneratedBy>
                        </xsl:otherwise>
                    </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="activity">
        <xsl:param name="mode"/>
        
        <xsl:variable name="date" select="substring-before(., 'T')"/>
        <xsl:variable name="creator" select="$spreadsheets//atom:entry[gsx:commitdate = $date]/gsx:creator"/>
            
        
        
        <prov:Activity>
            <rdf:type rdf:resource="http://www.w3.org/ns/prov#{$mode}"/>
            <prov:atTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                <xsl:value-of select="."/>
            </prov:atTime>
            
            <!-- evaluate spreadsheets to determine the uploader -->
            <xsl:call-template name="uploader">
                <xsl:with-param name="creator" select="$creator"/>
            </xsl:call-template>
            
            <!-- evaluate spreadsheet URL based on commit date -->
            <xsl:call-template name="generate-spreadsheet">
                <xsl:with-param name="date" select="$date"/>
            </xsl:call-template>
            <dcterms:type>spreadsheet</dcterms:type>
        </prov:Activity>
    </xsl:template>

    <!-- use the spreadsheet of spreadsheets to extract the key -->
    <xsl:template name="generate-spreadsheet">
        <xsl:param name="date"/>

        <xsl:variable name="key" select="$spreadsheets//atom:entry[gsx:commitdate = $date]/gsx:spreadsheetkey"/>
        
        <prov:used rdf:resource="{concat('https://docs.google.com/spreadsheets/d/', $key, '/pubhtml')}"/>
    </xsl:template>
    
    <xsl:template name="uploader">
        <xsl:param name="creator"/>
        
        <xsl:choose>
            <xsl:when test="$creator = 'http://nomisma.org/editor/upeter'">
                <prov:wasAssociatedWith rdf:resource="http://nomisma.org/editor/upeter"/>
            </xsl:when>
            <xsl:when test="$creator = 'http://nomisma.org/editor/ameadows'">
                <prov:wasAssociatedWith rdf:resource="http://nomisma.org/editor/ameadows"/>
            </xsl:when>
            <xsl:otherwise>
                <prov:wasAssociatedWith rdf:resource="http://nomisma.org/editor/egruber"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[rdf:type/@rdf:resource = 'http://www.w3.org/2004/02/skos/core#Concept']">
        <xsl:element name="{name()}">
            <xsl:attribute name="rdf:about" select="@rdf:about"/>
            <xsl:variable name="uri" select="@rdf:about"/>
            <xsl:apply-templates/>
            <skos:inScheme rdf:resource="http://nomisma.org/id/"/>
            <skos:changeNote rdf:resource="{concat($uri, '#provenance')}"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
