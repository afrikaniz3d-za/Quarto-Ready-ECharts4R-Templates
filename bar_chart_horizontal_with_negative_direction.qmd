---
title: "Vertical & Horizontal Bar Charts with Negative Values"
date: 10-03-2025
author: Ntobeko Sosibo
toc: true
toc-location: left
toc-title: "Contents"
toc-depth: 6
format: 
  html:
    include-in-header: 
      text: |
        <link rel="icon" type="image/png" href="images/echarts4r_logo.png">
    page-layout: full
    embed-resources: true
    self-contained: true
---
## 1. Vertical Bar Chart with Positive (income), Negative (expenses) and Calculated Difference (Nett Income) Values  

I first wanted to present the vertical version of this graph as an option because it's relatively easy to set up and forms a vase for the horizontal version. It's based on the the ECharts [version](https://echarts.apache.org/examples/en/editor.html?c=bar-negative), with elements like stacking the income and expenses values, but profit/loss values being standalone.  

&nbsp;  


```{r}
#| code-fold: true
#| label: vertical-bars
#| fig-width: 12
#| fig-height: 6

suppressPackageStartupMessages(library(echarts4r))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(dplyr))


df <- tibble(
  day = c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"),
  income = c(120456.95,20456.95,150456.95,180456.95,70456.95,310456.95,130456.95),
  expenses = c(-50456.95,-10456.95,-55456.95,-23456.95,-75456.95,-88456.95,-66456.95),
  nett_income = c(income + expenses) # Did not think this logic would work! :D
)

df_wide <- df |> 
  pivot_longer(
    cols = c(income, expenses, nett_income),
               names_to = "money_group",
               values_to = "value") |> 
  pivot_wider(names_from = money_group, values_from = value)

df_wide |>
  e_charts(day) |>
  e_bar(
    income, 
    name = "Income",
    stack = "total",
    itemStyle = list(
      color = "#1e8496")) |>
  e_bar(
    expenses, 
    name = "Expenses",
    stack = "total",
    itemStyle = list(color = "#132e57")) |>
  e_bar(
    nett_income, 
    name = "Nett Income",
    itemStyle = list(color = "#fa621c")) |>
  
  e_x_axis(
    type = "category",
    name = "Days of the Week",
    nameLocation = "middle",
    nameGap = 40,
    nameTextStyle = list(
      fontSize = 16,
      fontWeight = "bold"),
    fontSize = 14,
    fontWeight = "bold",
    margin = 10) |>
  e_y_axis(
    type = "value",
    show = TRUE
  ) |>
  
  e_title(
    "An End-of-Week Income Spike was also the Most Expensive ",
    "Bar chart with negative values (Expenses), including a calculated Nett Income bar.") |>
  
  e_legend(
    top = "15%", 
    left = "35%") |>
  
  e_tooltip(
    trigger = "axis" 
    ) |>
  
  e_grid(
    bottom = "80", 
    left = "10%", 
    right = "5%", 
    top = "35%")
```
  
&nbsp;

## 2. Horizontal Bar Chart with Positive (income), Negative (expenses) and Calculated Difference (Nett Income) Values  

You don't have to change too much to get horizontal bars from the same dataset. The key changes are introducing the `e_flip_coords()` function right after the `e_bar()`'s, switching the x and y letters in the `e_y_axis()` and `e_y_axis()` functions, making any necessary adjustments that relate to the new relationships. Lastly, you might also need to introduce the `inverse = TRUE` argument into the `e_y_axis` function if you need to correct the order.  

&nbsp;  

```{r}
#| code-fold: true
#| label: horizontal-bars
#| fig-width: 19
#| fig-height: 10

suppressPackageStartupMessages(library(echarts4r))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(dplyr))


df <- tibble(
  day = c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"),
  income = c(120456.95,20456.95,150456.95,180456.95,70456.95,310456.95,130456.95),
  expenses = c(-50456.95,-10456.95,-55456.95,-23456.95,-75456.95,-88456.95,-66456.95),
  nett_income = c(income + expenses)
)

df_wide <- df |> 
  pivot_longer(
    cols = c(income, expenses, nett_income),
               names_to = "money_group",
               values_to = "value") |> 
  pivot_wider(names_from = money_group, values_from = value)

df_wide |>
  e_charts(day) |>
  e_bar(
    income, 
    name = "Income",
    stack = "total",
    itemStyle = list(
      color = "#1e8496")) |>
  e_bar(
    expenses, 
    name = "Expenses",
    stack = "total",
    itemStyle = list(color = "#132e57")) |>
  e_bar(
    nett_income, 
    name = "Nett Income",
    itemStyle = list(color = "#fa621c")) |>
  e_flip_coords() |>
   
  e_y_axis(
    type = "category",
    inverse = TRUE
    ) |>
  
  e_x_axis(
    type = "value",
    name = "Amount in Dollars ($)",
    nameLocation = "middle",
    nameGap = 40,
    nameTextStyle = list(
      fontSize = 16,
      fontWeight = "bold")
  ) |>
  
  e_title(
    "An End-of-Week Revenue Spike was also the Most Expensive ",
    "Bar chart with negative values (Expenses), including a calculated Nett Income bar.") |>
  
  e_legend(
    top = "15%", 
    left = "40%") |>
  
  e_tooltip(
    trigger = "axis" 
    ) |>
  
  e_grid(
    bottom = "100", 
    left = "10%", 
    right = "5%", 
    top = "25%")
```
  
&nbsp;  

In this example I purposefully created a dynamic column, `nett_income`, which calculated off of `income` and `expenses`. I really wasn't expecting the logic of it to be so simple :D I'm sure there's more you can do with it, but I like the flexibility in this context rather than making the changes elsewhere and bringing the updated table in after each change.  

&nbsp;  

## 3. Outro  

I will add to this document as I work more with these charts and learn new things. If you think something's missing or have a question give me a shout and we can figure it out together.  

