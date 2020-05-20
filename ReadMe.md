            *** LA Arrest Data - 1+ Million Records (January 2010 - June 2019) ***
                Data Wrangling and Visualization Using R Markdown in R Studio.

This project demonstrates our work of cleaning, visualizing for the raw public dataset provided by LAPD at https://data.lacity.org/A-Safe-City/Arrest-Data-from-2010-to-Present/yru6-6re4.

There are more than 1 million incidents of arrests recorded in the dataset each of which includes 17 columns [Arrest Date, Time, Area ID, Area Name, Age, Sex Code, Charge Description, Location, etc.].

Key accomplishments:
    1. Raw data was cleaned and extracted to yield the information of interest
    2. Causes of arrests were grouped, and each type was presented by a bar chart
    3. Causes of arrests were grouped but this time categorized by gender, and each was presented by a bar chart for comparison of male and female arrests
    4. Distribution of arrests involved in drug violations from 2010 to 2019 was plotted
    5. A heatmap for locations of arrests involved in drug violations in 2019 was visualized using Google Maps API
    6. Similarly, heatmaps for locations of arrests involved in drug violations from 2010 to 2018 were generated
    7. Again, heatmaps for locations of arrests involved in drug violations in 2010 and 2018 were generated for comparison

The outputs produced by LA_Arrests.Rmd were exported to LAArestVisualization.pdf file.

To expriment the program:
    1. Download LA_Arrests.Rmd
    2. Download the dataset at https://data.lacity.org/A-Safe-City/Arrest-Data-from-2010-to-Present/yru6-6re4
    3. Move the the dataset to the same directory of LA_Arrests.Rmd
    4. Install the following package for your R Studio:
           Dependencies          Purposes
           * data.table          faster read of large dataset
           * tidyverse           dplyr, tidyr, and ggplot
           * ggmap maps          Google maps API
           * mapdata             map API toolkits
           * ggrepel             map data
           * varhandle           manipulations of layers on maps
           * gridExtra           show 2 maps side by side
    5. Obtain a Google maps API key for you application at https://developers.google.com/maps/documentation/javascript/get-api-key
    6. Use R studio to open the LA_Arrests.Rmd
    7. Find the line ggmap::register_google(key='AIzaSyAyDbezM1mVF2yr5FnpX9bJ61zEVapyjqU') in the R Markdown file then replace the current key with your own Google maps API one.
    8. Run the program to enjoy how the data is visualized
