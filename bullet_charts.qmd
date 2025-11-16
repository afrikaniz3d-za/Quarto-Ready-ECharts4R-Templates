---
title: "Bullet Charts"
date: 11-16-2025
author: Ntobeko Sosibo
toc: true
toc-location: left
toc-title: "Contents"
toc-depth: 6
format: 
  html:
    grid: 
      body-width: 1200px
    include-in-header: 
      text: <link rel="icon" type="/images/png" href="images/echarts4r_logo.png">
    page-layout: full
    embed-resources: true
    self-contained: true
---
## 1. Looking for an ECharts example  

The closest (looking) example I could find on the [ECharts](https://echarts.apache.org/examples/) to a bullet chart was the [Bar Background](https://echarts.apache.org/examples/en/editor.html?c=bar-background) example. It uses visual formatting unrelated to the data, and that gave me an idea about how I could approach making them with existing tools in ECharts4r.  

&nbsp;  

## 2. Creating bullet charts with ECharts4R  

The first two examples below are of a **basic**/**simple** bullet chart, a vertical and an horizontal version, that outline my approach to creating the common form with ECharts4R. Each chart is comprises:

  - a coloured (navy) JS shape to represent the value  
  - a target marker using a `markPoint =` argument  
  - a wider `e_bar()` in the background to represent `previous` values for comparison  
  -
  
It's really hard, with **echarts4r**, to accomplish certain things without using javascript (JS) - because ECharts is effectively 100% JS. That said, I do try to keep JS use to a minimum because it is a skill-set I don't adequately possess (yet), so that also means not assuming anyone else looking at these templates has any kind of working knowledge of JS too.  

With the templates provided in this document, however, I did decide to embrace JS where it was suggested because it did provide the cleanest and most accurate solution (and the most control) when compared to the many echarts4r-based workarounds I tried. There are certain elements/behaviours in echarts4r, like the shifting of the axis line when using `e_bar()`'s of varying widths that resulted in *janky*-looking solutions, that made it an easy choice to take the JS route.  

In the end, the result presents the data in a clean and familiar format, and I think that's an important justification.


### 2.1 Type 1: Slimmer Bar using JavaScript  

#### 2.1.1 Horizontal configuration  

```{r}
#| code-fold: true
#| label: type-1-horizontal-bullet-chart
#| fig-width: 5
#| fig-height: 6


suppressPackageStartupMessages({
  library(dplyr)
  library(echarts4r)
  library(jsonlite)
  library(htmlwidgets)
  library(htmltools)
})

# example data
df <- data.frame(
  category = c("Sunglasses", "Watches", "Belts", "Socks"),
  current_measure = c(750, 658, 802, 620),
  target = c(700, 650, 960, 600),
  previous_measure = c(655, 557, 690, 590),
  previous_target = c(658, 554, 670, 550)
  
) |>
  mutate(
    cat_index = seq_along(category) - 1 # needed for JS indexing
  )

# preparing data for JS (current measure bar)
custom_data <- lapply(seq_len(nrow(df)), function(i) {
  list(df$cat_index[i], df$current_measure[i], df$current_measure[i])
})
custom_data_json <- toJSON(custom_data, auto_unbox = TRUE)

# base chart
base_chart <- df |>
  e_charts(
    category,
    height = 750) |>
  e_bar(
    previous_measure,
    name = "Previous",
    barWidth = 80,
    barGap = "-100%",
    z = 0,
    itemStyle = list(
      color = "rgba(128, 128, 128, 0.4)"),
    markPoint = list(
      symbol = "rect",
      tooltip = list(
        show = FALSE
        ),
    symbolSize = c(6, 80),
      itemStyle = list(
      color = "rgba(128,128,128,1.0)"
      ),
      data = lapply(1:nrow(df), function(i) list(
        xAxis = df$previous_target[i],
        yAxis = df$category[i]
        )
      )
    )
  ) |>
  e_scatter(
    previous_target,
    name = "Previous Target",
    markPoint = list(
      symbol = "rect",
      symbolSize = c(6, 80),   # width and height (slim vertical bar)
      symbolOffset = c(0, 0),
      itemStyle = list(
        color = "rgba(128, 128, 128, 0.4)"),  # target color
      z = 0,
      data = lapply(
        1:nrow(df),
        function(i) list(
          xAxis = df$prevous_target[i],
          yAxis = df$category[i]
          )
        )
      ),
    ) |>
  
    e_scatter(
    current_measure,
    name = "Current",
    itemStyle = list(
      opacity = 0),
    symbolSize = 0
    ) |>
  
  e_scatter(
    target,
    name = "Target",
    markPoint = list(
      symbol = "rect",
      tooltip = list(
        show = FALSE
        ),                                 
      symbolSize = c(6, 35), # width and height of the target value marker
      symbolOffset = c(0, 0),
      itemStyle = list(
        color = "#f07532"), # colour of the target value marker
      z = 0,
      data = lapply(
        1:nrow(df),
        function(i) list(
          xAxis = df$target[i],
          yAxis = df$category[i]
          )
        )
      ),
    z = 0
    ) |>
# seen as the y-axis in this example because of e-flipped_coords()
    e_x_axis(             
    show = TRUE,
    axisLabel = list(
      margin = 20,
      fontSize = 16,
      fontWeight = "bold"
      ),
    axisLine = list(
      show = FALSE
      ),
    axisTick = list(
      show = FALSE
      )
    ) |>
# seen as the 4-axis in this example because of e-flipped_coords()
    e_y_axis(            
    show = TRUE,
    axisLabel = list(
      margin = 20,
      fontSize = 16,
      fontWeight = "bold"
      ),
    axisLine = list(
      show = FALSE
      ),
    axisTick = list(
      show = FALSE
      )
  ) |>
  e_legend(
    show = FALSE
  ) |>
  e_tooltip(
    trigger = "axis",
    axisPointer = list(
      type = "line", 
      axis = "y" 
      ),
    formatter = htmlwidgets::JS("
  function(params) {
    if (!Array.isArray(params)) return;

    let title = 'Mens Clothing & Accessory Sales';
    let subtitle = 'Category: ' + (params[0]?.name || '-');

    // Header
    let tooltip = '<div style=\"margin-bottom:6px; font-weight:bold; color:#333;\">' + title + '</div>';
    tooltip += '<div style=\"margin-bottom:10px; color:#777;\">' + subtitle + '</div>';

    // Define consistent marker colours (to match your chart styling)
    const colors = {
      'Current': 'rgba(19,46,87,1.0)',          // navy
      'Target': '#f07532',                      // orange
      'Previous': 'rgba(128, 128, 128, 0.4)',      // grey
      'Previous Target': 'rgba(128,128,128,1.0)' // darker grey
    };

    // Helper to create a little coloured marker square
    const marker = (color) => 
      '<span style=\"display:inline-block;width:10px;height:10px;margin-right:6px;border-radius:2px;background:' + color + ';\"></span>';

    // Extracting all series values
    let values = {};
    params.forEach(p => {
      values[p.seriesName] = Array.isArray(p.value) ? p.value[0] : p.value;
    });

    // Add series lines (with marker and units)
    tooltip += '<div style=\"margin:5px 0;\">' + marker(colors['Current']) +
                 ' <span style=\"color:#666;\">Current Sales:</span> ' +
                 '<b>' + (values['Current'] ?? '-') + '</b> units' +
               '</div>';
    tooltip += '<div style=\"margin:5px 0;\">' + marker(colors['Target']) +
                 ' <span style=\"color:#666;\">Target:</span> ' +
                 '<b>' + (values['Target'] ?? '-') + '</b> units' +
               '</div>';
    tooltip += '<div style=\"margin:5px 0;\">' + marker(colors['Previous']) +
                 ' <span style=\"color:#666;\">Previous Sales:</span> ' +
                 '<b>' + (values['Previous'] ?? '-') + '</b> units' +
               '</div>';
    tooltip += '<div style=\"margin:5px 0;\">' + marker(colors['Previous Target']) +
                 ' <span style=\"color:#666;\">Previous Target:</span> ' +
                 '<b>' + (values['Previous Target'] ?? '-') + '</b> units' +
               '</div>';

    return tooltip;
  }
")


    ) |>
  e_title(
    "Belts are Slackening",
    "Although the category sold the most usits and surpassed its previous target the furthest, a closer look is needed to understand why the recent target wasn't met."
  ) |>
  e_flip_coords() |>
  e_grid( 
  top = 100
  ) 
# creating the slim JS bar
js <- sprintf("
function(el, x) {
  const chart = echarts.getInstanceByDom(el);
  const data = %s;

  // BAR CONFIGURATION AREA
  const settings = {
    baseValue: 0,                         // data value baseline (where the bar starts)
    offsetX: 0,                           // move horizontally (pixels)
    offsetY: 0,                           // move vertically (pixels)
    barHeight: 35,                        // thickness of custom bar
    fill: 'rgba(19,46,87,1.0)',           // navy fill and stroke
    stroke: 'rgba(19,46,87,1.0)',
    strokeWidth: 1,
    dash: [0, 0],                         // dashed outline
    zLevel: 2                             // this value ensures the current bar sits above the previous value bar
  };
  // -----------------------------

  const customSeries = {
    type: 'custom',
    name: 'Current',                      // the name to appear in the legend and tooltip
    tooltip: { show: true },
    renderItem: function(params, api) {
      const catIdx = api.value(0);
      const val = api.value(1);           // this is where you're selecting which column you're pulling values from

      // Getting pixel coords for base & end
      const baseCoord = api.coord([settings.baseValue, catIdx]);
      const endCoord  = api.coord([val, catIdx]);
      if (!baseCoord || !endCoord) return;

      const rect = {
        x: baseCoord[0] + settings.offsetX,
        y: endCoord[1] + settings.offsetY - settings.barHeight / 2,
        width: endCoord[0] - baseCoord[0],
        height: settings.barHeight
      };

      return {
        type: 'rect',
        shape: rect,
        style: api.style({
          fill: settings.fill,
          stroke: settings.stroke,
          lineWidth: settings.strokeWidth,
          lineDash: settings.dash
        }),
        data: [catIdx, val]
      };
    },
    data: data,
    silent: false,
    z: settings.zLevel
  };

  const opt = chart.getOption();
  opt.series = opt.series || [];
  opt.series.push(customSeries);
  chart.setOption(opt, false);
}
", custom_data_json)

# attaching slim JS bar to chart
final_chart <- onRender(base_chart, js)

final_chart

```  

&nbsp;  

The trick with getting this JS-heavier option to work is using simpler "*invisible*" dummy series that feed the necessary data into the tooltip. Because the `Current` column is fully built using JS, I needed to create an invisible placeholder with an `e_scatter` that would allow the tooltip's `formatter` to get those values. This method opens up many opportunities to create really customised visualizations without worrying about figuring out how you'll need to connect the pieces - that's being taken care of by the simpler, invisible placeholders.

&nbsp;  

#### 2.1.2 Vertical configuration  

```{r}
#| code-fold: true
#| label: type-1-vertical-bullet-chart
#| fig-width: 5
#| fig-height: 6


suppressPackageStartupMessages({
  library(dplyr)
  library(echarts4r)
  library(jsonlite)
  library(htmlwidgets)
  library(htmltools)
})

# example data
df <- data.frame(
  category = c("Sunglasses", "Watches", "Belts", "Socks"),
  current_measure = c(750, 658, 802, 620),
  target = c(700, 650, 960, 600),
  previous_measure = c(655, 557, 690, 590),
  previous_target = c(658, 554, 670, 550)
  
) |>
  mutate(
    cat_index = seq_along(category) - 1 # needed for JS indexing
  )

# preparing data for JS (current measure bar)
custom_data <- lapply(seq_len(nrow(df)), function(i) {
  list(df$cat_index[i], df$current_measure[i], df$current_measure[i])
})
custom_data_json <- toJSON(custom_data, auto_unbox = TRUE)

# base chart
base_chart <- df |>
  e_charts(
    category,
    height = 750) |>
  e_bar(
    previous_measure,
    name = "Previous",
    barWidth = 80,
    barGap = "-100%",
    z = 0,
    itemStyle = list(
      color = "rgba(128, 128, 128, 0.4)"),
    markPoint = list(
      symbol = "rect",
      show = FALSE,
      tooltip = list(
        show = FALSE
        ),
    symbolSize = c(80, 6),
      itemStyle = list(
      color = "rgba(128,128,128,1.0)"
      ),
      data = lapply(1:nrow(df), function(i) list(
        yAxis = df$previous_target[i],
        xAxis = df$category[i]
        )
      )
    )
  ) |>
   
  e_scatter(
    previous_target,
    name = "Previous Target",
    markPoint = list(
      symbol = "rect", # shape of the target marker
      symbolSize = c(80, 6), # width and height (slim vertical bar)
      symbolOffset = c(0, 0),
      itemStyle = list(
        color = "rgba(128, 128, 128, 0.4)" # target color
        ),                
      z = 0,
      data = lapply(
        1:nrow(df),
        function(i) list(
          yAxis = df$prevous_target[i],
          xAxis = df$category[i]
          )
        )
      ),
    ) |>

# placeholder for the target average waiting time value for the tooltip
  e_scatter(
    target,
    name = "Target",
    markPoint = list(
      symbol = "rect",
      tooltip = list(
        show = FALSE
        ),                                 
      symbolSize = c(35, 6),  # width and height of the target value marker
      symbolOffset = c(0, 0),
      itemStyle = list(
        color = "#f07532"),  # colour of the target value marker
      z = 0,
      data = lapply(
        1:nrow(df),
        function(i) list(
          yAxis = df$target[i],
          xAxis = df$category[i]
          )
        )
      ),
    z = 0
    ) |>
# seen as the y-axis in this example because of e-flipped_coords()
    e_x_axis(   
    show = TRUE,
    axisLabel = list(
      margin = 30,
      fontSize = 16,
      fontWeight = "bold"
      ),
    axisLine = list(
      show = FALSE
      ),
    axisTick = list(
      show = FALSE
      )
    ) |>
# seen as the x-axis in this example because of e-flipped_coords()  
    e_y_axis(  
    show = TRUE,
    axisLabel = list(
      margin = 20,
      fontSize = 16,
      fontWeight = "bold"
      ),
    axisLine = list(
      show = FALSE
      ),
    axisTick = list(
      show = FALSE
      )
  ) |>
  e_legend(
    show = FALSE
  ) |>
  e_tooltip(
    trigger = "axis",
    axisPointer = list(
      type = "line", 
      axis = "x" 
      ),
    formatter = htmlwidgets::JS("
  function(params) {
    if (!Array.isArray(params)) return;

    let title = 'Mens Clothing & Accessory Sales';
    let subtitle = 'Category: ' + (params[0]?.name || '-');

    // Tooltip header
    let tooltip = '<div style=\"margin-bottom:6px; font-weight:bold; color:#333;\">' + title + '</div>';
    tooltip += '<div style=\"margin-bottom:10px; color:#777;\">' + subtitle + '</div>';

    // Defining consistent marker colours to match chart styling
    const colors = {
      'Current': 'rgba(19,46,87,1.0)',            // navy
      'Target': '#f07532',                        // orange
      'Previous': 'rgba(128, 128, 128, 0.4)',     // grey
      'Previous Target': 'rgba(128,128,128,1.0)'  // darker grey
    };

    // Helper to create a little coloured marker square
    const marker = (color) => 
      '<span style=\"display:inline-block;width:10px;height:10px;margin-right:6px;border-radius:2px;background:' + color + ';\"></span>';

    // Extracting all series values
    let values = {};
    params.forEach(p => {
      values[p.seriesName] = Array.isArray(p.value) ? p.value[1] : p.value; // p.value[] needs to be 1 in the vertical version
    });

    // Adding series lines (with marker and units)
    tooltip += '<div style=\"margin:5px 0;\">' + marker(colors['Current']) +
                 ' <span style=\"color:#666;\">Current Sales:</span> ' +
                 '<b>' + (values['Current'] ?? '-') + '</b> units' +
               '</div>';
    tooltip += '<div style=\"margin:5px 0;\">' + marker(colors['Target']) +
                 ' <span style=\"color:#666;\">Target:</span> ' +
                 '<b>' + (values['Target'] ?? '-') + '</b> units' +
               '</div>';
    tooltip += '<div style=\"margin:5px 0;\">' + marker(colors['Previous']) +
                 ' <span style=\"color:#666;\">Previous Sales:</span> ' +
                 '<b>' + (values['Previous'] ?? '-') + '</b> units' +
               '</div>';
    tooltip += '<div style=\"margin:5px 0;\">' + marker(colors['Previous Target']) +
                 ' <span style=\"color:#666;\">Previous Target:</span> ' +
                 '<b>' + (values['Previous Target'] ?? '-') + '</b> units' +
               '</div>';

    return tooltip;
  }
")


    ) |>
  e_title(
    "Belts are Slackening",
    "Although the category sold the most usits and surpassed its previous target the furthest, a closer look is needed to understand why the recent target wasn't met."
  ) |>
  e_grid( 
  top = 100
  ) 

# creating the slim navy bar using JS
js <- sprintf("
function(el, y) {
  const chart = echarts.getInstanceByDom(el);
  const data = %s;

  const settings = {
    baseValue: 0,
    offsetX: 0,
    offsetY: 0,
    barWidth: 35,                         // now represents horizontal thickness
    fill: 'rgba(19,46,87,1.0)',
    stroke: 'rgba(19,46,87,1.0)',
    strokeWidth: 1,
    dash: [0, 0],
    zLevel: 2
  };

  const customSeries = {
    type: 'custom',
    name: 'Current',
    renderItem: function(params, api) {
      const catIdx = api.value(0);
      const val = api.value(1);

      const baseCoord = api.coord([catIdx, settings.baseValue]);
      const endCoord  = api.coord([catIdx, val]);
      if (!baseCoord || !endCoord) return;

      const rect = {
        x: baseCoord[0] - settings.barWidth / 2 + settings.offsetX,
        y: endCoord[1] + settings.offsetY,
        width: settings.barWidth,
        height: baseCoord[1] - endCoord[1]
      };

      return {
        type: 'rect',
        shape: rect,
        style: api.style({
          fill: settings.fill,
          stroke: settings.stroke,
          lineWidth: settings.strokeWidth,
          lineDash: settings.dash
        }),
        data: [catIdx, val]
      };
    },
    data: data,
    silent: false,
    z: settings.zLevel
  };

  const opt = chart.getOption();
  opt.series = opt.series || [];
  opt.series.push(customSeries);
  chart.setOption(opt, false);
}
", custom_data_json)


# attaching slim JS bar to chart
final_chart <- onRender(base_chart, js)
final_chart
``` 

&nbsp;    
  
Pay attention the the comments scattered around the functions and particularly in the tooltip's formatter if you intend to rotate using `e_flip_coords()`. Although it can be a quicker solution in some regards, it opens the door to some confusion if you're not keeping in mind that some inversions are being done to axis-related arguments.  
  
&nbsp;  
  
### 2.2 Type 2: (Placeholders & Variance)  
  
The next two charts borrow a lot of their set up from the [Bar Waterfall Charts](https://github.com/afrikaniz3d-za/Quarto-Ready-ECharts4R-Templates/blob/main/bar_waterfall_chart.qmd) I created some time back, the main thing being the use of invisible bars that act as the base for certain visible elements. What's nice about this is that all of the chart elements are (apart from the tooltip) require no JS.

The reference charts are from an exchange between [Husain and MFelix](https://community.fabric.microsoft.com/t5/Desktop/Vertical-Bullet-Chart-with-variance-colored/td-p/1507725). Rather than using a wider, grayed bar to represent previous records, conditional formatting with colour is used to highlight whether a measure has met/exceeded a target or fallen short via the colour-coded variance elements.  

&nbsp;  

#### 2.2.1 Vertical configuration

```{r}
#| code-fold: true
#| label: type-2-vertical-bullet-chart
#| fig-width: 5
#| fig-height: 6


suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(echarts4r)
  library(htmltools)
})

# example data
df <- data.frame(
  agent_name = c("Carl", "Felicia", "Thembi", "Anika", "Kuben", "Thato", "Saul"),
  avg_waiting_time = c(33, 100, 45, 27, 80, 67, 38),
  target_avg_waiting_time = c(45, 65, 60, 55, 65, 50, 55)
  # this would be the data that comes in. In order to use it in a stacked bar format,
  # some calculations need to be done where there is a split/extension relative to the 
  # target value to inform the bar colour via conditional formatting.
  # This is done by introducing a new column "variance",
  # along with a column for the two different categories of the variance - "exceeded" or "fell short"
  ) |>
    mutate(
      variance = target_avg_waiting_time - avg_waiting_time,
      placeholder = case_when(
        variance < 0 ~ target_avg_waiting_time,
        TRUE ~ target_avg_waiting_time - variance
        ),
      variance_group = case_when(
        variance > 0 ~ "exceeded",
        TRUE ~ "fell_short" 
        )
      ) 

# defining the colour of the variance bar in the chart
df_wider <- df |>
  pivot_wider(
    names_from = variance_group,
    values_from = variance
  ) |>
  
  mutate(
    fell_short_abs = abs(fell_short) # a workaround to stop the negative value from sprouting from 0 downward
  )

# base chart
df_wider |>
  e_charts(
    agent_name,
    height = 750) |>
  e_bar(
    avg_waiting_time,
    name = "Avg Waiting Time (seconds)",
    barWidth = 80,
    stack = "total",
    z = 0,
    itemStyle = list(
      color = "#cccccc"),
    markPoint = list(
      symbol = "rect",
      show = FALSE, 
      tooltip = list(
        show = FALSE
        ),
    symbolSize = c(30, 6),
      itemStyle = list(
      color = "#000000"
      ),
      data = lapply(1:nrow(df), function(i) list(
        yAxis = df$target_avg_waiting_time[i],
        xAxis = df$agent_name[i]
        )
      )
    )
  ) |>
  e_bar(
    placeholder,
    name = "Placeholder",
    barWidth = 80,
    stack = "variance",
    z = 1,
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
    exceeded,
    name = "Variance (Exceeded)",
    barWidth = 80,
    stack = "variance", # sitting on top of the invisible placeholder
    barGap = "-100%",
    z = 1,
    itemStyle = list(
      color = "#118dff"
      ),
    label = list(
    show = TRUE,
    position = "inside",
    fontSize = 16,
    fontWeight = "bold"
    )
  ) |>
  e_bar( 
    fell_short_abs,
    name = "Variance (Fell Short)",
    barWidth = 80,
    stack = "variance", # sitting on top of the invisible placeholder
    barGap = "-100%",
    z = 1,
    itemStyle = list(
      color = "#d64550"
      ),
    label = list(
    show = TRUE,
    position = "inside",
    fontSize = 16,
    fontWeight = "bold"
    )
  ) |>
    
# invisible placeholder for the avg. waiting time value to appear in the tooltip  
  e_scatter( 
    avg_waiting_time,
    name = "Avg. Waiting Time",
    itemStyle = list(
      opacity = 0),
    symbolSize = 0
    ) |>
# invisible placeholder for the  target avg. waiting time value to appear in the tooltip
    e_scatter( 
    target_avg_waiting_time,
    name = "Target Avg. Waiting Time",
    itemStyle = list(
      opacity = 0),
    symbolSize = 0
    ) |>
# seen as the y-axis in this example because of e-flipped_coords()
  e_x_axis(  
    show = TRUE,
    axisLabel = list(
      margin = 30,
      fontSize = 16,
      fontWeight = "bold"
      ),
    axisLine = list(
      show = FALSE
      ),
    axisTick = list(
      show = FALSE
      )
    ) |>
# seen as the x-axis in this example because of e-flipped_coords()
    e_y_axis( 
    min = 0,
    show = TRUE,
    axisLabel = list(
      margin = 20,
      fontSize = 16,
      fontWeight = "bold"
      ),
    axisLine = list(
      show = FALSE
      ),
    axisTick = list(
      show = FALSE
      )
  ) |>
  e_legend(
    show = FALSE
  ) |>
  e_tooltip(
  trigger = "axis",
  axisPointer = list(
    type = "line",
    axis = "x"
  ),
  formatter = htmlwidgets::JS("
    function(params) {

      if (!Array.isArray(params)) return;

      // Agent name
      let agent = params[0]?.name ?? '-';

      // Header
      let tooltip = `
        <div style=\"margin-bottom:6px;font-weight:bold;color:#333;\">
          Incoming Calls: Average Wait Times
        </div>
        <div style=\"margin-bottom:10px;color:#777;\">
          Agent name: <b>${agent}</b>
        </div>
      `;

      // Colours to match series names exactly
      const colors = {
        'Avg. Waiting Time': '#cccccc',
        'Target Avg. Waiting Time': '#000000',
        'Variance (Exceeded)': '#118dff',
        'Variance (Fell Short)': '#d64550'
      };

      // Small coloured square
      function marker(color) {
        return `<span style=\"
                  display:inline-block;
                  width:10px;
                  height:10px;
                  margin-right:6px;
                  border-radius:2px;
                  background:${color};
                \"></span>`;
      }

      // Gathering values (flatten arrays like [category, value])
      let values = {};
      params.forEach(p => {
        let v = p.value;
        if (Array.isArray(v)) v = v[1];
        if (v === undefined || v === null) return;
        values[p.seriesName] = v;
      });

      // Average Waiting Time
      if (values['Avg. Waiting Time'] !== undefined) {
        tooltip += `
          <div style=\"margin:5px 0;\">
            ${marker(colors['Avg. Waiting Time'])}
            <span style=\"color:#666;\">Avg. Waiting Time:</span>
            <b>${values['Avg. Waiting Time']}</b> seconds
          </div>
        `;
      }

      // Target Average Waiting Time
      if (values['Target Avg. Waiting Time'] !== undefined) {
        tooltip += `
          <div style=\"margin:5px 0;\">
            ${marker(colors['Target Avg. Waiting Time'])}
            <span style=\"color:#666;\">Target Avg. Waiting Time:</span>
            <b>${values['Target Avg. Waiting Time']}</b> seconds
          </div>
        `;
      }

      // Only one variance should show: Exceeded OR Fell Short (never both)
      if (values['Variance (Exceeded)'] !== undefined && values['Variance (Exceeded)'] > 0) {
        tooltip += `
          <div style=\"margin:5px 0;\">
            ${marker(colors['Variance (Exceeded)'])}
            <span style=\"color:#666;\">Exceeded By:</span>
            <b>${values['Variance (Exceeded)']}</b> seconds
          </div>
        `;
      } else if (values['Variance (Fell Short)'] !== undefined && values['Variance (Fell Short)'] > 0) {
        tooltip += `
          <div style=\"margin:5px 0;\">
            ${marker(colors['Variance (Fell Short)'])}
            <span style=\"color:#666;\">Fell Short By:</span>
            <b>${values['Variance (Fell Short)']}</b> seconds
          </div>
        `;
      }

      return tooltip;
    }
  ")
) |>
  e_title(
    "Bye, Felicia?",
    "Even after implementing the use of personalised targets for each agent, recent figures show that Felicia has failed to meet her Minimum Wait Time for incoming calls."
  ) |>
  e_grid( 
  top = 100
  ) 

``` 

&nbsp;  

The tricky part here was figuring out a way to get the negative variance value bars to sprout downward from the target marker, rather than starting from zero. This is where the invisible placeholder `e_bar()` was crucial.  

&nbsp;  

```html
mutate(
      variance = target_avg_waiting_time - avg_waiting_time,
      placeholder = case_when(
        variance < 0 ~ target_avg_waiting_time,
        TRUE ~ target_avg_waiting_time - variance
        ),
      variance_group = case_when(
        variance > 0 ~ "exceeded",
        TRUE ~ "fell_short" 
        )
      )
```  

&nbsp;  

I couldn't work out a solution that worked for all bars, so I ended up using applying the `abs()` function to the new `fell_short` column after the above mutation and stacking that on the invisible `placeholder e_bar()` to construct the final chart.  

The final mental gymnastic you might need to do, especially when working off the [reference](https://community.fabric.microsoft.com/t5/Desktop/Vertical-Bullet-Chart-with-variance-colored/td-p/1507725) is that you needed to flip a few logics to construct the chart in this example. One instance is that you're racing to the bottom, so that means lower numbers are better. It took a few tries to get it looking "right" visually, even is some of the lines of code seemed "backward".  

#### 2.2.1 Vertical configuration

```{r}
#| code-fold: true
#| label: type-2-horizontal-bullet-chart
#| fig-width: 5
#| fig-height: 6


suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(echarts4r)
  library(htmltools)
})

# example data
df <- data.frame(
  agent_name = c("Carl", "Felicia", "Thembi", "Anika", "Kuben", "Thato", "Saul"),
  avg_waiting_time = c(33, 100, 45, 27, 80, 67, 38),
  target_avg_waiting_time = c(45, 65, 60, 55, 65, 50, 55)
  # this would be the data that comes in. In order to use it in a stacked bar format,
  # some calculations need to be done where there is a split/extension relative to the 
  # target value to inform the bar colour via conditional formatting.
  # This is done by introducing a new column "variance",
  # along with a column for the two different categories of the variance - "exceeded" or "fell short"
  ) |>
    mutate(
      variance = target_avg_waiting_time - avg_waiting_time,
      placeholder = case_when(
        variance < 0 ~ target_avg_waiting_time,
        TRUE ~ target_avg_waiting_time - variance
        ),
      variance_group = case_when(
        variance > 0 ~ "exceeded",
        TRUE ~ "fell_short" 
        )
      ) 

# defining the colour of the variance bar in the chart
df_wider <- df |>
  pivot_wider(
    names_from = variance_group,
    values_from = variance
  ) |>
  
  mutate(
    fell_short_abs = abs(fell_short) # a workaround to stop the negative value from sprouting from 0 downward
  )

# base chart
df_wider |>
  e_charts(
    agent_name,
    height = 750) |>
  e_bar(
    avg_waiting_time,
    name = "Avg Waiting Time (seconds)",
    barWidth = 60,
    stack = "total",
    z = 0,
    itemStyle = list(
      color = "#cccccc"
      )
    ) |>
  e_bar(
    placeholder,
    name = "Placeholder",
    barWidth = 60,
    stack = "variance",
    z = 1,
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
    exceeded,
    name = "Variance (Exceeded)",
    barWidth = 60,
    stack = "variance", # sitting on top of the invisible placeholder
    barGap = "-100%",
    z = 1,
    itemStyle = list(
      color = "#118dff"
      ),
    label = list(
      show = TRUE,
      position = "inside",
      fontSize = 16,
      fontWeight = "bold"
      ),
    tooltip = list(
      show = TRUE
      )
    ) |>
  e_bar( 
    fell_short_abs,
    name = "Variance (Fell Short)",
    barWidth = 60,
    stack = "variance", # sitting on top of the invisible placeholder
    barGap = "-100%",
    z = 1,
    itemStyle = list(
      color = "#d64550"
      ),
    label = list(
      show = TRUE,
      position = "inside",
      fontSize = 16,
      fontWeight = "bold"
      ),
    tooltip = list(
      show = TRUE
      )
    ) |>

# invisible placeholder for the avg. waiting time value to appear in the tooltip    
  e_scatter( 
    avg_waiting_time,
    name = "Avg. Waiting Time",
    itemStyle = list(
      opacity = 0),
    symbolSize = 0,
    tooltip = list(
      show = TRUE
      )
    ) |>

# invisible placeholder for the  target avg. waiting time value to appear in the tooltip  
    e_scatter( 
    target_avg_waiting_time,
    name = "Target Avg. Waiting Time",
    itemStyle = list(
      opacity = 0),
    symbolSize = 0,
    tooltip = list(
      show = TRUE
      ),
    markPoint = list(
      symbol = "rect",
      show = FALSE, 
      tooltip = list(
        show = FALSE
      ),
      symbolSize = c(6, 30), # these values were switched around
      itemStyle = list(
        color = "#000000"
      ),
      data = lapply(1:nrow(df), function(i) list(
        yAxis = df$agent_name[i],
        xAxis = df$target_avg_waiting_time[i] # these columns (yAxis and xAxis) were switched around
        )
       )
      )
    ) |>

# seen as the y-axis in this example because of e-flipped_coords()
    e_x_axis(  
    show = TRUE,
    axisLabel = list(
      margin = 30,
      fontSize = 16,
      fontWeight = "bold"
      ),
    axisLine = list(
      show = FALSE
      ),
    axisTick = list(
      show = FALSE
      )
    ) |>
# seen as the x-axis in this example because of e-flipped_coords()
    e_y_axis(
    min = 0,
    show = TRUE,
    axisLabel = list(
      margin = 20,
      fontSize = 16,
      fontWeight = "bold"
      ),
    axisLine = list(
      show = FALSE
      ),
    axisTick = list(
      show = FALSE
      )
  ) |>
  e_legend(
    show = FALSE
  ) |>
  e_tooltip(
  trigger = "axis",
  confine = TRUE,
  order = "seriesAsc",
  axisPointer = list(
    type = "line",
    axis = "y" # switched when the chart was flipped ((bars..))
  ),
  formatter = htmlwidgets::JS("
    function(params) {

      if (!Array.isArray(params)) return;

      // Agent name
      let agent = params[0]?.name ?? '-';

      // Header
      let tooltip = `
        <div style=\"margin-bottom:6px;font-weight:bold;color:#333;\">
          Incoming Calls: Average Wait Times
        </div>
        <div style=\"margin-bottom:10px;color:#777;\">
          Agent name: <b>${agent}</b>
        </div>
      `;

      // Colours to match series names exactly
      const colors = {
        'Avg. Waiting Time': '#cccccc',
        'Target Avg. Waiting Time': '#000000',
        'Variance (Exceeded)': '#118dff',
        'Variance (Fell Short)': '#d64550'
      };

      // Small coloured square
      function marker(color) {
        return `<span style=\"
                  display:inline-block;
                  width:10px;
                  height:10px;
                  margin-right:6px;
                  border-radius:2px;
                  background:${color};
                \"></span>`;
      }

      // Gathering values to handle both numeric & object data
        let values = {};
        params.forEach(p => {
        let raw = p.data;
        if (raw === undefined || raw === null) return;
        let v = (typeof raw === 'object' && raw !== null && 'value' in raw)
            ? raw.value
            : raw;
            values[p.seriesName] = Array.isArray(v) ? v[0] : v;
          });


      // Average Waiting Time
      if (values['Avg. Waiting Time'] !== undefined) {
        tooltip += `
          <div style=\"margin:5px 0;\">
            ${marker(colors['Avg. Waiting Time'])}
            <span style=\"color:#666;\">Avg. Waiting Time:</span>
            <b>${values['Avg. Waiting Time']}</b> seconds
          </div>
        `;
      }

      // Target Average Waiting Time
      if (values['Target Avg. Waiting Time'] !== undefined) {
        tooltip += `
          <div style=\"margin:5px 0;\">
            ${marker(colors['Target Avg. Waiting Time'])}
            <span style=\"color:#666;\">Target Avg. Waiting Time:</span>
            <b>${values['Target Avg. Waiting Time']}</b> seconds
          </div>
        `;
      }

      // Only one variance should show: Exceeded OR Fell Short (never both)
      if (values['Variance (Exceeded)'] !== undefined && values['Variance (Exceeded)'] > 0) {
        tooltip += `
          <div style=\"margin:5px 0;\">
            ${marker(colors['Variance (Exceeded)'])}
            <span style=\"color:#666;\">Exceeded By:</span>
            <b>${values['Variance (Exceeded)']}</b> seconds
          </div>
        `;
      } else if (values['Variance (Fell Short)'] !== undefined && values['Variance (Fell Short)'] > 0) {
        tooltip += `
          <div style=\"margin:5px 0;\">
            ${marker(colors['Variance (Fell Short)'])}
            <span style=\"color:#666;\">Fell Short By:</span>
            <b>${values['Variance (Fell Short)']}</b> seconds
          </div>
        `;
      }

      return tooltip;
    }
  ")
) |>
  e_title(
    "Bye, Felicia?",
    "Even after implementing the use of personalised targets for each agent, recent figures show that Felicia has failed to meet her Minimum Wait Time for incoming calls."
  ) |>
  e_grid( 
  top = 100
  ) |>
  e_flip_coords()

``` 

&nbsp;   

Changing the orientation using `e_flip_coords()` tends to be a delicate exercise unique to every chart. It's the main reason why I've started including both a vertical **and** horizontal version for each chart. I commented in some details near lines to pay attention to when making changes, or letting you know the relationship of the change according to the other orientation. I hope to flesh these parts of the guides more once I've done the dedicated ***tooltip templates***.  

&nbsp;  

## 3. Outro  

I got to learn about some of the limitations of using out-of-the-box ECharts4R during the making of these templates. It was also another case where appealing to Chat-GPT in areas where I got stuck wasn't always the best decision because it has a habit of wanting to refactor a whole solution rather than focusing on the small detail you outline. For example, in setting up the second example of Type one, I had deleted the placeholder `e_scatter` that fed values into the tooltip. I'd forgotten that's what its purpose was. I couldn't figure out why I couldn't get the tool tip to show the value, so when I queried this to Chat-GPT the solution it proposed was a completely different chart. Sample data was changed, many little elements were moved, and the chart was now throwing out new errors when I tried to render. I closed the tab and went back to the first chart and reviewed the code. 6-7 lines of code fixed the problem, versus the 200+ revised lines that wouldn't generate anything. My error started this issue, but it was a good reminder that the LLM is not infallible either.

There was a third example I considered adding, but it might be better suited to being in its own submission due to the level of detail.  

If you think something's missing or have a question give me a shout and we can figure it out together.  
