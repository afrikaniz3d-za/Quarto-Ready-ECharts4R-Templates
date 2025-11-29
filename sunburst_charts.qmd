---
title: "Sunburst Charts"
date: 11-29-2025
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

### 1.1 As per CRAN documentation PDF 

Here's the example from the [ECharts4R site](https://cran.r-project.org/web/packages/echarts4r/echarts4r.pdf) pdf documentation. The data used to generate the chart takes the form of a JSON list and follows quite a few steps before being run through the `e_sunburst` function.  

&nbsp;  

```{r}
#| code-fold: true
#| label: basic-sunburst-chart-pdf-documentation
#| fig-width: 5
#| fig-height: 6


suppressPackageStartupMessages({
  library(echarts4r)
  })

# example data
# json list hierarchical data representation
jsonl <- jsonlite::fromJSON('[
{"name": "earth", "value": 30,
"children": [
{"name": "land", "value":10,
"children": [
{"name": "forest", "value": 3},
{"name": "river", "value": 7}
]},
{"name": "ocean", "value":20,
"children": [
{"name": "fish", "value": 10,
"children": [
{"name": "shark", "value":2},
{"name": "tuna", "value":6}
]},
{"name": "kelp", "value": 5}
]}
]
},
{"name": "mars", "value": 30,
"children": [
{"name": "crater", "value": 20},
{"name": "valley", "value": 20}
]},
{"name": "venus", "value": 40, "itemStyle": {"color": "blue"} }
]', simplifyDataFrame = FALSE)

# tibble hierarchical data representation
suppressPackageStartupMessages({
  library(dplyr)
  })
df <- tibble(
name = c("earth", "mars", "venus"),
value = c(30, 40, 30),

# 1st level
itemStyle = tibble(color = c("NA", "red", "blue")),

# embedded styles, optional
children = list(
tibble(
name = c("land", "ocean"),
value = c(10, 20),

# 2nd level
children = list(
tibble(name = c("forest", "river"), value = c(3, 7)),

# 3rd level
tibble(
name = c("fish", "kelp"),
value = c(10, 5),
children = list(
tibble(name = c("shark", "tuna"), value = c(2, 6)),

# 4th level
NULL # kelp
)
)
)
),

tibble(name = c("crater", "valley"), value = c(20, 20)),
NULL # venus
)
)

# use it in echarts4r
df |>
e_charts() |>
e_sunburst() |>
e_theme("westeros")
```  

&nbsp;  

### 1.2 As per ECharts4R documentation site 

Here's the example (with minor adjustments) provided on John Coene's [ECharts4R site](https://echarts4r.john-coene.com/articles/chart_types). It uses the more familiar dataframe structure seen in many of the other template examples in this series. The `FromDataFrameNetwork()` function is used to create the data tree needed to generate the sunburst chart.

&nbsp;  

```{r}
#| code-fold: true
#| label: basic-sunburst-chart-echarts4r-site-2
#| fig-width: 5
#| fig-height: 6

# example data
df <- data.frame(
  parents = c("","earth", "earth", "mars", "mars", "land", "land", "ocean", "ocean", "fish", "fish", "Everything", "Everything", "Everything"),
  labels = c("Everything", "land", "ocean", "valley", "crater", "forest", "river", "kelp", "fish", "shark", "tuna", "venus","earth", "mars"),
  value = c(0, 30, 40, 10, 10, 20, 10, 20, 20, 8, 12, 10, 70, 20)
)

# create a tree object
universe <- data.tree::FromDataFrameNetwork(df)

# use it in echarts4r
universe |> 
  e_charts() |> 
  e_sunburst()
```  

&nbsp;  

### 1.3 Translating from ECharts  

This example depicts unit sales within the Electronic category for an hypothetical retail chain. It mirrors the structure found in the [Sunburst with Rounded Corner](https://echarts.apache.org/examples/en/editor.html?c=sunburst-borderRadius) example, but the table is formatted the same way as the chart from **1.2**.  


```{r}
#| code-fold: true
#| label: sunburst-rounded-corners-donut-hole-1
#| fig-width: 5
#| fig-height: 8

suppressPackageStartupMessages({
  library(echarts4r)
  library(htmltools)
})

df <- data.frame(
  parents = c(
    "", # everything (root)
    "Everything", "Everything", "Everything", # major categories
    "Cleaning", "Cleaning", "Cleaning", "Cleaning", # parents of dishwasher, washing machine, pressure washer, vacuum cleaner
    "Kitchen", "Kitchen", "Kitchen", "Kitchen", "Kitchen", "Kitchen", "Kitchen", # parents of kettle, coffee machine, toaster, ovens, fridges, cookers, food processors
    "Ovens", "Ovens", # children of Ovens
    "Fridges", "Fridges", "Fridges", "Fridges", # children of fridges
    "Cookers", "Cookers", "Cookers", # children of electric cookers
    "Food Processors", "Food Processors", # children of food processors
    "Body Care", "Body Care", "Body Care", "Body Care", "Body Care", "Body Care" # parents of water dispenser, electric toothbrush, electric razor, curling iron, hair dryer, treadmill 
  ),
  labels = c(
    "Everything",
    "Cleaning", "Kitchen", "Body Care",
    "Dishwasher", "Washing Machine", "Pressure Washer", "Vacuum Cleaner",
    "Kettle", "Coffee Machine", "Toaster", "Ovens", "Fridges", "Cookers", "Food Processors",         
    "Microwave", "Electronic Oven", 
    "Fridge", "Minibar Fridge", "Ice Maker", "Chest Freezer",
    "Air Fryer", "Electric Stove", "Gas Cooker",
    "Blender", "Mixer",
    "Water Dispenser", "Electric Toothbrush", "Electric Razor", "Curling Iron", "Hair Dryer", "Treadmill"
  ),
  value = c(
    901083, # everything/all appliances
    143470, 608872, 148741, # summary of the 3 categories       
    43995, 67589, 25990, 5896, # dishwasher, washing machine, pressure washer, Vacuum cleaner
    65478, 84283, 36885, 59487, 182091, 144852, 35807, # kettle, toaster, ovens summary, fridges summary, cookers summary, food processors summary                 
    13495, 45992, # microwave, electric oven
    141688, 7198, 6698, 26496, # fridges - fridge, minibar fridge, ice maker, chest freezer
    22843, 35819, 86190, # cookers - air fryers, electric stove, gas cooker
    8121, 27686, # blender, mixer
    20093, 4473, 23783, 4610, 4790, 90992 # water dispenser, electric toothbrush, electric razor, curling iron, hair dryer, treadmill
  )
)

# creating the tree
appliances <- data.tree::FromDataFrameNetwork(df) 

# defining specific colours for each category
category_colours <- list(
  "Cleaning" = "#A49A87",
  "Kitchen" = "#9D4542",
  "Body Care" = "#114A6B"
  )

# adding a progressive lightening effect to the children in each category 
lighten <- function(color, factor = 0.35) {
  color <- as.character(color)    
  if (!grepl("^#", color)) stop("Color must start with #")
  
  rgb_vals <- col2rgb(color) / 255
  rgb_vals <- rgb_vals + (1 - rgb_vals) * factor
  rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3])
}

# assign colors
appliances$Do(function(node) {
  # top-level categories get explicit colors
  if (node$name %in% names(category_colours)) {
    node$itemStyle <- list(color = category_colours[[node$name]])
  }
  
  # children get lighter shades of parent color
  if (!is.null(node$parent) && !(node$name %in% names(category_colours))) {
    # only proceed if parent has itemStyle and color
    if (!is.null(node$parent$itemStyle) && !is.null(node$parent$itemStyle$color)) {
      parent_col <- as.character(node$parent$itemStyle$color)
      node$itemStyle <- list(color = lighten(parent_col, factor = 0.35))
    }
  }
})


div(
  style = "padding-top: 80px; padding-bottom: 130px;", # additional padding to give the chart more white space to prevent the tooltip clipping
appliances |>
  e_charts() |>
  e_sunburst(
    name = "Appliances",
    confine = TRUE, # smooths the drift of the tooltip so that it doesn't clip the boundaries of the chart and trigger the scroll bars
    colorMappingBy = "id",
    itemStyle = list( # adding a gap between wedges and rounding the corners -- large radii make sausages :D
      borderRadius = 4,
      borderWidth = 3,
      color = "#7D7A89"
      ),
    radius = c("100%", "60%") # reversing these values will give you a conventional-looking sunburst
    ) |>
  e_labels( 
    show = FALSE
    ) |>
  e_tooltip(
    trigger = "item",
    confine = TRUE, # makes the tooltip less jittery/likely to hit the boundary of the chart and trigger the scroll bars
    backgroundColor = "rgba(255,255,255,0.80)",
    textStyle = list(
      color = "#333333"
      ),
    formatter = htmlwidgets::JS("
    function(params) {
      // 1. ANCESTRY PATH (treePathInfo)
      // treePathInfo is an array like:
      // [{name: 'Everything'}, {name: 'Kitchen'}, {name: 'Fridges'}, {name: 'Ice Maker'}]
      
      var path = params.treePathInfo;
      
      // Build breadcrumb title: Appliances → Kitchen → Fridges → Ice Maker
      var breadcrumbs = path.map(function(node) { return node.name; }).join(' &rarr; ');
      
      // Current node name and value
      var currentName = params.name;
      var currentValue = params.value;

      // 2. START HTML: BREADCRUMB TITLE SECTION
      var html = `
        <div style='font-family: sans-serif; padding: 8px;'>
          <div style='font-weight: bold; margin-bottom: 6px; font-size: 13px;'>
            ${breadcrumbs}
          </div>
      `;
      
      // 3. SHOW CURRENT NODE + ITS VALUE
      if (params.data && params.data.children && params.data.children.length  > 0) {
      html += `
        <div style='margin-bottom: 6px; font-size: 12px;'>
          ${currentName} Summary: <b>$ ${currentValue.toLocaleString()}</b>
        </div>
      `;
      }
      
      else  {
      html += `
        <div style='margin-bottom: 6px; font-size: 12px;'>
          ${currentName}: <b>$ ${currentValue.toLocaleString()}</b>
        </div>
      `;
      }
      
      
      // 4. CHILDREN SECTION (only if node has any)
      // If this is an internal node (category), it will have children in params.data.children
      if (params.data && params.data.children && params.data.children.length > 0) {
        
        html += `
          <div style='margin-top: 6px; font-size: 12px;'>
            <b>Includes:</b>
            <ul style='padding-left: 16px; margin: 4px 0;'>
        `;
        
        params.data.children.forEach(function(child) {
          html += `
            <li>${child.name}: <b>$${child.value.toLocaleString()}</b> </li>
          `;
        });
        
        html += `
            </ul>
          </div>
        `;
      }
      
      // 5. CLOSE THE HTML BLOCK
      html += `</div>`;
      
      return html;
    }
  ")
  )
)
```


&nbsp;  

The first thing you notice about the chart is the shape and how the "burst" travels inward. This is achieved by introducing an inner radius to give it a donut chart quality, then making the inner radius larger than than the chart's scale within the `radius` argument of the `e_sunbusrt()` function:  

```html
e_sunburst(
    radius = c("100%", "60%")
    )
```

&nbsp;  

Although it's more like an `e_sunimplosion()` I think this looks better, especially in situations where you're following a strict grid and need a lot of your visual elements to line up.

Here's a more conventional-looking version (inner radius smaller than the chart scale):

```{r}
#| code-fold: true
#| label: sunburst-rounded-corners-donut-hole-2
#| fig-width: 5
#| fig-height: 8

suppressPackageStartupMessages({
  library(echarts4r)
  library(htmltools)
})

df <- data.frame(
  parents = c(
    "", # everything (root)
    "Everything", "Everything", "Everything", # major categories
    "Cleaning", "Cleaning", "Cleaning", "Cleaning", # parents of dishwasher, washing machine, pressure washer, vacuum cleaner
    "Kitchen", "Kitchen", "Kitchen", "Kitchen", "Kitchen", "Kitchen", "Kitchen", # parents of kettle, coffee machine, toaster, ovens, fridges, cookers, food processors
    "Ovens", "Ovens", # children of Ovens
    "Fridges", "Fridges", "Fridges", "Fridges", # children of fridges
    "Cookers", "Cookers", "Cookers", # children of electric cookers
    "Food Processors", "Food Processors", # children of food processors
    "Body Care", "Body Care", "Body Care", "Body Care", "Body Care", "Body Care" # parents of water dispenser, electric toothbrush, electric razor, curling iron, hair dryer, treadmill 
  ),
  labels = c(
    "Everything",
    "Cleaning", "Kitchen", "Body Care",
    "Dishwasher", "Washing Machine", "Pressure Washer", "Vacuum Cleaner",
    "Kettle", "Coffee Machine", "Toaster", "Ovens", "Fridges", "Cookers", "Food Processors",         
    "Microwave", "Electronic Oven", 
    "Fridge", "Minibar Fridge", "Ice Maker", "Chest Freezer",
    "Air Fryer", "Electric Stove", "Gas Cooker",
    "Blender", "Mixer",
    "Water Dispenser", "Electric Toothbrush", "Electric Razor", "Curling Iron", "Hair Dryer", "Treadmill"
  ),
  value = c(
    901083, # everything/all appliances
    143470, 608872, 148741, # summary of the 3 categories       
    43995, 67589, 25990, 5896, # dishwasher, washing machine, pressure washer, Vacuum cleaner
    65478, 84283, 36885, 59487, 182091, 144852, 35807, # kettle, toaster, ovens summary, fridges summary, cookers summary, food processors summary                 
    13495, 45992, # microwave, electric oven
    141688, 7198, 6698, 26496, # fridges - fridge, minibar fridge, ice maker, chest freezer
    22843, 35819, 86190, # cookers - air fryers, electric stove, gas cooker
    8121, 27686, # blender, mixer
    20093, 4473, 23783, 4610, 4790, 90992 # water dispenser, electric toothbrush, electric razor, curling iron, hair dryer, treadmill
  )
)

# creating the tree
appliances <- data.tree::FromDataFrameNetwork(df) 

# defining specific colours for each category
category_colours <- list(
  "Cleaning" = "#A49A87",
  "Kitchen" = "#9D4542",
  "Body Care" = "#114A6B"
  )

# adding a progressive lightening effect to the children in each category 
lighten <- function(color, factor = 0.35) {
  color <- as.character(color)    
  if (!grepl("^#", color)) stop("Color must start with #")
  
  rgb_vals <- col2rgb(color) / 255
  rgb_vals <- rgb_vals + (1 - rgb_vals) * factor
  rgb(rgb_vals[1], rgb_vals[2], rgb_vals[3])
}

# assign colors
appliances$Do(function(node) {
  # top-level categories get explicit colors
  if (node$name %in% names(category_colours)) {
    node$itemStyle <- list(color = category_colours[[node$name]])
  }
  
  # children get lighter shades of parent color
  if (!is.null(node$parent) && !(node$name %in% names(category_colours))) {
    # only proceed if parent has itemStyle and color
    if (!is.null(node$parent$itemStyle) && !is.null(node$parent$itemStyle$color)) {
      parent_col <- as.character(node$parent$itemStyle$color)
      node$itemStyle <- list(color = lighten(parent_col, factor = 0.35))
    }
  }
})


div(
  style = "padding-top: 80px; padding-bottom: 130px;", # additional padding to give the chart more white space to prevent the tooltip clipping
appliances |>
  e_charts() |>
  e_sunburst(
    name = "Appliances",
    confine = TRUE, # smooths the drift of the tooltip so that it doesn't clip the boundaries of the chart and trigger the scroll bars
    colorMappingBy = "id",
    itemStyle = list( # adding a gap between wedges and rounding the corners -- large radii make sausages :D
      borderRadius = 4,
      borderWidth = 3,
      color = "#7D7A89"
      ),
    radius = c("50%", "100%") # reversing these values will give you a conventional-looking sunburst
    ) |>
  e_labels( 
    show = FALSE
    ) |>
  e_tooltip(
    trigger = "item",
    confine = TRUE, # makes the tooltip less jittery/likely to hit the boundary of the chart and trigger the scroll bars
    backgroundColor = "rgba(255,255,255,0.80)",
    textStyle = list(
      color = "#333333"
      ),
    formatter = htmlwidgets::JS("
    function(params) {
      // 1. ANCESTRY PATH (treePathInfo)
      // treePathInfo is an array like:
      // [{name: 'Everything'}, {name: 'Kitchen'}, {name: 'Fridges'}, {name: 'Ice Maker'}]
      
      var path = params.treePathInfo;
      
      // Build breadcrumb title: Appliances → Kitchen → Fridges → Ice Maker
      var breadcrumbs = path.map(function(node) { return node.name; }).join(' &rarr; ');
      
      // Current node name and value
      var currentName = params.name;
      var currentValue = params.value;

      // 2. START HTML: BREADCRUMB TITLE SECTION
      var html = `
        <div style='font-family: sans-serif; padding: 8px;'>
          <div style='font-weight: bold; margin-bottom: 6px; font-size: 13px;'>
            ${breadcrumbs}
          </div>
      `;
      
      // 3. SHOW CURRENT NODE + ITS VALUE
      if (params.data && params.data.children && params.data.children.length  > 0) {
      html += `
        <div style='margin-bottom: 6px; font-size: 12px;'>
          ${currentName} Summary: <b>$ ${currentValue.toLocaleString()}</b>
        </div>
      `;
      }
      
      else  {
      html += `
        <div style='margin-bottom: 6px; font-size: 12px;'>
          ${currentName}: <b>$ ${currentValue.toLocaleString()}</b>
        </div>
      `;
      }
      
      
      // 4. CHILDREN SECTION (only if node has any)
      // If this is an internal node (category), it will have children in params.data.children
      if (params.data && params.data.children && params.data.children.length > 0) {
        
        html += `
          <div style='margin-top: 6px; font-size: 12px;'>
            <b>Includes:</b>
            <ul style='padding-left: 16px; margin: 4px 0;'>
        `;
        
        params.data.children.forEach(function(child) {
          html += `
            <li>${child.name}: <b>$${child.value.toLocaleString()}</b> </li>
          `;
        });
        
        html += `
            </ul>
          </div>
        `;
      }
      
      // 5. CLOSE THE HTML BLOCK
      html += `</div>`;
      
      return html;
    }
  ")
  )
)
```

&nbsp;  

You'll see in the code that I commented in the relationships to the other two columns to make it easier for those who aren't familiar with setting up tree structures at first - I ***struggled*** at the start. 

## 2. Outro  

The sunburst chart is a fun and compact way to visualise hierarchical data. The interactivity makes it a great tool to get the audience engaging with the data, and it's a must-use wherever appropriate.

If you think something's missing or have a question give me a shout and we can figure it out together.  
