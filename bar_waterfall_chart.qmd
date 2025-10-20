---
title: "Bar Waterfall Charts"
date: 10-20-2025
author: Ntobeko Sosibo
toc: true
toc-location: left
toc-title: "Contents"
toc-depth: 6
format: 
  html:
    grid: 
      body-width: 1200px
    page-layout: full
    embed-resources: true
    self-contained: true
---
## 1. Looking at the ECharts example  

Echarts4r doesn't seem to gave an `e_waterfall()` or `e_bar_waterfall()` function, so I explored the [Bar Waterfall](https://echarts.apache.org/examples/en/editor.html?c=bar-waterfall) example on the site to see how they put their's together.  

It seems to be composed of a stacked bar chart with the base bar chart being invisible:  

```html
{
      name: 'Placeholder',
      type: 'bar',
      stack: 'Total',
      itemStyle: {
        borderColor: 'transparent',
        color: 'transparent'
      },
      emphasis: {
        itemStyle: {
          borderColor: 'transparent',
          color: 'transparent'
        }
      }
```

&nbsp;  

The bar stacked on top of that is what you end up seeing. This example also has these *invisible* values pre-calculated, but I wonder if the column could be defined to calculate it on-the-fly too..?  

Might try that later.  
  
&nbsp;  
  
### 1.1 Waterfall Bar Chart with ECharts4R  

```{r}
#| code-fold: true
#| label: bar-waterfall-chart
#| fig-width: 12
#| fig-height: 6

suppressPackageStartupMessages({
  library(echarts4r)
  library(tidyr)
  library(dplyr)
})

df <- tibble(
  category = c("Total","Rent","Utilities","Transportation","Meals","Other"),
  placeholder = c(0, 1700, 1400, 1200, 300, 0),
  life_cost = c(2900, 1200, 300, 200, 900, 300)
)

df_wide <- df |> 
  pivot_longer(
    cols = c(placeholder, life_cost),
               names_to = "expense_type",
               values_to = "value") |> 
  pivot_wider(names_from = expense_type, values_from = value)


df_wide |>
  e_charts(category) |>
  e_bar(
    placeholder,
    name = "Placeholder",
    stack = "total",
    itemStyle = list(
      borderColor = "transparent",
      color = "transparent"
    ),
    label = list(
      show = FALSE
    ),
    tooltip = list(
      show = FALSE
    )
  ) |>
  e_bar(
    life_cost,
    name = "Life Cost",
    stack = "total",
    itemStyle = list(
      color = "#1e8496"
    ),
  label = list(
    show = TRUE,
    position = "inside"
    )
  ) |>
  
  e_x_axis(
    type = "category",
    name = "Expenses",
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

  e_tooltip(
    trigger = "item"
  ) |>
  
  e_y_axis_(
    show = FALSE
  ) |>
  
  e_legend(
    show = FALSE
  ) |>
  
  e_title(
    "Waterfall Chart"
  )
  
```  

&nbsp;  

### 1.2 Accumulated Waterfall Bar Chart with ECharts4R  

This one gets a little trickier, but the logic behind it is more or less the same with small differences:  

```html
series: [
    {
      name: 'Placeholder',
      type: 'bar',
      stack: 'Total',
      silent: true,
      itemStyle: {
        borderColor: 'transparent',
        color: 'transparent'
      },
      emphasis: {
        itemStyle: {
          borderColor: 'transparent',
          color: 'transparent'
        }
      },
      data: [0, 900, 1245, 1530, 1376, 1376, 1511, 1689, 1856, 1495, 1292]
    },
    {
      name: 'Income',
      type: 'bar',
      stack: 'Total',
      label: {
        show: true,
        position: 'top'
      },
      data: [900, 345, 393, '-', '-', 135, 178, 286, '-', '-', '-']
    },
    {
      name: 'Expenses',
      type: 'bar',
      stack: 'Total',
      label: {
        show: true,
        position: 'bottom'
      },
      data: ['-', '-', '-', 108, 154, '-', '-', '-', 119, 361, 203]
    }
  ]
```  

&nbsp;  

On top of the `placeholder` and `expenses` variables, there's now also `income`. Looks like an hyphen (`-`) is used in the slot that isn't either `income` or `expense` for that particular day. 
  
  
```{r}
#| code-fold: true
#| label: accumulated-bar-waterfall-chart
#| fig-width: 12
#| fig-height: 6

suppressPackageStartupMessages({
  library(echarts4r)
  library(tidyr)
  library(dplyr)
})

df <- tibble(
  category = c("Feb 9", "Feb 10", "Feb 11", "Feb 12", "Feb 13", "Feb 14", "Feb 15", "Feb 16", "Feb 17", "Feb 18", "Feb 19"),
  placeholder = c(0, 2900, 4100, 3725, 2925, 2925, 3225, 3400, 4000, 2750, 2250),
  income = c(2900, 1200, 300, NA, NA, 300, 175, 600, 450, NA, NA),
  expenses = c(NA, NA, NA, 375, 800, NA, NA, NA, NA, 1250, 500)
)

df_wide <- df |> 
  pivot_longer(
    cols = c(placeholder, income, expenses),
               names_to = "money_type",
               values_to = "value") |> 
  pivot_wider(names_from = money_type, values_from = value)


df_wide |>
  e_charts(category) |>
  e_bar(
    placeholder,
    name = "Balance",
    stack = "total",
    itemStyle = list(
      borderColor = "transparent",
      color = "transparent"
    ),
    label = list(
      show = FALSE
    ),
    tooltip = list(
      trigger = "silent"
    ),
    legend = list(
      show = FALSE
    )
  ) |>
  e_bar(
    income,
    name = "Income",
    stack = "total",
    itemStyle = list(
      color = "#132e57"
    ),
    label = list(
      show = TRUE,
      position = "top"
      )
    ) |>
  e_bar(
    expenses,
    name = "Expenses",
    stack = "total",
    itemStyle = list(
      color = "#1e8496"
    ),
    label = list(
      show = TRUE,
      position = "bottom"
      )
    ) |>
  
  e_x_axis(
    type = "category",
    fontSize = 14,
    fontWeight = "bold",
    margin = 10) |>
  
  e_y_axis(
    type = "value",
    show = TRUE
  ) |>

  e_tooltip(
    trigger = "item"
  ) |>
  
  e_y_axis_(
    show = FALSE
  ) |>

  e_title(
    "Accumulated Waterfall Chart"
  )
  
```  

&nbsp; 

Using `'-'` in the place where there was no movement in either the `income` or `expenses` columns doesn't work in R, so you need to replace those with `NA`.  

The other thing you had to take into account was the positioning of the next bar being dependent on its height also being factored into the `placeholder` calculation. That way, it would visually make sense because its base would be situated at the "end" of the previous bar if the balance was going up, or set lower so that the top of the new bar met the bottom of the previous to indicate the balance going down. Below is the final table for this chart:  
  
&nbsp;  
  
+---------------+---------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------+
|**date**       |**Feb 9**|**Feb 10**|**Feb 11**|**Feb 12**|**Feb 13**|**Feb 14**|**Feb 15**|**Feb 16**|**Feb 17**|**Feb 18**|**Feb 19**|
+---------------+---------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------+
|**placeholder**| 0       | 2900     | 4100     | 3725     | 2925     | 2925     | 3225     | 3400     | 4000     | 2750     | 2250     |
+---------------+---------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------+
|**income**     | 2900    | 1200     | 300      | NA       | NA       | 300      | 175      | 600      | 450      | NA       | NA       |
+---------------+---------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------+
|**expenses**   | NA      | NA       | NA       | 375      | 800      | NA       | NA       | NA       | NA       | 1250     | 500      |
+---------------+---------+----------+----------+----------+----------+----------+----------+----------+----------+----------+----------+
  
&nbsp;  
  
Looking at the ECharts example, I was able to work out that the `placeholder` needs extra work at the pivoting points - where it changes from `income` to `expenses`, and vice versa:  

  - When `income` follows `income`, then the next day/entry's `placeholder` value = `prev_placeholder + prev_income`
  - When `expenses` follows `expenses`, then the next day/entry's `placeholder` value = `prev_placeholder − expenses`  
  - When `income` follows `expenses`, then the next day/entry's `placeholder` value = `prev_placeholder`  
  - When `expenses` follows `income`, then the next day/entry's `placeholder` value = `prev_placeholder - expenses`  

&nbsp;    

## 2. Outro  

The examples above stick very close to their ECharts counterparts. The part that took a little longer for me to wrap my head around was the `placeholder` calculations because it wasn't a one-for-one conversion. Having it visualised really helped to confirm when it had been calculated correctly.  

In this project I also got to learn but more about applying isolated edits/behaviours related to labels and tooltips. Usually those are tinkered with in their functions, but I had to isolate them to just the `placeholder` variable.  

The [**Horizontal Bar Chart with Negative Values**](https://github.com/afrikaniz3d-za/Quarto-Ready-ECharts4R-Templates/blob/main/bar_chart_horizontal_with_negative_direction.qmd) template was very useful in this one for setting most of the chart before applying conditions specific to the waterfall effect.  

If you think something's missing or have a question give me a shout and we can figure it out together.  
