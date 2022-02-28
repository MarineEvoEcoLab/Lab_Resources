---
title: "readme"
author: "Jacob M. Green"
date: "9/8/2020"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Objective 1: EecSeq laboratory protocol optimization and improvement
There are three key elements in the EecSeq protocol that can be optimized to improve efficiency: probe
and insert length, probe and capture pool diversity, and the ratio of probes to genomic library during
hybridization. Optimizing all three parameters will allow EecSeq users to: (1) maximize the number of
sequenced exomic basepairs and on-target reads, (2) maximize the number of individuals that can be
sequenced simultaneously while using minimal amounts of probes, and therefore (3) greatly reduce costs.

* *Approach:* Using adult oysters, we will construct genomic DNA libraries with 180 bp, 270 bp, and 360
bp inserts and we will create cDNA probe libraries with the same size intervals. Captures will be
performed using eight adult oysters and probes will be made from 12 individuals. Hybridizations will
be performed with a full factorial cross of insert size and probe size with 3 replicate captures per
treatment. Capture specificity, sensitivity, and reproducibility will be compared across treatments.
* *Outcome:* Longer probes may be able to compensate for intron/exon boundaries by maximizing the
number of exonic basepairs per probe and allowing for stronger hybridization between probe and
genomic DNA fragment. Longer probes will also allow for more mismatches between probe and target,
helping to facilitate captures across polymorphic species.

*Goals*

A) To quantify the role of probe and insert length in exome capture efficiency and specificity
B) To determine the optimal level of probe and capture pool diversity
C) To optimize the ratio of probes to genomic library for efficient hybridization and capture

Each subdirectory represents respective objective goals outlined in the EAGER grant. Within each subdirectory will contain a readme outlining the specific approach, protocols, data, and metadata associated with the subset of the project. If there are any questions please direct them to Jacob Green, gree9242@uri.edu.
