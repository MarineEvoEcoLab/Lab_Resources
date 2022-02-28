---
title: "readme"
author: "Jacob M. Green"
date: "9/8/2020"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Objective 1C: To optimize the ratio of probes to genomic library for efficient hybridization and capture

Along with varying probe/insert length and probe/capture pool diversity, the ratio probes to capture library can be varied to help enhanced target capture. Commercially available kits vary between recommended amounts of 100 ng to 500 ng per library (or individual). The original EecSeq publication was based on a capture of 500 ng of genomic DNA library with 500 ng of probes, and during initial experimentation as little as 100 ng of genomic library was successfully captures with 100 ng of probes, though these were never sequenced. Increasing the relative amount of genomic library in hybridizations helps to ensure that adequate amounts of target sequences are present in the reaction, leading to even enrichment across samples. With EecSeq, probes are not equally distributed across all exon loci, so increasing the amount of genomic library relative to probes may help to also even coverage across the exome if total exome capture is the desired outcome. However, if a study is particularly focused on loci that are highly expressed, using less genomic DNA relative to capture probes may help produce a more targeted capture, allowing for more samples to be sequenced for the same cost.

* *Approach:* We will construct cDNA probe libraries and genomic DNA libraries using the optimal insert and probe length determined in Objective 1.A and the optimal level of probe and capture pool diversity determined in Objective 1.B. We will perform three replicate hybridizations and captures using a full cross of three different amounts of probes (100 ng, 250 ng and 500 ng), and three different amounts of genomic DNA library per individual (100 ng, 250 ng, and 500 ng). Across all treatments, we will compare capture specificity, sensitivity, and reproducibility among the whole exome as well as a highly expressed subset of the exome.

* *Outcome:* We expect that increasing the ratio of capture library to probes will result in more even across samples and all loci. Across only highly expressed genes, we expect that increased amounts of genomic library will have a reduced effect, if any, on coverage levels and reproducibility. Reducing both the amount of probe material and the amount of captured library used per hybridization will increase overall cost efficiency.