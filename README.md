
<!-- README.md is generated from README.Rmd. Please edit that file -->

# volcalc

<!-- badges: start -->

[![R-CMD-check](https://github.com/Meredith-Lab/volcalc/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Meredith-Lab/volcalc/actions/workflows/R-CMD-check.yaml)
[![latest-DOI](https://zenodo.org/badge/425022983.svg)](https://zenodo.org/badge/latestdoi/425022983)

<!-- badges: end -->

## Overview

The goal of volcalc is to automate calculating estimates of volatility
for chemical compounds.

Volatility can be estimated for most chemical compounds that are in the
[KEGG](https://www.genome.jp/kegg/) database, using just the [KEGG
unique identifier](https://www.genome.jp/kegg/compound/) for the
compound of interest. Alternatively, volatility can be estimated for
multiple compounds that are in a [KEGG
pathway](https://www.genome.jp/kegg/pathway.html).

## Installation

### Using without installing

You can use the `volcalc` package by using RStudio on a server
[here](https://mybinder.org/v2/gh/Meredith-Lab/binder_volcalc/master?urlpath=rstudio).
This instance can be slow to launch.

The instance was generated using [Binder](https://mybinder.org/), which
is an excellent free, open source tool to create custom computing
environments.

To see an example of how to use `volcalc`, run the script
`example_volcalc_usage.R` which is included in the server’s file system.

### Installing locally

You can install `volcalc` from GitHub with

``` r
# install.packages("remotes")
remotes::install_github("Meredith-Lab/volcalc")
```

Or from r-universe with

``` r
install.packages('volcalc', repos = c('https://cct-datascience.r-universe.dev', 'https://cloud.r-project.org'))
```

Installation of `volcalc` requires the system library
[OpenBabel](https://openbabel.org/) (it’s a requirement of the
`ChemmineOB` package, which `volcalc` depends on). For macOS, this can
be installed via homebrew by running the following shell command:

``` bash
brew install open-babel
```

For ubuntu linux:

``` bash
sudo apt-get install libopenbabel-dev
sudo apt-get install libeigen3-dev
```

For windows, `OpenBabel` is included in the `ChemmineOB` binary and does
not need to be installed separately.

For other installation options see the [OpenBabel
documentation](https://openbabel.org/docs/dev/Installation/install.html)
and `ChemmineOB` [install
guide](https://github.com/girke-lab/ChemmineOB/blob/master/INSTALL)

### Loading package

Use the package with:

``` r
library(volcalc)
#> Warning: package 'volcalc' was built under R version 4.2.3
```

## Single compound usage

This is a basic example which shows you how to get a volatility estimate
for an example compound *beta-2,3,4,5,6-Pentachlorocyclohexanol*. The
KEGG compound identifier for the compound, as found on [the compound’s
KEGG page](https://www.genome.jp/dbget-bin/www_bget?C16181), is
*C16181*.

#### Single function approach

``` r
calc_vol(compound_id = "C16181")
#>      pathway compound  formula                                   name
#> CMP1      NA   C16181 C6H7Cl5O beta-2,3,4,5,6-Pentachlorocyclohexanol
#>      volatility category
#> CMP1   6.975571     high
```

This returns a dataframe with columns specifying general info about the
compound, and the compound’s calculated volatility and corresponding
volatility category. The functional group counts underlying the
volatility can be additionally returned with `return_fx_groups = TRUE`,
and the intermediate calculation steps with `return_calc_steps = TRUE`.
A list of all possible dataframe columns is included below.

There are other possible input arguments to the function. The compound
can alternatively be specified with its chemical formula using the
`compound_formula` argument instead of `compound_id` as in the example.
The KEGG pathway that a compound is part of can be included with the
`pathway_id` argument, which will generate a data subfolder for all
compounds in that specified pathway. You can specify where the compound
files are downloaded by setting the desired relative path using
`path = "path/to/folder"`; otherwise, the path will be in a `data`
folder in the current directory. If the underlying data file for a
compound has already been downloaded in the specified path, it will not
be downloaded again unless `redownload = TRUE`.

#### Multiple function approach

This breaks the steps done by `calc_vol` into three parts: 1) download
the compound’s .mol file from KEGG, 2) count occurrences of different
functional groups, and 3) estimate volatility. This calculation uses the
SIMPOL approach[^1].

``` r
save_compound_mol(compound_id = "C16181")
example_compound_fx_groups <- get_fx_groups(compound_id = "C16181")
example_compound_vol <- calc_vol(compound_id = "C16181", fx_groups_df = example_compound_fx_groups)
print(example_compound_vol$volatility)
#> [1] 6.975571
```

This example compound has a volatility around 7. It is in the high
volatility category.

Many of the arguments described for `calc_vol` can be used in these
intermediate functions. See function documentation for details.

## Multiple compounds from a pathway usage

A dataframe with volatility estimates for all compounds in a chosen
pathway can be returned as below.

``` r
example_pathway_vol <- calc_pathway_vol("map00361")
print(example_pathway_vol[1,])
#>       pathway compound formula name volatility category
#> CMP1 map00361   C00011     CO2 CO2;   7.914336     high
```

## Dataframe columns

### Basic compound information

- pathway: KEGG pathway identifier
- compound: KEGG compound identifier
- formula: compound chemical formula
- name: compound name
- mass: compound mass

### Counted functional groups and atoms

- carbons
- ketones
- aldehydes
- hydroxyl_groups
- carbox_acids
- peroxide
- hydroperoxide
- nitrate
- nitro
- carbon_dbl_bonds
- rings
- rings_aromatic
- phenol
- nitrophenol
- nitroester
- ester
- ether_alicyclic
- ether_aromatic
- amine_primary
- amine_secondary
- amine_tertiary
- amine_aromatic
- amines
- amides
- phosphoric_acid
- phosphoric_ester
- sulfate
- sulfonate
- thiol
- carbothioester
- oxygens
- chlorines
- nitrogens
- sulfurs
- phosphoruses
- bromines
- iodines
- fluorines

### Volatility calculation steps

- log_alpha: intermediate step
- log_Sum: intermediate step
- volatility: estimated volatility
- category: volatility category, where values less than 0 are “none”,
  values between 0 and 2 are “moderate”, and values above 2 are “high”

### Functional group details

| Functional group   | In manual? | Count method        | Coefficient | Coef source      |
|--------------------|------------|---------------------|-------------|------------------|
| Carbons            | Y          | ChemmineR atomcount | -0.438      | ?                |
| Ketones            | Y          | ChemmineR groups    | -0.935      | Pankow & Asher   |
| Aldehydes          | Y          | ChemmineR groups    | -1.35       | Pankow & Asher   |
| Hydroxyl groups    | Y          | ChemmineR groups    | -2.23       | Pankow & Asher   |
| Carboxylic acids   | Y          | ChemmineR groups    | -3.58       | Pankow & Asher   |
| Peroxide           | Y          | SMARTS              | -0.368      | Pankow & Asher   |
| Hydroperoxide      | Y          | NA                  | -2.48       | Pankow & Asher   |
| Nitrate            | Y          | SMARTS              | -2.23       | Pankow & Asher   |
| Nitro              | Y          | SMARTS              | -2.15       | Pankow & Asher   |
| Carbon double bond | Y          | ChemmineR conMA     | -0.105      | Pankow & Asher   |
| Non-aromatic rings | Y          | ChemmineR rings     | –0.0104     | Pankow & Asher   |
| Aromatic rings     | Y          | ChemmineR rings     | -0.675      | Pankow & Asher   |
| Phenol             | Y          | SMARTS              | -2.14       | Pankow & Asher   |
| Nitrophenol        | Y          | NA                  | 0.0432      | Pankow & Asher   |
| Nitroester         | Y          | NA                  | -2.67       | Pankow & Asher   |
| Ester              | Y          | ChemmineR groups    | -1.20       | Pankow & Asher   |
| Ether (acyclic)    | Y          | NA                  | -0.683      | Pankow & Asher   |
| Ether (aromatic)   | Y          | NA                  | -1.03       | Pankow & Asher   |
| Amine primary      | Y          | ChemmineR groups    | -1.03       | Pankow & Asher   |
| Amine secondary    | Y          | ChemmineR groups    | -0.849      | Pankow & Asher   |
| Amine tertiary     | Y          | ChemmineR groups    | -0.608      | Pankow & Asher   |
| Amine aromatic     | Y          | ChemmineR rings     | -1.61       | Pankow & Asher   |
| Amine              | N          | SMARTS              | -2.23       | Same as nitrate  |
| Amide              | N          | SMARTS              | -2.23       | Same as nitrate  |
| Phosphoric acid    | N          | SMARTS              | -2.23       | Same as nitrate  |
| Phosphoric ester   | N          | SMARTS              | -2.23       | Same as nitrate  |
| Sulfate            | N          | SMARTS              | -2.23       | Same as nitrate  |
| Sulfonate          | N          | SMARTS              | -2.23       | Same as nitrate  |
| Thiol              | N          | SMARTS              | -2.23       | Same as hydroxyl |
| Carbothioester     | N          | SMARTS              | -1.20       | Same as ester    |

## How to contribute

We appreciate many kinds of feedback and contributions to this R
package. If you find a bug, are interested in an additional feature, or
have made improvements to the package that you want to share, feel free
to file an [issue](https://github.com/Meredith-Lab/volcalc/issues/new)
in this GitHub repo.

## How to cite

If you use this package in your published work, please cite it using the
reference below:

> Meredith, L.K., Riemer, K., Geffre, P., Honeker, L., Krechmer, J.,
> Graves, K., Tfaily, M., and Ledford, S.K. Automating methods for
> estimating metabolite volatility. In prep.

### References

[^1]: Pankow, J.F., Asher, W.E., 2008. SIMPOL.1: a simple group
    contribution method for predicting vapor pressures and enthalpies of
    vaporization of multifunctional organic compounds. Atmos. Chem.
    Phys. <https://doi.org/10.5194/acp-8-2773-2008>
