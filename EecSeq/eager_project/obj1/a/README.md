---
title: "readme"
author: "Jacob M. Green"
date: "9/8/2020"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Objective 1A: To quantify the role of probe and insert length in exome capture efficiency and specificity

In the EecSeq proof-of-concept, the insert size (size of the gDNA fragment) and probe length (size of cDNA fragment) were both fragmented to a modal peak size of 180 bp. This small size was intended to limit the interaction of intron/exon boundaries during cDNA and gDNA hybridization; however, increasing the insert size will make sequencing more efficient by reducing overlap between forward and paired-end reads. Most modern Illumina sequencers produce 100 bp or 150 bp reads, therefore increasing the fragment size to larger than the read size removes redundancy in sequencing and allows for more exomic basepairs sequenced per run.

* *Approach:* Using adult oysters, we will construct genomic DNA libraries with 180 bp, 270 bp, and 360 bp inserts and we will create cDNA probe libraries with the same size intervals. Captures will be performed using eight adult oysters and probes will be made from 12 individuals. Hybridizations will be performed with a full factorial cross of insert size and probe size with 3 replicate captures pertreatment. Capture specificity, sensitivity, and reproducibility will be compared across treatments.

* *Outcome:* Longer probes may be able to compensate for intron/exon boundaries by maximizing the number of exonic basepairs per probe and allowing for stronger hybridization between probe and genomic DNA fragment. Longer probes will also allow for more mismatches between probe and target, helping to facilitate captures across polymorphic species.

There are two specific areas of the probe and capture pool creation where we modify fragment size. For gDNA, this occurs after DNA purification in the column and before hybridization with the mRNA probe pools. We fragment gDNA through sonication 