---
title: "DEI Web Resources Folder"
author: "Jacob M. Green"
date: "6/11/2020"
---

This folder will function to pool our resources covering diversity, equity, and inclusion. In this folder you will find a subdirectory to store pdf or other pritned documents. You will also find a csv file that contains links to web resources. If you wish to add to either the csv or papers feel free to do so. The readme.Rmd should update the csv list. If you have any question please reach out to Jacob Green.

Here is a current list of online resources regarding diversity, equity, and inclusion topics for the Puritz lab.

```{r message=FALSE, warning=FALSE, include=FALSE}
library(readr)
dei_web_resources <- read_csv("dei_web_resources.csv")
View(dei_web_resources)
```

```{r echo=FALSE}
library(knitr)
kable(dei_web_resources)
```