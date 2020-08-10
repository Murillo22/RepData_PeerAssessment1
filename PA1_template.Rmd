---
title: "Course Project"
author: "Alexis"
date: "10/8/2020"
output: html_document
---
## Reproducible Research: Peer Assessment 1

This is an R Markdown document to read activity monitoring data and run some analysis.

## Loading and preprocessing the data

Let's download the zip file and unzip it.

```{r eval=FALSE}
fileURL<-"https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
download.file(fileURL,"data.zip")
unzip(zipfile="data.zip",exdir="./TestR_Data")
```
Set the directory where the file was unzip and verify the presence of the file
```{r eval=FALSE}
setwd("./TestR_Data/")
dir()
```
Read the CSV file and identify the na elements
```{r}
read.csv("activity.csv",na=NA)->data
```
## What is mean total number of steps taken per day?
Remove na to create a available data to be analyzed
```{r}
data[which(!is.na(data$steps)),]->dataAvail
```
Calculating the total number of steps per day
```{r}
aggregate(steps~date,dataAvail,sum)->totalStepsPerDay
totalStepsPerDay
```
Make a histogram of the total number of steps taken each day
```{r}
hist(totalStepsPerDay$steps, xlab="Total Steps per Day", main="Histogram of Steps per Day")
```

Calculate and report the mean and median of the total number of steps taken per day
1. for Mean
```{r}
mean(totalStepsPerDay$steps)
```
2. for Median
```{r}
median(totalStepsPerDay$steps)
```
## What is the average daily activity pattern?
Aggregate steps information by interval, calculating a mean for each one.
```{r}
aggregate(steps~interval,data,mean)->meanInterval
```
Making a time series plot
```{r}
plot(meanInterval,type="l",xlab="5-min Interval",ylab="Steps",main="Time series plot")
```

Which 5-min interval, contains the maximum number of steps?
```{r}
meanInterval[which(meanInterval$steps==max(meanInterval$steps)),]
```

## Imputing missing values

Calculating and report the total number of missing values
```{r}
is.na(data)->missed
nrow(missed[which(missed=="TRUE"),])
```
Filling all of the missing values in the dataset. 
Let's use mean values for each interval.
```{r}
transform(data,steps=ifelse(is.na(data$steps),meanInterval$steps[match(data$interval,meanInterval$interval)],data$steps))->impData
```
```impData``` represents the new dataset with missing data filled in.

Make a histogram of the total number of steps taken each day with this new dataset

1. Calculating the total number of steps per day
```{r}
aggregate(steps~date,impData,sum)->totalStepsImp
totalStepsImp
```
2. Making the histogram
```{r}
hist(totalStepsImp$steps, xlab="Total Steps per Day", main="Histogram of Steps per Day")
```

3. Calculate and report the mean and median of the total number of steps taken per day
3.1. for Mean
```{r}
mean(totalStepsImp$steps)
```
3.2. for Median
```{r}
median(totalStepsImp$steps)
```
## Are there differences in activity patterns between weekdays and weekends?
Creating a new factor variable indicating if the date is weekend or weekday
```{r}
#Converting date information in date class
as.Date(impData$date)->impData$date
#applying weekdays function
sapply(impData$date,weekdays)->impData$day
#transforming data
transform(impData,day=ifelse(impData$day=="sábado","weekend",ifelse(impData$day=="domingo","weekend","weekday")))->impDataDay
```
Make a panel plot containing a time series plot
```{r}
#create a frame with mean data for day and intervals
meanStepsByDay <- aggregate(steps ~ interval + day, impDataDay, mean)
#plotting the graph
library(ggplot2)
ggplot(meanStepsByDay,aes(interval,steps))->g
g+geom_line()+facet_grid(day~.)+ggtitle("Average Daily Activity")+xlab("5-min Interval")
```

