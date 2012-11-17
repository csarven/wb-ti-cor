#!/bin/bash
echo "Sorting coefficients"
sort -nr coefficients.2010.csv > c.csv
mv c.csv coefficients.2010.csv
echo "Creating index.xml"
echo '<table xmlns="http://www.w3.org/1999/xhtml"><tbody>' > index.xml
perl -pe 's/(.*)(?=,),(.*)(?=.2010.csv).2010.csv/<tr><td><a href="charts\/$2.2010.svg">$2<\/a><\/td><td>$1<\/td><\/tr>/' coefficients.2010.csv >> index.xml
echo '</tbody></table>' >> index.xml
echo "Creating index.html"
saxonb-xslt -s index.xml -xsl index.xsl indicators=indicators.rdf > index.html
