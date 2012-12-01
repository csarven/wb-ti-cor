<!--
    Author: Sarven Capadisli <info@csarven.ca>
    Author URL: http://csarven.ca/#i
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"

    xpath-default-namespace="http://www.w3.org/1999/xhtml"

    exclude-result-prefixes="xsl rdf skos"
    >

    <xsl:param name="indicators"/>

    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:template match="/">
        <html>
            <head>
                <title>Correlations between World Bank Indicators and Transparency International Corruption Perceptions Index Linked Data</title>
            </head>
            <body>
                <h1>Correlations between World Bank and Transparency International Linked Data</h1>

                <dl>
                    <dt>Author</dt>
                    <dd><a href="http://csarven.ca/#i">Sarven Capadisli</a></dd>
                    <dt>Notes</dt>
                    <dd>The following work was originally developed during the <a href="http://15iacc.org/get-involved/iacc-hackathon/">hackathon</a> at the <a href="http://15iacc.org/">15th International Anti-Corruption Conference</a>.</dd>
                    <dt>Status</dt>
                    <dd>Request for comments.</dd>
                </dl>


                <h2 id="hypothesis">Hypothesis</h2>
                <p>Can correlations be made between <a href="http://worldbank.org/">World Bank</a> and <a href="http://transparency.org/">Transparency International</a> Linked Data?</p>

                <h2 id="results">Results</h2>
                <table>
                    <caption>Correlation coefficients and Scatter plots for World Bank indicators and Transparency International CPI scores</caption>
                    <thead>
                        <tr><td>Coefficient</td><td>Plot</td><td>Indicator</td><td>Source</td></tr>
                    </thead>
                    <tfoot>
                        <tr>
                            <td colspan="3">
                                <dl>
                                    <dt>Results</dt>
                                    <dd>Coefficient values 1, NA, and -1 don't have much meeting (due to insufficient data) but left in the table for completeness.</dd>
                                    <dt>Data coverage</dt>
                                    <dd>Incomplete data coverage due to original datasets e.g., Observation data is not available for each country and year for a given indicator. Hence, there is no matching with CPI score for that country and year.</dd>
                                </dl>
                            </td>
                        </tr>
                    </tfoot>
                    <tbody>
                        <xsl:call-template name="table"/>
                    </tbody>
                </table>

                <h2 id="methodology">Methodology</h2>
                <ul>
                    <li>Access to <a href="http://worldbank.270a.info/">World Bank Linked Data</a> and <a href="http://transparency.270a.info/">Transparency International Linked Data</a> primarily to run SPARQL queries over both datasets.</li>
                    <li>Collected a list of World Bank Indicators (little over 7000) and saved them in a plain text file (one indicator per line).</li>
                    <li>Using a Bash script, for each indicator and year (2010), queried the SPARQL endpoint with Apache Jena's command line tool <code>tdbquery</code>.</li>
                    <li id="data-retrieval">Retrieved data via SPARQL query from endpoint <a href="http://transparency.270a.info/sparql">http://transparency.270a.info/sparql</a>, and saved the CSV outputs per indicator. The query matches observations from the Transparency International's Corruption Perceptions Index dataset and the observations from the World Bank indicators such that they both contain the same year and country. For those matches, indicator values are taken from the World Bank observations, and the scores from the Transparency International CPIs. The query is as follows:
<pre>
PREFIX owl: &lt;http://www.w3.org/2002/07/owl#&gt;
PREFIX skos: &lt;http://www.w3.org/2004/02/skos/core#&gt;
PREFIX sdmx-dimension: &lt;http://purl.org/linked-data/sdmx/2009/dimension#&gt;
PREFIX sdmx-measure: &lt;http://purl.org/linked-data/sdmx/2009/measure#&gt;
PREFIX year: &lt;http://reference.data.gov.uk/id/year/&gt;
PREFIX wbindicator: &lt;http://worldbank.270a.info/classification/indicator/&gt;
PREFIX wbp: &lt;http://worldbank.270a.info/property/&gt;
PREFIX property: &lt;http://transparency.270a.info/property/&gt;

SELECT ?countryCode ?indicatorValue ?CPIScore
WHERE {
    {
        ?observationURI
            property:indicator &lt;http://transparency.270a.info/classification/indicator/corruption-perceptions-index&gt; ;
            sdmx-dimension:refPeriod year:$year ;
            sdmx-dimension:refArea ?countryURI ;
        .
        ?countryURI owl:sameAs ?wbCountry .
        FILTER (regex(str(?wbCountry), "^http://worldbank.270a.info/"))
    }
    SERVICE &lt;http://worldbank.270a.info/sparql&gt; {
        SELECT ?wbCountry ?indicatorValue
        WHERE {
            GRAPH &lt;http://worldbank.270a.info/graph/world-development-indicators&gt; {
                ?wbObservationURI wbp:indicator wbindicator:$i ;
                sdmx-dimension:refPeriod year:$year ;
                sdmx-dimension:refArea ?wbCountry ;
                sdmx-measure:obsValue ?indicatorValue
            }
            GRAPH &lt;http://worldbank.270a.info/graph/meta&gt; {
                ?wbCountry skos:notation ?countryCode
            }
        }
    }
    ?observationURI property:score ?CPIScore .
}
ORDER BY ?indicatorValue ?CPIScore
</pre>
                    </li>
                    <li>Filtered files with no indicator and score values.</li>
                    <li>Using the <a href="http://www.r-project.org/">R</a> software (for statistical computing), for each CSV file which contains the indicator values and the scores, coefficients are calculated using the <a href="http://en.wikipedia.org/wiki/Pearson_product-moment_correlation_coefficient">Pearson correlation</a>. All of the coefficients are kept in a single file. Scatter plots are created from each CSV file.</li>
                </ul>

                <h2 id="source-code">Source Code</h2>
                <p>Source code is available on GitHub: <a href="https://github.com/csarven/wb-ti-cor">csarven/wb-ti-cor</a>. It is using the Apache License 2.0.</p>

                <h2 id="conclusions">Conclusions</h2>
                <ul>
                    <li>Correlation coefficient is dependent on data quality. Possible action: original data providers should publish more complete datasets.</li>
                </ul>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="table">
        <xsl:for-each select="table/tbody/tr">
            <xsl:variable name="notation" select="normalize-space(td/a)"/>
            <tr>
                <td>
                    <xsl:value-of select="td[2]"/>
                </td>
                <td>
                    <a href="{td/a/@href}">Scatter</a>
                </td>
                <td>
                    <a href="http://worldbank.270a.info/classification/indicator/{$notation}"><xsl:value-of select="document($indicators)/rdf:RDF/rdf:Description[skos:notation = $notation]/skos:prefLabel/text()"/></a>
                </td>
                <td>
                    <a href="data/{$notation}.2010.csv">CSV</a>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
