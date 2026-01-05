---
title: "Bar Chart with Conditional Formatting"
subtitle: "Rendering elements that meets certain conditions differently in order to highlight them"
date: 09-29-2025
author: Ntobeko Sosibo
toc: true
toc-location: left
toc-title: "Outline"
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
## 1. Setting up a basic Bar Chart  

Here's a basic bar chart. The `y-axis` is hidden and the values are placed at the top of the bars for easier readability. The code is relatively straightforward, and I've hinted in places how you can modify things like text size and formatting.  


```{r}
#| code-fold: true
#| label: regular-bar-chart
#| fig-width: 12
#| fig-height: 12  

suppressPackageStartupMessages(library(echarts4r)) # the suppress prefix is just for a cleaner presentation
suppressPackageStartupMessages(library(dplyr))


df <- tibble(
  day = c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"),
  value = c(120,20,150,180,70,310,130)
  )

df |>
  e_charts(day) |>
  e_bar(value,
        name = "Impressions",
        itemStyle = list(
          color = "#999999"
        )) |>
  
  e_y_axis(
    show = FALSE # you can change this to TRUE if you prefer using tooltips or having no values on/in the bars
  ) |>
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
  
  e_title(
    "Saturday was a Great Day for Impressions", # title
    "Regular Bar Chart with no conditional formatting." #sub-title
  ) |>
  e_legend(
    top = "25%",
    left = "10%") |>
  e_labels(
    fontSize = 16,
    fontWeight = "bold") |>
  e_grid(
    bottom = "80",  
    left = "10%",    
    right = "5%",
    top = "20%"
  )
```
  
&nbsp;  

## 2. Bar Chart with Conditional Formatting  

  
```{r}
#| code-fold: true
#| label: conditional-formatting
#| fig-width: 12
#| fig-height: 6

suppressPackageStartupMessages(library(echarts4r)) # the suppress prefix is just for a cleaner presentation
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(tidyr))

df <- tibble(
  day = c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"),
  value = c(120,20,150,180,70,310,130)
  ) |>
  
# Creating a column for defining which of the three thresholds the values fall into
  mutate( 
    colour_group = case_when(
      value < 100  ~ "Low",
      value == max(value) ~ "Max",
      TRUE         ~ "Normal"
      )
    )

# Converting to wide format: one series per color_group
df_wide <- df |>
  pivot_wider(
    names_from = colour_group, 
    values_from = value
  )

df_wide |>
  e_charts(day,
           top = 60) |>
  e_y_axis(
    show = FALSE
  ) |>
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
  e_bar(Low,   
        name = "Investigate (Below 100)",    
        barGap = "-100%", # this ensures that the bar takes up the full width of it's day cell. without this argument it would leave space for the other two thresholds
        itemStyle = list(color = "#d62728"),
        top = "20%") |>
  e_bar(Normal,
        name = "Normal (Expected Output)", 
        barGap = "-100%", 
        itemStyle = list(color = "#b9b5b5"),
        top = "20%") |>
  e_bar(Max,   
        name = "Outstanding (Highest Value)",    
        barGap = "-100%", 
        itemStyle = list(color = "#91cc75"),
        top = "20%") |>
  
  e_title(
   "Saturday was a Great Day for Impressions this Week",
    "Bar chart with conditional formatting depicting daily impression counts. Three thresholds were defined and colours are automatically assigned depending on the #value."
  ) |>
  e_legend(
    top = "15%"
  ) |>
  e_labels(
    fontSize = 16,
    fontWeight = "bold") |>
  e_grid( # Massage these values if you're running out of space around your chart
    bottom = "80",  
    left = "10%",    
    right = "5%",
    top = "30%"
  )

```
  
&nbsp;  

What's nice about adding the conditional formatting is that it quickly draws your attention to elements that answer questions. The way it was done in this particular example was by defining a separate `e_bar()` for each condition.  

Here, I defined three tiers:  

  - **Investigate** (Below 100)  
  - **Normal** (Expected Output)  
  - **Outstanding** (The Highest Value)  
  
A new column, `colour_group`, was generated using `mutate()` and then the table was pivoted to create individual streams for each tier. Each tier was then plotted using its own `e_bar()` where I could also customise the name of the tier for the legend.  

The `barGap()` argument in each `e_bar()` was necessary because each day cell would draw narrower bars in order to fit all three tiers (removed the argument and run it again to see for yourself). You could also use the `stack =` argument to achieve the same effect by giving them all the same stack name, but I think that better serve a situation where you'd actually be creating a stacked bar chart.  

&nbsp;  

## 3. Outro  

I will add to this document as I work more with these charts and learn new things. If you think something's missing or have a question give me a shout and we can figure it out together.  

 

