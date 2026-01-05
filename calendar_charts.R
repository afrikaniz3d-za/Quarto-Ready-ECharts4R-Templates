---
title: "Calendar Charts"
subtitle: "Creating multiple charts linked, and reacting, to the same dataset"
date: 10-10-2025
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
## 1. Single Month Chart  

### 1.1 Out-of-the-box (As per documentation)  

```{r}
#| code-fold: true
#| label: calendar-month-per-documentation
#| fig-width: 1
#| fig-height: 1
#| echo: false


suppressPackageStartupMessages({
  library(echarts4r)
  library(dplyr)
})

dates <- seq.Date(
  as.Date("2025-01-01"), 
  as.Date("2025-01-31"), 
  by = "day")
values <- rnorm(
  length(dates), 
  20,
  6)

month <- data.frame(
  date = dates, 
  values = values)

month |> 
  e_charts(
    date) |> 
  e_calendar(
    top = "middle",
    left = "center",
    range = "2025-01",
    cellSize = 60,
    yearLabel = list(
      margin = 65
      )
    ) |> 
  e_heatmap(
    values, 
    coord_system = "calendar"
    ) |> 
  e_visual_map(
    max = 30,
    right = "25%",
    top = "50%"
    )
  
```
&nbsp;  

This is made using the code from the documentation, with a few adjustments like `cellSize` and positioning for layout and consistency with the next example.  

&nbsp;  

### 1.2 With added detail    

```{r}
#| code-fold: true
#| label: calendar-month-with-detail
#| fig-width: 4
#| fig-height: 4
#| echo: false

{
suppressPackageStartupMessages({
  library(echarts4r)
  library(dplyr)
  library(htmlwidgets)
  library(htmltools)
})


  set.seed(2)
  df <- data.frame(
    date = seq(as.Date("2025-01-01"), as.Date("2025-01-31"), by = "day"),
    value = runif(31, 10, 100)
  )

  make_cal <- function(start, end) {
    df |>
      filter(date >= as.Date(start) & date <= as.Date(end)) |>
      e_charts(
        date) |>
      e_calendar(
        top = "middle",
        left = "25%",
        range = c(start, end), 
        cellSize = 60, 
        orient = "vertical",
        yearLabel = list(
          margin = 65,
          fontSize = 20
        ),
        monthLabel = list(
          margin = 25,
          fontSize = 18,
          color = "#999"
          ),
        dayLabel = list(
          color = "#999"
        )
        ) |>
      e_heatmap(
        value, 
        coord_system = "calendar"
        ) |>
      e_visual_map(
        type = "piecewise",
        min = 0, 
        max = 100,
        right = "25%",
        top = "50%"
        ) |>
      e_scatter(
        value,
        coord_system = "calendar",
        label = list(
          show = TRUE,
          formatter = htmlwidgets::JS("
                                      function(params){ return echarts.format.formatTime('dd', params.value[0]);                                          }"),
          fontSize = 13
        ),
        symbol_size = 0
      ) |>
      e_tooltip(
        trigger = "item"
        ) |>
      e_legend(
        show = FALSE)

      }

  p1 <- make_cal("2025-01-01", "2025-01-31")

  browsable(p1)
}

```  

&nbsp;  

The [Lunar Calendar](https://echarts.apache.org/examples/en/editor.html?c=calendar-lunar) example is a nice example of a more conventional calendar in terms of orientation and contents - particularly the day numbers. To achieve this effect the `htmlwidgets` package is loaded to use the JavaScript `formatter` argument, and `e_scatter()` to distribute them in the cells. The `e_tooltip()` function is also used to show the values of highlighted cells at the cursor rather than looking to the `visual_map()` to the side.  


&nbsp;  

## 2. Calender Year  

### 2.1 Out-of-the-box (As per documentation)  

```{r}
#| code-fold: true
#| label: calendar-year-original
#| fig-width: 12
#| fig-height: 6

suppressPackageStartupMessages({
  library(echarts4r)
  library(dplyr)
  library(htmlwidgets)
})

dates <- seq.Date(as.Date("2025-01-01"), as.Date("2025-12-31"), by = "day")
values <- rnorm(length(dates), 20, 6)
year <- data.frame(date = dates, values = values)

year |>
  e_charts(
    date,
    height = 220) |>
  e_calendar(
    range = "2025",
    left = 160) |>
  e_visual_map(
    max = 30,
    top = 50) |>
  e_heatmap(
    values, 
    coord_system = "calendar")

```  

&nbsp;  

A quick note: I did add things like `height =` in the `e_charts()` function because there was a huge empty gap below the chart. This is apparently due to the charts being html widgets, so they end up ignoring the code chunk's specification in `fig-width/height`.  

&nbsp;  

### 2.2 Range (As per documentation)  

```{r}
#| code-fold: true
#| label: calendar-range
#| fig-width: 12
#| fig-height: 2

suppressPackageStartupMessages({
  library(echarts4r)
  library(dplyr)
  library(htmlwidgets)
})

dates <- seq.Date(as.Date("2025-01-01"), as.Date("2025-12-31"), by = "day")
values <- rnorm(length(dates), 20, 6)
year <- data.frame(date = dates, values = values)

year |>
  e_charts(
    date,
    height = 220) |>
  e_calendar(
    range = c("2025-01-01", "2025-7-31"),
    left = 160,
    top = 50,
    bottom = 20,
    cellSize = c(20, 20)
  ) |>
  e_visual_map(
    max = 30,
    top = 50
  ) |>
  e_heatmap(values, coord_system = "calendar")

```  

&nbsp;  


&nbsp;  

### 2.3 Multiple years (As per documentation)  

```{r}
#| code-fold: true
#| label: calendar-heatmap-multiple-years
#| fig-width: 12
#| fig-height: 6

suppressPackageStartupMessages({
  library(echarts4r)
  library(dplyr)
  library(htmlwidgets)
})

dates <- seq.Date(as.Date("2024-01-01"), as.Date("2025-12-31"), by = "day")
values <- rnorm(length(dates), 20, 6)
year <- data.frame(date = dates, values = values)

year |>
dplyr::mutate(
  year = format(date, "%Y")) |>
group_by(year) |>
e_charts(date) |>
e_calendar(
  range = "2024", 
  top = 40,
  left = 160) |>
e_calendar(
  range = "2025", 
  top = 260, 
  left = 160) |>
e_heatmap(
  values, 
  coord_system = "calendar") |>
e_visual_map(
  max = 30,
  top = 250)

```  

&nbsp;  


  
### 2.4 Including day numbers, changing orientation and using more CSS for layout  

```{r}
#| code-fold: true
#| label: calendar-year
#| fig-width: 4
#| fig-height: 2
#| echo: false

{
suppressPackageStartupMessages({
  library(echarts4r)
  library(dplyr)
  library(htmlwidgets)
  library(htmltools)
})


  set.seed(1)
  df <- data.frame(
    date = seq(as.Date("2025-01-01"), as.Date("2025-12-31"), by = "day"),
    value = runif(365, 10, 100)
  )

  make_cal <- function(start, end) {
    df |>
      filter(date >= as.Date(start) & date <= as.Date(end)) |>
      e_charts(
        date) |>
      e_calendar(
        range = c(start, end), 
        cellSize = 30, 
        orient = "horizontal",
        yearLabel = list(
          show = FALSE
        )
        ) |>
      e_heatmap(
        value, 
        coord_system = "calendar"
        ) |>
      e_visual_map(
        min = 0, 
        max = 100,
        show = FALSE) |>
      e_scatter(
        value,
        coord_system = "calendar",
        label = list(
          show = TRUE,
          formatter = htmlwidgets::JS("
                                      function(params){ return echarts.format.formatTime('dd', params.value[0]);                                          }"),
          fontSize = 10
        ),
        symbol_size = 0
      ) |>
      e_tooltip(
        trigger = "item"
        ) |>
      e_legend(
        show = FALSE
        ) |>
      e_grid(
        top = 10,
        bottom = -50,
        left = 10,
        right = 10
        )

      }

  p1 <- make_cal("2025-01-01", "2025-01-31")
  p2 <- make_cal("2025-02-01", "2025-02-28")
  p3 <- make_cal("2025-03-01", "2025-03-31")
  p4 <- make_cal("2025-04-01", "2025-04-30")
  p5 <- make_cal("2025-05-01", "2025-05-31")
  p6 <- make_cal("2025-06-01", "2025-06-30")
  p7 <- make_cal("2025-07-01", "2025-07-31")
  p8 <- make_cal("2025-08-01", "2025-08-31")
  p9 <- make_cal("2025-09-01", "2025-09-30")
  p10 <- make_cal("2025-10-01", "2025-10-31")
  p11 <- make_cal("2025-11-01", "2025-11-30")
  p12 <- make_cal("2025-12-01", "2025-12-31")
  

  out <- div(
    style = "
      display: flex;
      flex-direction: column;
      gap: 0px;
      height: 900px;
      width: 100%;

    
  ",

  # Row 1 (Jan–Apr)
  div(
    style = "
      display: flex;
      flex-wrap: wrap;
      justify-content: space-between;
      gap: 1px;
      width: 100%;
      height: 600px;
      margin-bottom: -220px;

    ",
    div(style = "flex: 1; min-width: 250px;", p1),
    div(style = "flex: 1; min-width: 250px;", p2),
    div(style = "flex: 1; min-width: 250px;", p3),
    div(style = "flex: 1; min-width: 250px;", p4)
  ),

  # Row 2 (May–Aug)
  div(
    style = "
      display: flex;
      flex-wrap: wrap;
      justify-content: space-between;
      gap: 1px;
      width: 100%;
      height: 900px;
      margin-bottom: -220px; 
    ",
    div(style = "flex: 1; min-width: 250px;", p5),
    div(style = "flex: 1; min-width: 250px;", p6),
    div(style = "flex: 1; min-width: 250px;", p7),
    div(style = "flex: 1; min-width: 250px;", p8)
  ),

  # Row 3 (Sep–Dec)
  div(
    style = "
      display: flex;
      flex-wrap: wrap;
      justify-content: space-between;
      gap: 1px;
      width: 100%;
      height: 1100px;
      margin-bottom: -220px; 
    ",
    div(style = "flex: 1; min-width: 250px;", p9),
    div(style = "flex: 1; min-width: 250px;", p10),
    div(style = "flex: 1; min-width: 250px;", p11),
    div(style = "flex: 1; min-width: 250px;", p12)
  )
)

out

  browsable(out)
}

```  

&nbsp;  

This is an extension of the single month, with each month being a standalone segment, rather than a band. I prefer it this way because it's still a relatively familiar format and a little easier to navigate.  

Each month has been rotated using `orient = "horizontal"` so that it's a clean and consistent row. Some months (looking at you, March..) have six weeks, so it ends up looking *mubi* if all the months maintain the `orient = "vertical"` used for a single month chart.  

The idea behind how the CSS is used in this example was in anticipation for things like dashboards or presentations focused on events visually tracked throughout the year.  

Had a lot of trouble trying to trim off the extra blank space at the bottom of the container. Will address it as I learn more.


&nbsp;  

## 3. Outro  

The examples above are a small sample of the different ways calendars are visualised using ECharts. 

If you think something's missing or have a question give me a shout and we can figure it out together.  

