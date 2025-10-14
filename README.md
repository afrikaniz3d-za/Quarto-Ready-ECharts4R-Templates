# Quarto-Ready-ECharts4R-Templates

## 0. Background  
I've been really getting into using `echarts4r` to generate interactive charts and putting them into my **Quarto** reports, but also had a hard time making sense of of some of the instruction in the [documentation](https://cran.r-project.org/web/packages/echarts4r/echarts4r.pdf).  

On top of that there's the matter that not all charts are documented, with suggestion usually being to visit the **ECharts** [website](https://echarts.apache.org/examples/en/index.html) and work your magic on the the JS code to work in R/RStudio. Admittedly, I'm no pro, so it's taken some time and many conversations with **Chat-GPT** to break elements down and build up an understanding of how to not only make charts in **RStudio**, but to also have them be Quarto-friendly.  

I'll be filling this repository with templates based on some charts I like - and some that I've needed - and I hope these can also be usefult to you in any way.  

ECharts is such a great library, and I'm enjoying learning the tools and the languages throughout the process.  

If you find anything that you think would do the job better or more efficiently please don't hesitate to get in touch.  
Ntobeko  

# Latest Addittion: Calendar Charts  

![][1]  

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


[1]: /images/20251013.gif
