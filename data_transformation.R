# 3. DATA TRANSFORMATION

## 3.1 INTRODUCTION

library(nycflights13)
library(tidyverse)

# Tibbles are data frames tweaked for the tidyverse
View(flights) # shows all the data

# dplyr key functions:
# filter()    -> pick observations by their values
# arrange()   -> reorder the rows
# select()    -> pick variables by their names
# mutate()    -> create new variables with functions of existing variables
# summarize() -> collapse many values down to a single summary

# Arguments: 1. data frame, 2. what to do with the variables -> results in a new data frame

# Can use `group_by()` to change the scope of each function to operate on the dataset group-by-group

## 3.2 FILTER

filter(flights, month == 1, day == 1)

# Or operator: |
filter(flights, month == 11 | month == 12)
filter(flights, month %in% c(11, 12))

# Flights that weren't delayed by more than two hours
filter(flights, !(arr_delay > 120 | dep_delay > 120))

# Filter only includes rows where the condition is TRUE
#        excludes both FALSE and NA (see is.na())

### 3.2.1.a
filter(flights, arr_delay >= 120)

### 3.2.1.b 
filter(flights, dest == "IAH" | dest == "HOU")

### 3.2.1.c
filter(flights, carrier == "UA" | carrier == "AA" | carrier == "DL")

### 3.2.1.d
filter(flights, month %in% c(7,8,9))

### 3.2.1.e
filter(flights, arr_delay > 120, dep_delay <= 0)

### 3.2.1.f
filter(flights, dep_delay >= 60, arr_delay <= 30)

### 3.2.1.g
filter(flights, dep_time >= 0, dep_time <= 600)

### 3.2.2
filter(flights, between(dep_time, 0, 600))

### 3.2.3
filter(flights, is.na(dep_time))

### 3.2.4
# NA^0 = 1
# NA | TRUE is true 
# FALSE & NA doesn't select anything
# NA + ALMOST anything is not NA

## 3.3 ARRANGE

arrange(flights, year, month, day)
arrange(flights, desc(arr_delay))

### 3.3.1
arrange(flights, desc(is.na(dep_time)))

### 3.3.2
arrange(flights, desc(dep_delay)) # Most delayed
arrange(flights, dep_delay) # Left earliest

### 3.3.3
arrange(flights, air_time)

### 3.3.4
View(arrange(flights, desc(distance))) # Longest
View(arrange(flights, distance)) # Shortest

## 3.4 SELECT

select(flights, year, month, day)
select(flights, year:day)
select(flights, -(year:day))

# Useful functions:
# starts_with("abc")
# ends_with("abc")
# contains("ijk")
# matches("(.)\\1")
# num_range("x", 1:3)

rename(flights, tail_num = tailnum)
select(flights, time_hour, air_time, everything())

### 3.4.1
select(flights, dep_time)
select(flights, -everything(), dep_time)

### 3.4.2
select(flights, dep_delay, dep_delay)

### 3.4.3
vars <- c("year", "month", "day", "dep_delay", "arr_delay")
select(flights, one_of(vars))

### 3.4.4
select(flights, contains("TIME"))

## 3.5 MUTATE

flights_sml <- select(flights,
                      year:day,
                      ends_with("delay"),
                      distance,
                      air_time)
mutate(flights_sml,
       gain = arr_delay - dep_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours)

# To keep only new variables:
transmute(flights,
          gain = arr_delay - dep_delay,
          hours = air_time / 60,
          gain_per_hour = gain / hours)

transmute(flights,
          dep_time,
          hour = dep_time %/% 100,
          minute = dep_time %% 100)

### 3.5.1
flights <- mutate(flights,
                  dep_time_mins = dep_time %/% 100 * 60 + dep_time %% 100,
                  sched_dep_time_mins = sched_dep_time %/% 100 * 60 +
                  sched_dep_time %% 100)
select(flights, starts_with('dep_time'), starts_with('sched'))

### 3.5.2
transmute(flights,
          air_time,
          arr_time - dep_time)

flights %>%
  mutate(arr_time_mins = arr_time %/% 100 * 60 + arr_time %% 100,
         flight_time = arr_time_mins - dep_time_mins)

select(flights, air_time, flight_time)

### 3.5.3 
select(flights, dep_time, sched_dep_time, dep_delay)
transmute(flights,
          dep_time,
          sched_dep_time + dep_delay)

### 3.5.4

flights %>%
  mutate(total_delay = dep_delay + arr_delay) %>%
  arrange(desc(total_delay),total_delay) %>%
  select(total_delay) %>%
  head(10)

### 3.5.5

1:3 + 1:10

### 3.5.6

sin(pi/4)
tan(pi/4)
cos(pi/4)
acos(sqrt(2)/2)

## 3.6 SUMMARIZE

# Collapses a data frame into a single row.
summarize(flights, delay = mean(dep_delay, na.rm = TRUE))

by_day <- group_by(flights, year, month, day)
summarize(by_day, delay = mean(dep_delay, na.rm = TRUE))

# Relationship between distance and ave. delay
by_dest <- group_by(flights, dest)
delay <- summarize(by_dest,
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE))
delay <- filter(delay, count > 20, dest != "HNL")

ggplot(data = delay, mapping = aes(x = dist, y = delay)) +
  geom_point(aes(size = count), alpha = 1/3) +
  geom_smooth(se = FALSE)

# Using Pipe: %>%
delays <- flights %>%
  group_by(dest) %>%
  summarize(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
  ) %>%
  filter(count > 20, dest != "HNL")

# How to deal with missing values?
not_cancelled <- flights %>%
  filter(!is.na(dep_delay), !is.na(arr_delay))

not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(mean = mean(dep_delay))

# Using only the groups with more than 25 entries:
delays <- not_cancelled %>%
  group_by(tailnum) %>%
  summarize(
    delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )

delays %>%
  filter(n > 25) %>%
  ggplot(mapping = aes(x = n, y = delay)) +
    geom_point(alpha = 1/10)

# Useful functions:
# mean(x)
# median(x)
# sd (standard deviation)
# IQR (interquartile range)
# mad (median absoluve deviation)
# min(x)
# quantile(x, 0.25)
# first(x)
# nth(x, 2)
# last(x)
# n()
# n_distinct(x)
# ungroup()
