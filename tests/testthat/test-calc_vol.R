test_that("volatility estimate is correct for example compound for entire workflow", {
  ex_vol_df <- calc_vol(compound_id = "C16181", path = "data", redownload = FALSE)
  expect_equal(round(ex_vol_df$volatility, 6), 6.975571)
})

test_that("volatility estimate is correct for example compound with pathway for entire workflow", {
  ex_vol_df <- calc_vol(compound_id = "C16181", pathway_id = "map00361",
                        path = "data", redownload = FALSE)
  expect_equal(round(ex_vol_df$volatility, 6), 6.975571)
})

test_that("volatility estimate is correct for example compound from functional groups dataframe", {
  ex_fx_df <- get_fx_groups(compound_id = "C16181", pathway_id = "map00361",
                            path = "data")
  ex_vol_df <- calc_vol(compound_id = "C16181", pathway_id = "map00361",
                        path = "data", redownload = FALSE,
                        get_groups = FALSE, fx_groups_df = ex_fx_df)
  expect_equal(round(ex_vol_df$volatility, 6), 6.975571)
})

test_that("returns error if no functional groups dataframe and no saving file and getting functional groups dataframe", {
  expect_error(calc_vol(compound_id = "C16181", pathway_id = "map00361",
                        path = "data", redownload = FALSE,
                        get_groups = FALSE, fx_groups_df = NULL))
})

test_that("returns correct number of columns depending on return arguments", {
  expect_equal(ncol(calc_vol(compound_id = "C16181", pathway_id = "map00361",
                             path = "data", redownload = FALSE)), 6)
  expect_equal(ncol(calc_vol(compound_id = "C16181", pathway_id = "map00361",
                             path = "data", return_fx_groups = TRUE, redownload = FALSE)), 45)
  expect_equal(ncol(calc_vol(compound_id = "C16181", pathway_id = "map00361",
                             path = "data", return_calc_steps = TRUE, redownload = FALSE)), 9)
  expect_equal(ncol(calc_vol(compound_id = "C16181", pathway_id = "map00361",
                             path = "data", return_fx_groups = TRUE,
                             return_calc_steps = TRUE, redownload = FALSE)), 48)
})
