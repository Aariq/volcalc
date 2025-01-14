% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calc_pathway_vol.R
\name{calc_pathway_vol}
\alias{calc_pathway_vol}
\title{Calculate volatility estimates for all compounds in a pathway}
\usage{
calc_pathway_vol(
  pathway_id,
  path = "data",
  redownload = FALSE,
  return_fx_groups = FALSE,
  return_calc_steps = FALSE
)
}
\arguments{
\item{pathway_id}{An optional character string specifying KEGG pathway ID, in format of 5 digits prepended with "map".}

\item{path}{An optional parameter to set relative path to location to download data.}

\item{redownload}{Download file again even if it has already been downloaded at path.}

\item{return_fx_groups}{When \code{TRUE}, includes functional group counts in final dataframe.}

\item{return_calc_steps}{When \code{TRUE}, includes intermediate volatility calculation steps in final dataframe.}
}
\value{
Dataframe with columns of basic compound info and volatility value and
category. See documentation for column descriptions.
}
\description{
Volatility value and category is estimated for all compounds in a specified
pathway using the SIMPOL formula
}
\examples{
\dontrun{
ex_pathway <- calc_pathway_vol(pathway_id = "map00361")
}
}
