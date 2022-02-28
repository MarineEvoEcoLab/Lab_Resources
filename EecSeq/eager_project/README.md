---
title: "README"
author: "Jacob M. Green"
date: "9/8/2020"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## EAGER Project 

*Problem Statement:*Understanding the interaction between genotype, phenotype, and the environment is one of the greatest challenges in population biology. Even with the transformative outputs of nextgeneration sequencing, there is a two-fold sampling problem limiting progress in ecological genomics: 

1) sampling enough individuals, i.e. assessing enough genotypes for accurate allele frequency estimates and
2) sampling the correct part of the genome, i.e. sequencing base pairs that lead to phenotypic change. 

For some organisms with small, sequenced, and well-annotated genomes, the whole genome can be resequenced for multiple individuals; however, for most organisms and research budgets, some sort of genome reduction is needed to investigate the genetic basis of adaptation, especially in wild populations responding to changing environments.

*Solution:* We have recently developed a novel approach that combines transcriptome sequencing with in situ exon probe synthesis, capitalizing on the benefits of exome capture without the biases of sequencing mRNA directly or the resource investment of traditional exome capture. Briefly, the Expressed Exome Capture Sequencing (EecSeq) method starts with a traditional mRNA library preparation with specialized adapters. The mRNA library is then normalized, restriction enzymes are used to remove adapters, and the probes are biotinylated. Standard genomic DNA (gDNA) libraries are then hybridized with the probes, selectively enriching exon sequences. Probes are removed and the exome capture library is ready for sequencing. A proof of concept was recently published (Puritz and Lotterhos 2018) demonstrating that EecSeq effectively captures exome sequences, and the proposed research will transform a proof of concept into readily available method that can be applied to any organism. 

The research has three objectives:

1) To optimize probe length, diversity, and hybridization to enhance specificity and efficiency
2) To directly compare and validate EecSeq with traditional exome capture, WGS, and RNAseq
3) To develop a de novo assembly method for an open source EecSeq bioinformatic pipeline

Results from the above objectives will empower three significant outcomes: an improved set of adapters immune to Illumina index hopping, an efficient step-by-step laboratory protocol, and a de novo bioinformatic pipeline for EecSeq that incorporates locus assembly and annotation for any organism.

Each objective can be found in the subdirectories below. Each subdirectory will contain a README describing the objective of the project and more subdirectories for smaller objective goals.