# setwd("/mnt/windows/Dropbox/4. Archive/Algorithms/Learning R")

# DATA EXPLORATION: generates leads
# 1. Look at the data
# 2. Generate hypothesis
# 3. Test them 
# 4. Repeat it

# ggplot2: a grammar of graphics
#install.packages("tidyverse")
library(tidyverse)
# Be explicit about where a function comes from:
# package::function()
# ggplot2::ggplot()

# DATA FRAME:
# : Rectangular collection of variables (in columns) and observations

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy))

# Begin the plot with `ggplot()`
# First argument: dataset
# Layers: geom_points adds a layer of points (scatterplot)
# Each geom function takes a mapping argument: how variables are mapped to visual properties?
# Always paired with `aes()`, which specify which variables to map to x or y-axis.

# AESTHETIC: visual property of the objects displayed

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, color = class))

# Other options: size, alpha (transparency), shape (only six types)

# FACETS: display various plots each with one subset of the data

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_wrap(~ class, nrow = 2)

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ cyl)

# GEOM:
# : Geometrical object that a plot uses to represent data

ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy))

ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv, color = drv))

# Another way of organizing, passing the mapping directly to ggplot
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth()

# Yet another example
ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(color = drv)) +
  geom_smooth(mapping = aes(linetype = drv, color = drv), se = FALSE)

# STATISTICAL TRANSFORMATIONS

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut))

# Here, the count is not a variable in diamonds, it is a new value!
# Bar charts, histograms, and frequency polygons bin your data
# Smoothers fit a model to your data and then plot predictions
# Boxplots compute a summary of the distribution

# Which algorithm calculate new values?
# Stat: statistical transformation

ggplot(data = diamonds) +
  stat_count(mapping = aes(x = cut))

# Is the same plot as above

demo <- tribble(
  ~a,      ~b,
  "bar_1", 20,
  "bar_2", 30,
  "bar_3", 40
)

ggplot(data = demo) + 
  geom_bar(mapping = aes(x = a, y = b), stat = "identity")

ggplot(data = diamonds) +
  geom_bar(
    mapping = aes(x = cut, y = ..prop.., group = 1)
  )

ggplot(data = diamonds) +
  stat_summary(
    mapping = aes(x = cut, y = depth),
    fun.ymin = min,
    fun.ymax = max,
    fun.y = median
  )

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, y = ..prop..))
ggplot(data = diamonds) +
  geom_bar(
    mapping = aes(x = cut, fill = color, y = ..prop..)
  )

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, color = cut))
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = cut))

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = clarity))

ggplot(data = diamonds) +
  geom_bar(
    mapping = aes(x = cut, fill = clarity),
    position = "dodge"
  )

# COORDINATE SYSTEMS

# coord_flip() switches the x- and y-axis
# coord_quickmap() sets the aspect ratio for maps (for sptaial data)

nz <- map_data("nz")
ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", color = "black") +
  coord_quickmap()

# coord_polar() uses polar coordinates

bar <- ggplot(data = diamonds) +
  geom_bar(
    mapping = aes(x = cut, fill = cut),
    show.legend = FALSE,
    width = 1
  ) +
  theme(aspect.ratio = 1) +
  labs(x = NULL, y = NULL)

bar + coord_polar()

# TEMPLATE

# ggplot(data = <DATA>) +
#   <GEOM_FUNCTION>(
#     mapping = aes(<MAPPINGS>),
#     stat = <STAT>,
#     position = <POSITION>
#   ) +
#   <COORDINATE_FUNCTION> +
#   <FACET_FUNCTION>