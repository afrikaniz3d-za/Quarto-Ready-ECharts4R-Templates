---
title: "Funnel Charts"
date: 12-07-2025
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

## 1. Existing examples from the documentation(s)  

Both versions of the standard chart are set up in more-or-less the same way.  

&nbsp;  

### 1.1 As per CRAN documentation PDF 

Here's the example from the [ECharts4R site](https://cran.r-project.org/web/packages/echarts4r/echarts4r.pdf) pdf documentation. 

&nbsp;  

```{r}
#| code-fold: true
#| label: basic-funnel-chart-pdf-documentation
#| fig-width: 5
#| fig-height: 6


suppressPackageStartupMessages({
  library(echarts4r)
  })

# example data
funnel <- data.frame(
stage = c("View", "Click", "Purchase"),
value = c(80, 30, 20)
)
funnel |>
e_charts() |>
e_funnel(value, stage)
```  

&nbsp;  

### 1.2 As per ECharts4R documentation site 

Here's the example (with minor adjustments) provided on John Coene's [ECharts4R site](https://echarts4r.john-coene.com/articles/chart_types). 

&nbsp;  

```{r}
#| code-fold: true
#| label: basic-funnel-chart-echarts4r-site
#| fig-width: 5
#| fig-height: 6

suppressPackageStartupMessages({
  library(echarts4r)
  })

# example data
funnel <- data.frame(stage = c("View", "Click", "Purchase"), value = c(80, 30, 20))

funnel |> 
  e_charts() |> 
  e_funnel(value, stage) |> 
  e_title("Funnel")
```  

&nbsp;  

### 1.3 Translating from ECharts  

This example depicts unit sales within the Electronic category for an hypothetical retail chain. It mirrors the structure found in the [Sunburst with Rounded Corner](https://echarts.apache.org/examples/en/editor.html?c=sunburst-borderRadius) example, but the table is formatted the same way as the chart from **1.2**.  

[Customized Funnel](https://echarts.apache.org/examples/en/editor.html?c=funnel-customize). There was another example, [Compare Funnel](https://echarts.apache.org/examples/en/editor.html?c=funnel-align), but I think this one does a better job.

```{r}
#| code-fold: true
#| label: overlaid-funnel
#| fig-width: 8
#| fig-height: 8

suppressPackageStartupMessages({
  library(echarts4r)
  library(htmltools)
  library(dplyr)
})

# example data
funnel <- data.frame(
  stage = c("View", "Click", "Add to Cart", "Checkout"),
  prev_value = c(8012, 6223, 4034, 2146),
  curr_value = c(7656, 6667, 2378, 1089),
  perc = c(96, 107, 59, 51)
  )

# generating the chart
funnel |>
  e_charts(
    height = 800
  ) |>
  e_funnel(
    prev_value, 
    stage, 
    name = "Previous (2024)", 
    width = "80%",
    left = "10%",
    z = 0, 
    top = 150
    ) |>
  e_funnel(
    curr_value,
    stage,
    name = "Current (2025)", 
    width = "55%", 
    left = "22.5%", # might need to fidget with these to get a centered overlap - depending on you values
    z = 1, 
    top = 150
    ) |>

e_color(c(
    "rgba(78, 99, 145, 0.55)", # view
    "rgba(36, 120, 255, 0.55)", # click
    "rgba(254, 178, 56, 0.55)", # add to cart
    "rgba(226, 88, 88, 0.55)" # checkout
  )) |>
  e_labels(
    position = "inside",
    textStyle = list(
      color = "#fff",
      fontWeight = "bold",
      fontSize = 16
      )
    ) |>
  e_tooltip(
    backgroundColor = "rgba(255,255,255,0.80)",
    formatter = htmlwidgets::JS("
      function(p) {
        // JS array of percents matching funnel stages
        const percents = [96, 107, 59, 51];

        let title = 'Black Friday Sales Conversions : 2024 | 2025';
        let subtitle = '<div style=\"margin-left:10px; margin-top:18px; margin-right:8px; color:#333;\">Stage: <b>' + p.name + '</b></div>';

        const colors = [
          'rgba(78, 99, 145, 0.88)',
          'rgba(36, 120, 255, 0.88)',
          'rgba(254, 178, 56, 0.88)',
          'rgba(226, 88, 88, 0.88)'
        ];

        const marker = '<span style=\"display:inline-block;width:10px;height:10px;margin-right:6px;border-radius:2px;background:' 
                       + colors[p.dataIndex] + ';\"></span>';
                       
        // Identifying Current for conditional tooltip using seriesName containing 'Current'
            const isCurrent = p.seriesName && p.seriesName.indexOf('Current') !== -1;
            
        // Get the correct percentage for this row
            const percentValue = percents[p.dataIndex];

        // Tooltip
                if (isCurrent && percentValue < 100) {
            return `
              <div style=\"font-weight:bold; margin-bottom:6px;\">${title}</div>
              ${subtitle}
              <div style=\"margin-left:10px; margin-top:6px; color:#333;\">
                ${marker}${p.seriesName}: <b>${p.value}</b> clicks 
                (<b style=\"color:#d9534f;\">${percentValue}</b>%)
              </div>
            `;
          }
          
          else if (isCurrent && percentValue > 100) {
            return `
              <div style=\"font-weight:bold; margin-bottom:6px;\">${title}</div>
              ${subtitle}
              <div style=\"margin-left:10px; margin-top:6px; color:#333;\">
                ${marker}${p.seriesName}: <b>${p.value}</b> clicks 
                (<b style=\"color:#37ab3c;\">${percentValue}</b>%)
              </div>
            `;
          }
          
          else {
            return `
              <div style=\"font-weight:bold; margin-bottom:6px;\">${title}</div>
              ${subtitle}
              <div style=\"margin-left:10px; margin-top:6px; color:#333;\">
                ${marker}${p.seriesName}: <b>${p.value}</b> clicks
              </div>
            `;
          }
        }
    ")
    ) |>
  e_legend(
    orient = "vertical",
    left = 20,
    bottom = 60
    ) |>
  e_title(
    text ="Overlaid Funnels", 
    textStyle = list(
    color = "#334",
    fontSize = 28,
    fontWeight = "bold",
    fontFamily = "system-ui",
    lineHeight = 32
    ),
    subtext = "Comparing recent figures to a previous promotional sale period for 2024 and 2025",
    subtextStyle = list(
    color = "#888",
    fontSize = 20,
    fontFamily = "system-ui",
    lineHeight = 24
    )
  )
```

&nbsp;  

I'm using **ECharts4r v0.4.6** to make these templates and the `e_funnel()` functions has a few areas that aren't easy to expand in. Where you'd usually add arguments that target a single series, you now must rely on other functions such as `e_labels()` to clean them up, or jump into JavaScript. This does mean you need to be a bit more mindful about your colour palettes and text sizes because moving the text outside produces an unreadable result due to the labels of both charts slightly offset and overlapping.  

&nbsp;  

## 2. Outro  

The `e_funnel()` function currently doesn't have a wide variety of customization past the basic set up. A look at the funnel chart [examples](https://echarts.apache.org/examples/en/index.html#chart-type-funnel) on the ECharts site shows more of the same.  

This particular template had a higher volume of challenges for such a simple chart. Many of them may have been related to how the function was set up, but additional JavaScript was able to overcome some of the limitations.  

If you think something's missing or have a question give me a shout and we can figure it out together.  
