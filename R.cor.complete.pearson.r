#Author: Sarven Capadisli <info@csarven.ca>
#Author URL: http://csarven.ca/#i

#TODO: Add SVG hover for points to indicate country

args <- commandArgs(TRUE)
argv <- length(args)
#if (is.null(argv) | length(argv)<1) {
#  cat("Usage: installr.r pkg1 [pkg2 pkg3 ...]0")
#  q()
#}
#print(args)

library(ggplot2)
indicators <- read.csv("indicators-notations-prefLabels.csv", header=T)

files <- dir("data/", "*.csv")
for (f in files) {
    data <- read.csv(paste("data/", f, sep=""), header=T)
    results <- cor(data$indicatorValue, data$CPIScore, use="complete.obs", method="pearson")

    cat(paste(results[1], f, sep=","), file="coefficients.2010.csv", sep="\n", append=TRUE)

    n <- substr(f, 0, nchar(f, type="chars")-9)

    xlabel <- indicators[indicators$notation == n, 2]
    ylabel <- "CPI Score"

    ggsave(ggplot(data, aes(indicatorValue, CPIScore)) + xlab(xlabel) + ylab(ylabel) + geom_point(shape=19, alpha=3/4) + stat_smooth() + ggtitle("2010 correlations"), file=paste("charts/", substr(f, 0, nchar(f, type="chars")-4), ".svg", sep=""))
}
warnings()
