# SoilWeb-data
Cached data used to support various aspects of the SoilWeb applications and APIs.


## Files
Most of these are derived from the current FY snapshot, semi-annually to quarterly.


### MLRA Overlap / Membership

  * mukey-mlra-overlap.csv.gz
  * nmsym-mlra-overlap.csv.gz
  * series-mlra-overlap.csv.gz

#### Examples

|   mukey|mlra | area_ac| membership|
|-------:|:----|-------:|----------:|
|  480552|28B  |    3503|      1.000|
|  118912|136  |      29|      1.000|
| 2403834|44   |       9|      1.000|
|  445569|102B |    1013|      1.000|
| 2108669|136  |     412|      0.924|


|nationalmusym |mlra | area_ac| membership|
|:-------------|:----|-------:|----------:|
|1hhpb         |6    |      36|      1.000|
|jxnq          |47   |     306|      1.000|
|1hcns         |133A |     551|      1.000|
|1tf7b         |30   |    9196|      1.000|
|59rh          |43A  |     677|      0.985|
|59rh          |44   |      10|      0.015|
|g1t2          |102A |    1655|      1.000|
|hfng          |15   |     584|      0.908|


|series   |mlra | area_ac| membership|
|:--------|:----|-------:|----------:|
|QUEBRADA |270  |   21659|      0.982|
|QUEBRADA |271  |     394|      0.018|
|QUEBRADA |272  |      13|      0.001|
|AEROBEE  |42   |   32165|      1.000|
|TOUCHET  |7    |    3093|      0.985|
|TOUCHET  |8    |      47|      0.015|
|WIGI     |4B   |     908|      1.000|
|ARRIVA   |3    |   17104|      0.981|


### SSURGO Parent Material

  * pmkind.csv.gz
  * pmorigin.csv.gz


#### Examples

|series |q_param        | q_param_n| total|     p|
|:------|:--------------|---------:|-----:|-----:|
|AABAB  |Alluvium       |         5|     5| 1.000|
|AAGARD |Slope alluvium |         4|     5| 0.800|
|AAGARD |Residuum       |         1|     5| 0.200|
|AARON  |Residuum       |        56|    64| 0.875|
|AARON  |Loess          |         8|    64| 0.125|
|AARUP  |Loess          |         7|    14| 0.500|
|AARUP  |Volcanic ash   |         7|    14| 0.500|
|AASTAD |Till           |       164|   164| 1.000|


|series |q_param                          | q_param_n| total|      p|
|:------|:--------------------------------|---------:|-----:|------:|
|AABAB  |Sandstone and siltstone          |         2|     2| 1.0000|
|AABERG |Shale                            |         3|     5| 0.6000|
|AABERG |Mudstone                         |         2|     5| 0.4000|
|AAGARD |Metamorphic and sedimentary rock |         3|     5| 0.6000|
|AAGARD |Limestone and shale              |         2|     5| 0.4000|
|AARON  |Limestone and shale              |        10|    11| 0.9091|
|AARON  |Calcareous shale                 |         1|    11| 0.0909|
|ABAC   |Sandstone and shale              |        11|    13| 0.8462|

### SSURGO Geomorphology

  * geomcomp_wide.csv.gz
  * hillpos_wide.csv.gz
  * mountainpos_wide.csv.gz

### Soil Series

  * series_stats.csv.gz
  * kssl-records-per-series.csv.gz
  * SC-database.csv.gz
  
### Soil Taxonomy Misc.
  * family_component_stats.csv.gz
  * taxsubgrp-stats.txt.gz
  
  
  
  
  
  
  
  
