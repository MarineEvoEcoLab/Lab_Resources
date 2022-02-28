---
title: "readme"
author: "Jacob M. Green"
date: "9/8/2020"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Objective 1B: To determine the optimal level of probe and capture pool diversity
Traditional exome capture relies on synthesized baits, usually designed from a reference genome with only one reference sequence per exon (no genetic polymorphisms in the baits). This means that divergent alleles from the reference may not be captured. Reduced bait diversity may also limit the number of individuals that can be captured simultaneously because samples that are less divergent from the probes may outcompete more divergent samples, leading to uneven levels of coverage across samples. Portik et al. (2016) found that for each percent increase of pairwise divergence, missing data increased 4.76%, sensitivity decreased 4.57%, and specificity decreased 3.26%. Even with well-designed, commerciall available capture kits for human exon capture, Sulonen et al. (2011) found that allele balances for heterozygous variants tended to have more reference bases than variant bases in the heterozygous variant position across all methods for probe developmentWith EecSeq, exome probes can be created from any number of individuals, encompassing multiple levels of sequence diversity and may enable the multiplexing of more individuals than traditional exome capture.

* *Approach:* Using the optimal insert and probe length determined in Objective 1.A, we will construct cDNA probe libraries and genomic DNA libraries with from 12 different individuals. We create replicate probe and capture pools with 4, 6, 8, and 12 individuals, and hybridizations will be performed cross all combinations of probe and capture pool composition with the exception of four extreme values. Capture specificity, sensitivity, and reproducibility will be compared across treatments. Resulting genotypes for each individual will also be compared across treatments to assess allelic capture diversity.

* *Outcome:* Probe pools made from more individuals will likely be able to evenly capture larger number of individuals in hybridization; however, there may be a point of limited marginal returns for including individuals in probe pools. It is also likely that more diverse probe pools with be better at capturing divergent alleles, leading to more accurate genotype calls at exon loci.
