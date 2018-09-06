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
    <xsl:variable name="fon" select="data(rdf:RDF/*[1]/dcterms:isPartOf/@rdf:resource)"/>

    <!-- see spreadsheet of Nomisma spreadsheets for list of associated Github commit dates : 
        https://docs.google.com/spreadsheets/d/e/2PACX-1vSzEJwjXIPApTOTCCjGTU9F2_r2QL7qZB-2iv3WIW8_8jDGsyqKNskQzLQ5bfjsTf7J1xoKcneEXngE/pubhtml -->

    <!-- Atom feed of spreadsheet -->
    <xsl:variable name="spreadsheets" as="document-node()">
        <xsl:copy-of select="document('spreadsheets.xml')"/>
        <!--<xsl:copy-of select="document('https://spreadsheets.google.com/feeds/list/1ke1Vi8sy9j_D7mnAUA0jgE1po3__RUCQuD2cTW7U8ZQ/od6/public/full')"/>-->
    </xsl:variable>

    <!-- create a sequence of commit dates from the spreadsheet -->
    <xsl:variable name="dates" select="data($spreadsheets//gsx:commitdate)"/>

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
                                <xsl:when
                                    test="@desc = 'fixed date glitch' or @desc = 'added skos:Concept into dynasty ids' or @desc = 'added FoN islamic_numismatics' or @desc = 'fixed structure'">
                                    <!-- note: minor fixes after creation of Islamic orgs and dynasties -->
                                </xsl:when>
                                <xsl:when test="contains(., '2016-04-13')">
                                    <!-- migrated CIDOC-CRM to canonical URI from Erlangen -->
                                </xsl:when>
                                <xsl:when test="contains(., '2016-06-13')">
                                    <!-- replaced http with https in wikidata URIs -->
                                </xsl:when>
                                <xsl:when test="@desc = 'changed the class of Epirote and Achaean Leagues'">
                                    <!-- 2018-04-11 -->
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
                    <xsl:when test="index-of($dates, $creation) &gt; 0">

                        <!-- call a manual modification event for certain combinations of type and date -->
                        <xsl:choose>
                            <xsl:when test="$creation = '2015-07-31' and not($type = 'foaf:Person')">
                                <xsl:apply-templates select="$history/date[1]" mode="manual">
                                    <xsl:with-param name="mode">Create</xsl:with-param>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:when test="$creation = '2015-07-01' and not($type = 'foaf:Person')">
                                <xsl:apply-templates select="$history/date[1]" mode="manual">
                                    <xsl:with-param name="mode">Create</xsl:with-param>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:when test="$creation = '2018-04-20' and $type = 'nmo:Collection'">
                                <xsl:apply-templates select="$history/date[1]" mode="manual">
                                    <xsl:with-param name="mode">Create</xsl:with-param>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="$history/date[1]" mode="spreadsheet">
                                    <xsl:with-param name="mode">Create</xsl:with-param>
                                </xsl:apply-templates>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="$history/date[1]" mode="manual">
                            <xsl:with-param name="mode">Create</xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>

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
                                        <prov:wasAssociatedWith rdf:resource="http://nomisma.org/editor/egruber"/>
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
                                        <prov:wasAssociatedWith rdf:resource="http://nomisma.org/editor/egruber"/>
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
                                        <prov:wasAssociatedWith rdf:resource="http://nomisma.org/editor/egruber"/>
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
                                <xsl:with-param name="creation" select="$creation"/>
                            </xsl:apply-templates>

                            <!-- call template on the final commit, but only evaluate whether it should exist within the template -->
                            <xsl:apply-templates select="$history/date[last()]" mode="manual">
                                <xsl:with-param name="mode">Modify</xsl:with-param>
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </dcterms:ProvenanceStatement>
        </xsl:element>
    </xsl:template>

    <xsl:template match="date" mode="manual">
        <xsl:param name="mode"/>

        <xsl:variable name="date" select="substring-before(., 'T')"/>

        <xsl:choose>
            <xsl:when test="$mode = 'Create'">
                <prov:wasGeneratedBy>
                    <prov:Activity>
                        <rdf:type rdf:resource="http://www.w3.org/ns/prov#{$mode}"/>
                        <prov:atTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                            <xsl:value-of select="."/>
                        </prov:atTime>

                        <!-- attempt to evaluate the prov:wasAssociatedWith by date, field of numismatics, or other parameters -->
                        <xsl:choose>
                            <xsl:when test="$date = '2012-10-28'">
                                <prov:wasAssociatedWith rdf:resource="http://nomisma.org/editor/ameadows"/>
                                <prov:wasAssociatedWith rdf:resource="http://nomisma.org/editor/sfsheath"/>
                                <dcterms:description xml:lang="en">
                                    <xsl:text>This is among the original Nomisma XHTML+RDFa fragments, most likely created between 2010-2012 by Sebastian Heath and/or Andy Meadows.</xsl:text>
                                </dcterms:description>
                            </xsl:when>
                            <xsl:when
                                test="($type = 'nmo:Mint' or $type = 'foaf:Person' or $type = 'nmo:Denomination') and (index-of($fon, 'http://nomisma.org/id/modern_german_numismatics') or index-of($fon, 'http://nomisma.org/id/medieval_european_numismatics'))">
                                <!-- assign Medieval, Modern German, and Merovingian mint or person IDs to Karsten -->
                                <xsl:if test="not(index-of($fon, 'http://nomisma.org/id/roman_numismatics'))">
                                    <!--ignore any IDs already in Roman numismatics -->
                                    <prov:wasAssociatedWith rdf:resource="http://nomisma.org/editor/kdahmen"/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="$type = 'foaf:Person' and index-of($fon, 'http://nomisma.org/id/byzantine_numismatics')">
                                <!-- Byzantine people created by Dennis Mathie -->
                                <prov:wasAssociatedWith rdf:resource="http://nomisma.org/editor/dmathie"/>
                            </xsl:when>
                            <xsl:when test="contains($id, '_pir')">
                                <prov:wasAssociatedWith rdf:resource="http://nomisma.org/editor/kdahmen"/>
                            </xsl:when>
                        </xsl:choose>
                        <dcterms:type>manual</dcterms:type>
                    </prov:Activity>
                </prov:wasGeneratedBy>
            </xsl:when>
            <xsl:when test="$mode = 'Modify'">
                <!-- insert an event if the date isn't in a spreadsheet -->
                <xsl:if test="not(index-of($dates, $date))">
                    <prov:activity>
                        <prov:Activity>
                            <rdf:type rdf:resource="http://www.w3.org/ns/prov#{$mode}"/>
                            <prov:atTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                                <xsl:value-of select="."/>
                            </prov:atTime>

                            <!-- agents of manual modification are nearly impossible to ascertain -->
                            <dcterms:type>manual</dcterms:type>
                        </prov:Activity>
                    </prov:activity>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="date" mode="spreadsheet">
        <xsl:param name="mode"/>
        <xsl:param name="creation"/>

        <xsl:variable name="date" select="substring-before(., 'T')"/>

        <!-- ignore certain dates when the ID doesn't match a specific parameter -->
        <xsl:choose>
            <xsl:when test="($date = $creation) and $mode = 'Modify'">
                <!-- ignore events that are already determined to be creation dates -->
            </xsl:when>
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
                    <xsl:when test="$mode = 'Create'">
                        <prov:wasGeneratedBy>
                            <xsl:call-template name="activity">
                                <xsl:with-param name="mode" select="$mode"/>
                            </xsl:call-template>
                        </prov:wasGeneratedBy>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="activity">
        <xsl:param name="mode"/>

        <xsl:variable name="date" select="substring-before(., 'T')"/>
        <xsl:variable name="creator" select="$spreadsheets//atom:entry[gsx:commitdate = $date][1]/gsx:creator"/>

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

            <!-- insert a note that all spreadsheets uploaded before or on 2015-06-12 (Non-Islamic corporate entities and dynasties) were converted to IDs through manual one-off scripts -->
            <xsl:if test="xs:date($date) &lt;= xs:date('2015-06-12')">
                <dcterms:description xml:lang="en">
                    <xsl:text>This ID was generated by processing a spreadsheet through a one-off PHP script, predating the Nomisma spreadsheet import feature.</xsl:text>
                </dcterms:description>
            </xsl:if>
        </prov:Activity>
    </xsl:template>

    <!-- use the spreadsheet of spreadsheets to extract the key -->
    <xsl:template name="generate-spreadsheet">
        <xsl:param name="date"/>

        <!-- evaluate spreadsheets with multiple dates -->
        <xsl:variable name="key">
            <xsl:choose>
                <xsl:when test="$date = '2017-12-16'">
                    <xsl:choose>
                        <xsl:when test="$type = 'foaf:Person'">
                            <xsl:text>1vi_FA60ybtzebLrqzb78ZS5YGk0elvCRp4EsVgoVIEs</xsl:text>
                        </xsl:when>
                        <xsl:when test="$type = 'foaf:Organization'">
                            <xsl:text>1ohAgCJ3nRIoA8PKFaM65YcHkMrChwHrDK37yuScK_IY</xsl:text>
                        </xsl:when>
                        <xsl:when test="$type = 'nmo:Mint'">
                            <xsl:text>1qUZ8k6Nd0kaEeGdOqpVDgP3gcBCaLqtls_0HHS18Cus</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$date = '2018-04-11'">
                    <xsl:choose>
                        <xsl:when test="@desc = 'added remaining Seleucids'">
                            <xsl:text>1vi_FA60ybtzebLrqzb78ZS5YGk0elvCRp4EsVgoVIEs</xsl:text>
                        </xsl:when>
                        <xsl:when test="@desc = 'added new Hellenistic kingdoms'">
                            <xsl:text>1IbLGN9SsiR89MmD_4GSs3qHgydj0g8gT174Lgf6xjio</xsl:text>
                        </xsl:when>
                        <xsl:when test="@desc = 'added new Greek dynasties'">
                            <xsl:text>1KNnrbtxrc2vtSLKjcp3zNdYcKq6x7okR00H-3CXvNiI</xsl:text>
                        </xsl:when>
                        <xsl:when test="@desc = 'added Hellenistic rulers to fill gaps in IGCH'">
                            <xsl:text>1gXcM0SRWqSZ4RJiDg21i5PI91EVyfMr1ogVgnH9zhIE</xsl:text>
                        </xsl:when>
                        <xsl:when test="@desc = 'began adding Ptolemies'">
                            <xsl:text>13vtnvFZVvRCxdgc9K4a8_EAdBEfcr1wW9gb0wmynLuE</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$spreadsheets//atom:entry[gsx:commitdate = $date]/gsx:spreadsheetkey"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <prov:used rdf:resource="{concat('https://docs.google.com/spreadsheets/d/', $key, '/pubhtml')}"/>
    </xsl:template>

    <xsl:template name="uploader">
        <xsl:param name="creator"/>

        <xsl:choose>
            <xsl:when test="$creator = 'http://nomisma.org/editor/upeter'">
                <prov:wasAssociatedWith rdf:resource="http://nomisma.org/editor/upeter"/>
            </xsl:when>
            <xsl:when test="$creator = 'http://nomisma.org/editor/ameadows' or $creator = 'http://nomisma.org/editor/kdahmen'">
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

    <!-- canonical Wikidata URI is http, not https -->
    <xsl:template match="skos:exactMatch[contains(@rdf:resource, 'wikidata.org')]">
        <skos:exactMatch rdf:resource="{replace(@rdf:resource, 'https', 'http')}"/>
    </xsl:template>
</xsl:stylesheet>
