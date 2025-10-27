---
title: "Candlestick Charts"
date: 10-27-2025
author: Ntobeko Sosibo
toc: true
toc-location: left
toc-title: "Contents"
toc-depth: 6
execute:
  echo: true
  output: asis
  cache: false
format: 
  html:
    grid: 
      body-width: 1200px
    page-layout: full

---
## 1. The ECharts example  

I explored the [Basic Candlestick](https://echarts.apache.org/examples/en/editor.html?c=candlestick-simple) example on the site to see how they put their's together.  

The code:  

```html
option = {
  xAxis: {
    data: ['2017-10-24', '2017-10-25', '2017-10-26', '2017-10-27']
  },
  yAxis: {},
  series: [
    {
      type: 'candlestick',
      data: [
        [20, 34, 10, 38],
        [40, 35, 30, 50],
        [31, 38, 33, 44],
        [38, 15, 5, 42]
      ]
    }
  ]
};
```

&nbsp;  

`Candlestick`is its own type of chart, and the same is true in ECharts4R with the `e_candlestick` function.

&nbsp;  
  
### 1.1 Candlestick chart in ECharts4R (As per documentation) 

```{r}
#| label: documentation-candlestick
#| code-fold: true
#| fig-width: 12
#| fig-height: 6

suppressPackageStartupMessages({
  library(echarts4r)
  library(tidyr)
})

stock <- tibble(
  date = c(
    "2017-01-01",
    "2017-01-02",
    "2017-01-03",
    "2017-01-04",
    "2017-03-05",
    "2017-01-06",
    "2017-01-07"
  ),
  opening = c(200.60, 200.22, 198.43, 199.05, 203.54, 203.40, 208.34),
  closing = c(200.72, 198.85, 199.05, 203.73, 204.08, 208.11, 211.88),
  low = c(197.82, 198.07, 197.90, 198.10, 202.00, 201.50, 207.60),
  high = c(203.32, 200.67, 200.00, 203.95, 204.90, 208.44, 213.17)
)

stock$date <- as.character(stock$date)


stock |>
  e_charts(date) |>
  e_candle(
    opening, 
    closing, 
    low, 
    high,
    name = "Candlestick") |>
  e_y_axis(min = 190, max = 220) 
  
```  

&nbsp;  



### 1.2 A more complex example using real data  

Here's an example using data pulled from Cody's [Stock Exchange Dataset](https://www.kaggle.com/datasets/mattiuzc/stock-exchange-data?resource=download) on Kaggle. The chart below include more detail than the base example, aiming to replicate the [Shanghai Index](https://echarts.apache.org/examples/en/editor.html?c=candlestick-sh) ECharts example. I took 3 months' worth of data to keep it short.  


```{r}
#| label: ks11-candlestick
#| code-fold: true
#| fig-width: 12
#| fig-height: 6

suppressPackageStartupMessages({
  library(echarts4r)
  library(tidyr)
  library(dplyr)
  library(purrr)
  library(htmlwidgets)
  library(htmltools)
})

ks11_stock <- tibble(
  Date = c("2021-01-04", "2021-01-05", "2021-01-06", "2021-01-07", "2021-01-08", "2021-01-11", "2021-01-12", "2021-01-13", "2021-01-14", "2021-01-15", "2021-01-18", "2021-01-19", "2021-01-20", "2021-01-21", "2021-01-22", "2021-01-25", "2021-01-26", "2021-01-27", "2021-01-28", "2021-01-29",
"2021-02-01", "2021-02-02", "2021-02-03", "2021-02-04", "2021-02-05", "2021-02-08", "2021-02-09", "2021-02-10", "2021-02-15", "2021-02-16", "2021-02-17", "2021-02-18", "2021-02-19", "2021-02-22", "2021-02-23", "2021-02-24", "2021-02-25", "2021-02-26", "2021-03-02", "2021-03-03", "2021-03-04", "2021-03-05", "2021-03-08", "2021-03-09", "2021-03-10", "2021-03-11", "2021-03-12", "2021-03-15", "2021-03-16", "2021-03-17", "2021-03-18", "2021-03-19", "2021-03-22", "2021-03-23", "2021-03-24", "2021-03-25", "2021-03-26", "2021-03-29", "2021-03-30", "2021-03-31"),
  Open = c(2874.5, 2943.669922, 2993.340088, 2980.75, 3040.110107, 3161.899902, 3145.870117, 3128.26001, 3148.649902, 3153.840088, 3079.899902, 3013.050049, 3115.040039, 3123.27002, 3163.830078, 3144.01001, 3203.959961, 3143.459961, 3114.97998, 3078.72998,2976.810059, 3065.560059, 3108.419922, 3135.02002, 3098.48999, 3113.629883, 3102.25, 3088.129883, 3108.699951, 3151.850098, 3162.949951, 3131.73999, 3089.959961, 3114.030029, 3069.26001, 3070.580078, 3026.469971, 3089.48999, 3021.679932, 3041.199951, 3076.879883, 3036.159912, 3031.98999, 2989.959961, 2980.76001, 2964.300049, 3030.72998, 3057.060059, 3049.22998, 3067.76001, 3054.929932, 3063.01001, 3040.01001, 3038.25, 2996.320068, 2995.669922, 3012.790039, 3047.709961, 3038.439941, 3073.389893),
  High = c(2946.540039, 2990.570068, 3027.159912, 3055.280029, 3161.110107, 3266.22998, 3154.790039, 3164.370117, 3159.030029, 3189.899902, 3079.899902, 3092.659912, 3145.01001, 3163.209961, 3185.26001, 3212.219971, 3209.179932, 3182.530029, 3114.97998, 3100.219971,3056.870117, 3138.949951, 3142.26001, 3135.02002, 3124.620117, 3128.540039, 3129.659912, 3111.879883, 3156.560059, 3180.939941, 3162.949951, 3140.399902, 3109.669922, 3142.47998, 3094.290039, 3092.050049, 3099.800049, 3089.48999, 3096.5, 3083.040039, 3076.879883, 3036.97998, 3055.649902, 3000.48999, 3013.949951, 3028.370117, 3061.429932, 3065.169922, 3071.540039, 3069.570068, 3090.189941, 3063.01001, 3048.110107, 3058.790039, 3006.540039, 3024.629883, 3041.860107, 3054.209961, 3074.570068, 3093.889893),
  Low = c(2869.110107, 2921.840088, 2961.370117, 2980.75, 3040.110107, 3096.189941, 3047.560059, 3109.629883, 3128.719971, 3085.899902, 3003.889893, 3013.050049, 3077.149902, 3123.27002, 3140.600098, 3142.800049, 3132.669922, 3118.889893, 3046.639893, 2962.699951,2947.23999, 3065.560059, 3091.850098, 3068.459961, 3081.780029, 3085.590088, 3084.669922, 3064.25, 3108.699951, 3145.840088, 3115.47998, 3086.659912, 3040.280029, 3079.159912, 3035.459961, 2993.459961, 3026.469971, 2988.280029, 3020.73999, 3029.370117, 3022.540039, 2982.449951, 2992.639893, 2929.360107, 2951.530029, 2964.300049, 3030.72998, 3036.139893, 3049.22998, 3027.199951, 3054.929932, 3022.48999, 3019.600098, 3003.050049, 2971.040039, 2987.830078, 3012.790039, 3025.389893, 3038.439941, 3061.399902),
  Close = c(2944.449951, 2990.570068, 2968.209961, 3031.679932, 3152.179932, 3148.449951, 3125.949951, 3148.290039, 3149.929932, 3085.899902, 3013.929932, 3092.659912, 3114.550049, 3160.840088, 3140.629883, 3208.98999, 3140.310059, 3122.560059, 3069.050049, 2976.209961,3056.530029, 3096.810059, 3129.679932, 3087.550049, 3120.629883, 3091.23999, 3084.669922, 3100.580078, 3147, 3163.25, 3133.72998, 3086.659912, 3107.620117, 3079.75, 3070.090088, 2994.97998, 3099.689941, 3012.949951, 3043.870117, 3082.98999, 3043.48999, 3026.26001, 2996.110107, 2976.120117, 2958.120117, 3013.699951, 3054.389893, 3045.709961, 3067.169922, 3047.5, 3066.01001, 3039.530029, 3035.459961, 3004.73999, 2996.350098, 3008.330078, 3041.01001, 3036.040039, 3070, 3061.419922),
  Volume = c(1026500, 1519900, 1793400, 1524700, 1297900, 1712500, 1388600, 1578000, 1233200, 1331100, 1472000, 1353300, 1192700, 1360100, 1111200, 1093700, 873000, 924600, 1310500, 995100,969300, 887300, 901800, 1460900, 1193500, 1277200, 2145400, 2152900, 1604700, 1944400, 1784100, 1860600, 3455500, 1832000, 2357800, 1560900, 1280100, 1361300, 1749900, 2236700, 1279000, 1187200, 1928300, 1534200, 905600, 1349200, 1669100, 1161800, 1123900, 815000, 1232600, 1068500, 915700, 1331200, 978400, 940400, 1036400, 1288800, 1023100, 1147000)
)

ks11_stock <- ks11_stock %>%
  mutate(
    date = as.character(Date),
    opening = Open,
    closing = Close,
    high = High,
    low = Low,
    volume = as.numeric(Volume),
    )

max <- list(
  name = "Max",
  type = "max"
)

min <- list(
  name = "Min",
  type = "min"
)


candlestick <-
ks11_stock |>
  e_charts(
    date,
    height = 800
    ) |>
  e_candle(
    opening, 
    closing, 
    low, 
    high,
    name = "KS11 Stock Candlestick Chart",
    itemStyle = list(
      color = "#47b262",        #   manually defining the candle colours because the default generated with 
      color0 = "#eb5454",       #   bullish being red and bearish being green
      borderColor = "#47b262",
      borderColor0 = "#eb5454"
      ),
    y_index = 0
    ) |>
  
  e_grid(
    top = "20%", 
    bottom = "15%"
    ) |>
  
  e_y_axis(
    y_index = 0, 
    min = 2800, 
    max = 3300,
    formatter = 
      htmlwidgets::JS(
        "function(v){return '$' + v.toFixed(0);}"
        )
    ) |>
  e_y_axis(
    index = 1, 
    name = "Volume"
    ) |>
  
  e_legend(
    top = 150
    ) |>
  e_tooltip(
    trigger = "axis",
    axisPointer = list(
      type = "cross"
      ),
  formatter = htmlwidgets::JS("
    function(params) {
      // If single point, fallback to default
      if (!Array.isArray(params)) return params.marker + ' ' + params.seriesName + ': ' + params.value;
    
      // --- Chart title
      let title = 'KS11 Stock Candlestick Chart';
      let tooltip = '<div style=\"margin-bottom:6px; font-weight:normal; color:#333;\">' + title + '</div>';
    
      // --- Date header
      let raw = params[0].axisValue || params[0].name || '';
      let match = raw.match(/\\d{4}-\\d{2}-\\d{2}/);
      let day = match ? match[0] : raw;
      tooltip += '<div style=\"font-weight:bold; color:#333; margin-bottom:8px;\">' + day + '</div>';
    
      // --- Find candlestick series
      let candleParam = params.find(p => p.seriesType === 'candlestick' || p.seriesName === title);
    
      if (candleParam) {
        // Extract OHLC from data
        let arr = Array.isArray(candleParam.data) ? candleParam.data :
                  (candleParam.data && Array.isArray(candleParam.data.value)) ? candleParam.data.value :
                  Array.isArray(candleParam.value) ? candleParam.value : [];
    
        let open, close, low, high;
        if (arr.length >= 5 && Number(arr[0]) < 1000) { // shifted format [idx, open, close, low, high]
          open  = Number(arr[1]);
          close = Number(arr[2]);
          low   = Number(arr[3]);
          high  = Number(arr[4]);
        } else if (arr.length >= 4) { // normal format [open, close, low, high]
          open  = Number(arr[0]);
          close = Number(arr[1]);
          low   = Number(arr[2]);
          high  = Number(arr[3]);
        } else { // fallback
          open = close = low = high = 0;
        }
    
        // --- Formatting helper
        function fmtMoney(n){ return (isFinite(n) ? n.toFixed(2) : '0.00'); }
    
        // --- Tooltip rows
        tooltip += '<div style=\"margin:5px 0;\">' + (candleParam.marker || '') + 
                   ' <span style=\"color:#666;\">Open:</span> <b>$ ' + fmtMoney(open) + '</b></div>';
        tooltip += '<div style=\"margin:5px 0;\">' + (candleParam.marker || '') + 
                   ' <span style=\"color:#666;\">Close:</span> <b>$ ' + fmtMoney(close) + '</b></div>';
        tooltip += '<div style=\"margin:5px 0;\">' + (candleParam.marker || '') + 
                   ' <span style=\"color:#666;\">Low:</span> <b>$ ' + fmtMoney(low) + '</b></div>';
        tooltip += '<div style=\"margin:5px 0;\">' + (candleParam.marker || '') + 
                   ' <span style=\"color:#666;\">High:</span> <b>$ ' + fmtMoney(high) + '</b></div>';
        }
    
        return tooltip;
      }
    ")
    ) |>
  e_mark_line(
    data = list(
      yAxis = "min"), 
    title = "Lowest"
    ) |> 
  e_mark_line(
    data = list(
      yAxis = "max"), 
    title = "Highest"  # rather than mark the actual highest figure, this option remains dynamic and adjusts according to the datazoomed chart
    ) |> 
  e_mark_line(
    data = list(
      xAxis = "2021-01-11"), 
    title = "Indecisive Period"
  ) |>  
  e_datazoom(
  ) |>
  e_title(
    "A Turbulent Start to 2021 for KS11",
    "The start of the year shows strong volatility and rapid gains for the KS11 stock. The tall green candles mixed into a steep climb suggest that while prices were rising overall, they were doing so through sharp, uncertain swings. 
    
Those two small red candles with long tails right after the rise hint at a moment of indecision ('Indecisive Period') or profit-taking.
    
As the weeks went on, the pattern calmed, balancing in colour mix and less extreme highs, suggesting the market was stabilising. Investors became less reactive and prices found a steadier range."
    ) |>
  e_grid( 
  top = "20%"
  ) |>
  e_group("grp") |>
  e_connect_group("grp")


# Step 1: Add candle colour classification
volume_bar <- ks11_stock |>
  mutate(
    candle_colour = case_when(
      closing > opening ~ "Bullish",
      TRUE ~ "Bearish"
    )
  ) |>
  pivot_wider(
    names_from = candle_colour,
    values_from = volume,
    values_fill = 0
  )

# Step 3: Create the bar chart with overlapping bars
volume_bar_chart <- volume_bar |>
  e_charts(
    date, 
    height = 250
    ) |>
  e_bar(
    Bullish,
    barGap = "-80%",
    itemStyle = list(
      color = "#47b262"),
    name = "Bullish",
    y_index = 1
    ) |>
  e_bar(
    Bearish,
    barGap = "-80%",
    itemStyle = list(
      color = "#eb5454"),
    name = "Bearish",
    y_index = 1
    ) |>
  e_tooltip(
    trigger = "axis",
    axisPointer = list(
      type = "shadow"),
    formatter = 
      htmlwidgets::JS("
       function(params) {
         let tooltip = '<div style=\"margin-bottom:6px; font-weight:normal; color:#333;\">KS11 Stock Share Volume Bar Chart</div>';
    
         // --- Date header
         let raw = params[0].axisValue || params[0].name || '';
         let match = raw.match(/\\d{4}-\\d{2}-\\d{2}/);
         let day = match ? match[0] : raw;
         tooltip += '<div style=\"font-weight:bold; color:#333; margin-bottom:8px;\">' + day + '</div>';
    
         // --- Loop through all series and only include those with non-zero values
         params.forEach(function(p){
           let val = Array.isArray(p.value) ? p.value[p.value.length - 1] : p.value;
           let num = Number(val);
           if(isFinite(num) && num !== 0){
             let formattedVal = num.toLocaleString('en-US');
             tooltip += '<div style=\"margin:5px 0;\">' + (p.marker || '') + 
                        ' <span style=\"color:#666;\">' + p.seriesName + ': ' + formattedVal + '</span> Shares Traded</div>';
           }
         });
    
         return tooltip;
        }
      ")
    ) |>
  e_datazoom(
    show = FALSE
    ) |>
  e_grid(
    top = "20%"
    ) |>
  
  e_group("grp")

# --- Step 4: Link and arrange charts
e_arrange(
  candlestick,
  volume_bar_chart,
  cols = 1
)
```  

&nbsp;  

### 1.2.1 A lot of borrowing involved  

The chart itself was mostly created using bits of the documentation from John Coene's ECharts4R's documentation [blog](https://echarts4r.john-coene.com/).  

The [Conditional Formatting](https://github.com/afrikaniz3d-za/Quarto-Ready-ECharts4R-Templates/blob/main/bar_chart_with_conditional_formatting.qmd) template was a great help toward getting the bar of the volume chart to match the candle colours for better visual syncing. My first attempt was to get the volume figure also appearing in the candlestick chart's tooltip, but it became troublesome when I was trying to get the formatting to work. I also learned that it was normal to visualise the share volume data separately, so I looked back to the [Linked Charts](https://github.com/afrikaniz3d-za/Quarto-Ready-ECharts4R-Templates/blob/main/linked_charts.qmd) template for connecting the candlestick chart to the bar chart using the `e_group` and `e_connect_group` functions and be able to have both of their tooltips trigger together. The synergy with these two worked really well, and the conditional formatting on the bar colours ties them together in an easy-to-read format.

&nbsp;  

### 1.2.2 The need to get more familiar with JavaScript  

The base `tooltip`, when enabled, in a lot of the charts often needs some work to make its contents more readable (money having the currency symbol and only two decimal places, or even making certain part **bold** for more emphasis).  

Javascript via the `htmlwidgets` `formatter =` argument I'm trying to get more familiar with. It's not as transferable from project to project because of many different factors, so I relied a lot on slowly building the code with Chat-GPT - not so easy if you don't already have an HTML background.  

&nbsp;   

## 2. Outro  

This particular project/template made me realise I need to have a dedicated template dealing with just the formatting. For now, I'm content to present the above example.  

If you think something's missing or have a question give me a shout and we can figure it out together.  
