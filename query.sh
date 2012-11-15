#!/bin/bash
#Author: Sarven Capadisli <info@csarven.ca>
#Author URL: http://csarven.ca/#i

year=2010;

cat indicators.txt | while read i ; do
    if [ ! -f "data/$i.$year.csv" ]
        then
            echo "$i" ; java tdb.tdbquery --desc=/usr/lib/fuseki/tdb2.transparency.ttl --results csv --time "PREFIX owl: <http://www.w3.org/2002/07/owl#> PREFIX sdmx-dimension: <http://purl.org/linked-data/sdmx/2009/dimension#> PREFIX sdmx-measure: <http://purl.org/linked-data/sdmx/2009/measure#> PREFIX year: <http://reference.data.gov.uk/id/year/> PREFIX wbindicator: <http://worldbank.270a.info/classification/indicator/> PREFIX wbp: <http://worldbank.270a.info/property/> PREFIX property: <http://transparency.270a.info/property/> SELECT ?indicatorValue ?CPIRank WHERE { { ?observationURI property:indicator <http://transparency.270a.info/classification/indicator/corruption-perceptions-index> ; sdmx-dimension:refPeriod year:$year ; sdmx-dimension:refArea ?countryURI ; . ?countryURI owl:sameAs ?wbCountry . FILTER (regex(str(?wbCountry), \"^http://worldbank.270a.info/\")) } SERVICE <http://worldbank.270a.info/sparql> { GRAPH <http://worldbank.270a.info/graph/world-development-indicators> { ?wbObservationURI wbp:indicator wbindicator:$i ; sdmx-dimension:refPeriod year:$year ; sdmx-dimension:refArea ?wbCountry ; sdmx-measure:obsValue ?indicatorValue } } ?observationURI property:rank ?CPIRank . } ORDER BY ?indicatorValue ?CPIRank" > data/"$i"."$year".csv ;
    fi
done
