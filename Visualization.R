#  **Dependencies** | **Purposes**
#  -----------------| -------------
#  data.table       | faster read large dataset
#  tidyverse        | dplyr, tidyr, and ggplot 
#  ggmap            | maps API
#  maps             | map API toolkits
#  mapdata          | map data
#  ggrepel          | manipulations of layers on maps   
#  varhandle        | unfactor function
#  gridExtra        | show 2 maps side by side
#  options          | number digits to display

library(data.table) 
library(tidyverse)  
library(ggmap)      
library(maps)       
library(mapdata)    
library(ggrepel)
library(ggpubr)
library(varhandle)
library(gridExtra)
options(digits=16, warn=-1)
ggmap::register_google(key='XXXXXXXXXXXXXXXXXXXXXXXXXX')

# 1. Read the relevant dataset into a data frame
# 2. View the data frame

# Copy the dataset to a data frame
data_path = '~/Arrest-data-from-2010-to-present.csv'
la_arrests <- as.data.frame(fread(data_path))
View(la_arrests)

# 3.  Select relevant variables in the dataset
# 4.  Clean and wrangle data (variable names, unfilled values, latittue, longitude, date)
# 5.  Factor variable $Charge_Group_Description
# 6.  Drop messy variable $Location
# 7.  Review the complete dataset
# Select relevant cols in the dataset
df <- select(la_arrests, `Arrest Date`, `Time`, `Age`, `Area Name`, `Sex Code`, 
             `Charge Group Description`, `Arrest Type Code`, `Location`)

# Rename the multi-word variables so that each of them does not have space
setnames(df, 
         old=c('Arrest Date', 'Area Name', 'Sex Code', 
               'Charge Group Description', 'Arrest Type Code'), 
         new=c('Arrest_Date', 'Area_Name', 'Sex_Code',
               'Charge_Group_Description', 'Arrest_Type_Code'))

# Extract latitude as double format from Location of the data frame
# Convert $Arrest_Date to Date format
df <- transform(df, 
                Latitude  = as.double(str_sub(word(Location, 2, 2), 2, -3)),
                Longitude = as.double(str_sub(word(Location, -1, -1), 2, -3)),
                Arrest_Date = as.Date(str_sub(df$Arrest_Date, 1, 10)))

# Fill emppty values in Charge_Group_Description variable with 'Unknown'
df$Charge_Group_Description[df$Charge_Group_Description==''] <- 'Unknown'

# Factor and sort $Charge_Group_Description
df <- within(df, Charge_Group_Description 
             <- factor(Charge_Group_Description, 
                       levels=names(sort(table(Charge_Group_Description)))))

# Remove Location off the data frame
df <- select(df, -Location)

# Inpsect the data frame
View(df)
glimpse(df)

# 8. Plot a bar chart for $Charge_Group_Description in presenation of count and percentage in the same chart
p_colors <- c('#FC0BF0','#52FD4D','#F4B942','#350113','#F90359','#320EFC','#18B4B2')
p_colors <- c(rep(p_colors, 4))
ggplot(df, aes(x=Charge_Group_Description)) +
  geom_bar(color='black', fill=p_colors) +
  geom_bar(mapping=aes(x=Charge_Group_Description, y=..prop.., group=1),  
           stat='count', fill=p_colors) +
  geom_text(aes(label=paste(round(stat(..prop..)*100, 1),'%', sep=''), group=1), 
            stat='count', size=3.5, hjust=-0.07, color=p_colors, fontface='bold') +
  coord_flip() +
  labs(title='Los Angeles Drug Violations By Year\n(January, 2010 - June, 2019)', 
       caption='Source: https://data.lacity.org') +
  theme(axis.text.y=element_text(color=p_colors, size=12, face='bold'),
        axis.text.x=element_text(color='red', size=12, face='bold'),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        plot.title=element_text(color='#52FD4D', face='bold', hjust=0.5)) 

# 9. Plot a bar chart for drug violations by year
drug_by_year <- data.frame(Year=integer(), Counts=double())
year_span <- 2010:2019
for (year in year_span) {
  cnts <- nrow(select(filter(df, Charge_Group_Description=='Narcotic Drug Laws', 
                             as.numeric(format(Arrest_Date,'%Y'))==year)))
  drug_by_year[nrow(drug_by_year) + 1, ] = list(year, cnts)
}

ggplot(drug_by_year, aes(x=Year, y=Counts)) +
  geom_point(size=6, color='#52FD4D') +
  geom_segment(aes(x=Year, xend=Year, 
                   y=0, yend=Counts), color='#52FD4D') +
  scale_x_continuous(breaks=year_span) +
  geom_smooth(method='lm', se=FALSE, color='#FC0BF0') +
  labs(title='Los Angeles Drug Violations By Year\n(January, 2010 - June, 2019)', 
       caption='Source: https://data.lacity.org') +
  theme(axis.text.y=element_text(color='red', size=12, face='bold'),
        axis.text.x=element_text(color='red', size=12, face='bold'),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        plot.title=element_text(color='#52FD4D', face='bold', hjust=0.5))

# 10. Function to plot a  distribution map for drug violations
map_plot <- function(dataset, center) {
  m <- ggmap(get_googlemap(center=c(lon=center[1], lat=center[2]), 
                           maptype='roadmap', scale=2, zoom=10))
  m + 
    geom_point(aes(x=Longitude, y=Latitude), 
               data=dataset, color='#F90359', size=1) +
    stat_density2d(data=dataset, 
                   aes(x=Longitude, y=Latitude, alpha=..level..),
                   size=0.01, bins=8, geom='polygon') +
    scale_fill_gradient(low='#18B4B2', high='#F90359') +
    scale_alpha(range=c(0.5, 0.8), guide=FALSE)
}

# 11. Create a list of data frames which contains the terms 'Narcotic Drug Laws' and years of interest
# 12. Feed the each of data frames in the list in the plot function to draw its map
drugs <- list()
d_plot <- list()
for(year in year_span) {
  drugs[[year]] <- select(filter(df, Charge_Group_Description=='Narcotic Drug Laws', 
                                 str_sub(Arrest_Date, 1, 4)==as.character(year)), 
                          `Latitude`, `Longitude`)
  d_plot[[year]] <- map_plot(drugs[[year]], c(-118.3533783, 34.0274463)) +
    annotate('text', x=-118.1, y=34.35, 
             label=year, color='#FC0BF0', size=12)
}

# 13. Plot a geographical map of drug violations:
drugs <- list()
d_plot <- list()
for(year in year_span) {
  drugs[[year]] <- select(filter(df, Charge_Group_Description=='Narcotic Drug Laws', 
                                 str_sub(Arrest_Date, 1, 4)==as.character(year)), 
                          `Latitude`, `Longitude`)
  d_plot[[year]] <- map_plot(drugs[[year]], c(-118.3533783, 34.0274463)) +
    annotate('text', x=-118.1, y=34.35, 
             label=year, color='#FC0BF0', size=12)
}

fig_1 <- ggarrange(d_plot[[2010]], d_plot[[2011]], nrow=2,
                   d_plot[[2012]], d_plot[[2013]], ncol=2)
annotate_figure(fig_1,
                top=text_grob('Geographical maps of drug violations from 2010 to 2013', 
                              color='#52FD4D', face='bold', hjust=0.5, size=20),
                bottom=text_grob('Source: https://data.lacity.org',
                                 hjust=1, x=1, face='italic', size=14))

fig_2 <- ggarrange(d_plot[[2014]], d_plot[[2015]], nrow=2,
                   d_plot[[2016]], d_plot[[2017]], ncol=2)
annotate_figure(fig_2,
                top=text_grob('Geographical maps of drug violations from 2014 to 2017', 
                              color='#52FD4D', face='bold', hjust=0.5, size=20),
                bottom=text_grob('Source: https://data.lacity.org',
                                 hjust=1, x=1, face='italic', size=14))

fig_3 <- ggarrange(d_plot[[2010]], d_plot[[2018]], nrow=1, ncol=2)
annotate_figure(fig_3,
                top=text_grob('Geographical maps of drug violations in 2010 and 2018', 
                              color='#52FD4D', face='bold', hjust=0.5, size=20),
                bottom=text_grob('Source: https://data.lacity.org',
                                 hjust=1, x=1, face='italic', size=14))




