#!/usr/bin/env bash
export LC_ALL=en_US.UTF-8
export SHELL=bash

##########dDocent##########
VERSION='2.7.6'
#This script serves as an interactive bash wrapper to QC, assemble, map, and call SNPs from double digest RAD (SE or PE), ezRAD (SE or PE) data, or SE RAD data.
#It requires that your raw data are split up by tagged individual and follow the naming convention of:

#Pop_Sample1.F.fq and Pop_Sample1.R.fq

#Prints out title and contact info
echo -e "dDocent" $VERSION "\n"
echo -e "Contact jpuritz@uri.edu with any problems \n\n "

###Code to check for the required software for dDocent

echo "Checking for required software"
DEP=(freebayes mawk bwa samtools vcftools rainbow gnuplot seqtk cd-hit-est bamToBed bedtools parallel vcfcombine pearRM fastp)
NUMDEP=0
for i in "${DEP[@]}"
do
	if which $i &> /dev/null; then
		foo=0
	else
    		echo "The dependency" $i "is not installed or is not in your" '$PATH'"."
    		NUMDEP=$((NUMDEP + 1))
	fi
done

SAMV1=$(samtools 2>&1 >/dev/null | grep Ver | sed -e 's/Version://' | cut -f2 -d " " | sed -e 's/-.*//' | cut -c1)
SAMV2=$(samtools 2>&1 >/dev/null | grep Ver | sed -e 's/Version://' | cut -f2 -d " " | sed -e 's/-.*//' | cut -c3)
	if [ "$SAMV1"  -ge "1" ]; then
		if [ "$SAMV2"  -lt "3" ]; then
        	echo "The version of Samtools installed in your" '$PATH' "is not optimized for dDocent."
        	echo "Please install at least version 1.3.0"
			echo -en "\007"
			echo -en "\007"
			exit 1
		fi
	
	else
		    echo "The version of Samtools installed in your" '$PATH' "is not optimized for dDocent."
        	echo "Please install at least version 1.3.0"
			echo -en "\007"
			echo -en "\007"
			exit 1
	fi

RAINV=(`rainbow | head -1 | cut -f2 -d' ' `)	
	if [[ "$RAINV" != "2.0.2" && "$RAINV" != "2.0.3" && "$RAINV" != "2.0.4" ]]; then
        	echo "The version of Rainbow installed in your" '$PATH' "is not optimized for dDocent."
        	echo -en "\007"
			echo -en "\007"
			echo -en "\007"
        	echo "Is the version of rainbow installed newer than 2.0.2?  Enter yes or no."
			read TEST
			if [ "$TEST" != "yes" ]; then 
        		echo "Please install a version newer than 2.0.2"
        		exit 1
        	fi
        fi
FREEB=(`freebayes | grep -oh 'v[0-9].*' | cut -f1 -d "." | sed 's/v//' `)	
	if [ "$FREEB" != "1" ]; then
        	echo "The version of FreeBayes installed in your" '$PATH' "is not optimized for dDocent."
        	echo "Please install at least version 1.0.0"
        	exit 1
        fi  
SEQTK=( `seqtk 2>&1  | grep Version | cut -f2 -d ":" |  sed 's/1.[0-9]-r//g' | sed 's/-dirty//g' `)
	if [ "$SEQTK" -lt "102" ]; then
		echo "The version of seqtk installed in your" '$PATH' "is not optimized for dDocent."
        	echo "Please install at least version 1.2-r102-dirty"
        	exit 1
	fi
	
VCFTV=$(vcftools | grep VCF | grep -oh '[0-9]*[a-z]*)$' | sed 's/[a-z)]//')
	if [ "$VCFTV" -lt "10" ]; then
        	echo "The version of VCFtools installed in your" '$PATH' "is not optimized for dDocent."
        	echo "Please install at least version 0.1.11"
        	exit 1
        elif [ "$VCFTV" == "11" ]; then
                VCFGTFLAG="--geno" 
        elif [ "$VCFTV" -ge "12" ]; then
                VCFGTFLAG="--max-missing"
	fi
BWAV=$(bwa 2>&1 | mawk '/Versi/' | sed 's/Version: //g' | sed 's/0.7.//g' | sed 's/-.*//g' | cut -c 1-2)
	if [ "$BWAV" -lt "13" ]; then
        	echo "The version of bwa installed in your" '$PATH' "is not optimized for dDocent."
        	echo "Please install at least version 0.7.13"
        	exit 1
	fi

BTC=$( bedtools --version | mawk '{print $2}' | sed 's/v//g' | cut -f1,2 -d"." | sed 's/2\.//g' )
	if [ "$BTC" -ge "26" ]; then
		BEDTOOLSFLAG="NEW"
		elif [ "$BTC" == "23" ]; then
		BEDTOOLSFLAG="OLD"
		elif [ "$BTC" != "23" ]; then
		echo "The version of bedtools installed in your" '$PATH' "is not optimized for dDocent."
		echo "Please install version 2.23.0 or version 2.26.0 and above"
		exit 1	
	fi
	
FASTP=$(fastp -v 2>&1 | cut -f2 -d " ")
FASTP1=$(echo $FASTP | cut -f1 -d ".")
FASTP2=$(echo $FASTP | cut -f2 -d ".")
FASTP3=$(echo $FASTP | cut -f3 -d ".")
	if [ "$FASTP1" -lt "2" ]; then
		if [ "$FASTP2" -lt "20" ]; then
			if [ "$FASTP2" -lt "5" ]; then
				echo "The version of fastp installed in your" '$PATH' "is not optimized for dDocent."
				echo "Please install version 0.19.5 or above"
				exit 1
			fi
		fi
	fi
	
if ! sort --version | fgrep GNU &>/dev/null; then
	sort=gsort
else
	sort=sort
fi

if [ $NUMDEP -gt 0 ]; then
	echo -e "\nPlease install all required software before running dDocent again."
	exit 1
else
	echo -e "\nAll required software is installed!"
fi

#This code checks for individual fastq files follow the correct naming convention and are gziped
TEST=$(ls *.fq 2> /dev/null | wc -l )
if [ "$TEST" -gt 0 ]; then
echo -e "\ndDocent is now configured to work on compressed sequence files.  Please run gzip to compress your files."
echo "This is as simple as 'gzip *.fq'"
echo "Please rerun dDocent after compressing files."
exit 1
fi

#Count number of individuals in current directory
NumInd=$(ls *.F.fq.gz 2> /dev/null | wc -l)
NumInd=$(($NumInd - 0))

#Test for file limits for current user and reset if necessary

Flimit=$(ulimit -n)
export Flimit

if [ "$Flimit" != "unlimited" ]; then
        Nlimit=$(( $NumInd * 10 ))
        if [ "$Flimit" -lt "$Nlimit" ]; then
                ulimit -n $Nlimit
        fi
fi

#Create list of sample names
ls *.F.fq.gz > namelist 2> /dev/null
sed -i'' -e 's/.F.fq.gz//g' namelist
#Create an array of sample names
NUMNAMES=$(mawk '/_/' namelist | wc -l)

if [ "$NUMNAMES" -eq "$NumInd" ]; then
	NAMES=( `cat "namelist" `)
else
	echo "Individuals do not follow the dDocent naming convention."
	echo "Please rename individuals to: Locality_Individual.F.fq.gz"
	echo "For example: LocA_001.F.fq.gz"
	exit 1
fi

if [[ "$1" == "help" || "$1" == "-help" || "$1" == "--help" || "$1" == "-h" || "$1" == "--h" ]]; then

	echo -e "\nTo run dDocent, simply type '"dDocent"' and press [ENTER]"
	echo -e "\nAlternatively, dDocent can be run with a configuration file.  Usuage is:"
	echo -e "\ndDocent config_file\n\n"
	exit 0
fi

#Wrapper for main program functions.  This allows the entire file to be read first before execution
main(){
##########User Input Section##########
#This code gets input from the user and assigns variables
######################################

#Sets a start time variable
STARTTIME=$(date)


echo -e "\ndDocent run started" $STARTTIME "\n"


#dDocent can now accept a configuration file instead of running interactively
#Checks if a configuration file is being used, if not asks for user input
if [ -n "$1" ]; then
	CONFIG=$1
	if [ ! -f $CONFIG ]; then
		echo -e "\nThe configuration file $CONFIG does not exist."
		exit 1
	fi
	
	NUMProc=$(grep -A1 Processor $CONFIG 2> /dev/null | tail -1 ) 
	if [[ $NUMProc -lt 999999 && $NUMProc -gt 1 ]]; then 
		MAXMemory1=$(grep -A1 Memory $CONFIG | sed 's/[g,G]//g' | tail -1)
	else
		echo -e "\nConfiguration file is not properly configured.  Please see example on dDocent.com or the dDocent GitHub page."
		exit 1
	fi
	MAXMemory=$(( $MAXMemory1 / $NUMProc ))G
	if [[ "$OSTYPE" == "darwin"* ]]; then
		MAXMemory=0
		MAXMemory1=0
	fi
	TRIM=$(grep -A1 Trim $CONFIG | tail -1)
	ASSEMBLY=$(grep -A1 '^Assembly' $CONFIG | tail -1)
	CUTOFF=$(grep -A1 'Minimum within' $CONFIG  2> /dev/null | tail -1)
	if [[ $CUTOFF -lt 9999 && $CUTOFF -gt 0 ]]; then 
		CUTOFF2=$(grep -A1 'Minimum number' $CONFIG | tail -1)
	else
		if [ "$ASSEMBLY" == "yes" ]; then
			echo -e "\nConfiguration file is not properly configured.  Please see example on dDocent.com or the dDocent GitHub page."
			exit 1
		fi
	fi
	ATYPE=$(grep -A1 Type $CONFIG | tail -1)
	simC=$(grep -A1 Simi $CONFIG | tail -1)
	MAP=$(grep -A1 Mapping_R $CONFIG | tail -1)
	optA=$(grep -A1 _Match $CONFIG | tail -1)
	optB=$(grep -A1 MisMatch $CONFIG | tail -1)
	optO=$(grep -A1 Gap $CONFIG | tail -1)
	SNP=$(grep -A1 SNP $CONFIG | tail -1)
	MAIL=$(grep -A1 Email $CONFIG | tail -1)
	
	if [ "$ASSEMBLY" == "yes" ] && [[ -z $CUTOFF || -z $CUTOFF2 ]]; then
		
		echo "dDocent will require input during the assembly stage.  Please wait until prompt says it is safe to move program to the background."	
	else	
		#Prints instructions on how to move analysis to background and disown process
		echo "At this point, all configuration information has been entered and dDocent may take several hours to run." 
		echo "It is recommended that you move this script to a background operation and disable terminal input and output."
		echo "All data and logfiles will still be recorded."
		echo "To do this:"
		echo "Press control and Z simultaneously"
		echo "Type 'bg' without the quotes and press enter"
		echo "Type 'disown -h' again without the quotes and press enter"
		echo ""
		echo "Now sit back, relax, and wait for your analysis to finish"
	
	fi

else
	GetInfo 
fi

#Creates (or appends to) a dDcoent run file recording variables
echo "Variables used in dDocent Run at" $STARTTIME >> dDocent.runs
echo "Number of Processors" >> dDocent.runs
echo $NUMProc >> dDocent.runs
echo "Maximum Memory" >> dDocent.runs
echo $MAXMemory1 | sed 's/[g,G]//g' >> dDocent.runs
echo "Trimming" >> dDocent.runs
echo $TRIM >> dDocent.runs
echo "Assembly?" >> dDocent.runs
echo $ASSEMBLY >> dDocent.runs
echo "Type_of_Assembly" >> dDocent.runs
echo $ATYPE >> dDocent.runs
echo "Clustering_Similarity%" >> dDocent.runs
echo $simC >> dDocent.runs
if [ -n "$CUTOFF" ]; then
	echo "Minimum within individaul coverage level to include a read for assembly (K1)" >> dDocent.runs
	echo $CUTOFF >> dDocent.runs
else
	echo "Minimum within individaul coverage level to include a read for assembly (K1)" >> dDocent.runs
	echo "CUTOFF1_NOTSET" >> dDocent.runs
fi
if [ -n "$CUTOFF2" ]; then
	echo "Minimum number of individuals a read must be present in to include for assembly (K2)" >> dDocent.runs
	echo $CUTOFF2 >> dDocent.runs
else
	echo "Minimum number of individuals a read must be present in to include for assembly (K2)" >> dDocent.runs
	echo "CUTOFF2_NOTSET" >> dDocent.runs
fi
echo "Mapping_Reads?" >> dDocent.runs
echo $MAP >> dDocent.runs
echo "Mapping_Match_Value" >> dDocent.runs
echo $optA >> dDocent.runs
echo "Mapping_MisMatch_Value" >> dDocent.runs
echo $optB >> dDocent.runs
echo "Mapping_GapOpen_Penalty" >> dDocent.runs
echo $optO >> dDocent.runs
echo "Calling_SNPs?" >> dDocent.runs
echo $SNP >> dDocent.runs
echo "Email" >> dDocent.runs
echo $MAIL >> dDocent.runs


##Section of logic statements that dictates the order and function of processing the pipeline

if [[ "$TRIM" == "yes" && "$ASSEMBLY" == "yes" ]]; then
        echo -e "\nTrimming reads and simultaneously assembling reference sequences"        
        TrimReads & 2> trim.log
        Assemble
        #setupRainbow 2> rainbow.log
        wait
fi

if [[ "$TRIM" == "yes" && "$ASSEMBLY" != "yes" ]]; then
        echo -e "\nTrimming reads"
        TrimReads 2> trim.log
fi                
                
if [[ "$TRIM" != "yes" && "$ASSEMBLY" == "yes" ]]; then                
        Assemble
        #setupRainbow 2> rainbow.log
fi

#Checks to see if reads will be mapped.
if [ "$MAP" != "no" ]; then
echo -e "\nUsing BWA to map reads"
	if [ reference.fasta -nt reference.fasta.fai ]; then
        samtools faidx reference.fasta &> index.log
        bwa index reference.fasta >> index.log 2>&1
	fi
#dDocent now checks for trimmed read files before attempting mapping
        if [[ "$MAP" != "no" && ! -f "${NAMES[@]:(-1)}".R1.fq.gz ]]; then
        	echo "dDocent cannot locate trimmed reads files"
        	echo "Please rerun dDocent with quality trimming"
        	exit 1
        fi
#This next section of code checks to see if the reference was assembled by dDocent 
#and if so, modifies the expected insert length distribution for BWA's metric for proper pairing
        if head -1 reference.fasta | grep -e 'dDocent_' reference.fasta 1>/dev/null; then
        	rm lengths.txt &> /dev/null
        	for i in "${NAMES[@]}";
        		do
        		if [ -f "$i.R.fq.gz" ]; then
        		gunzip -c $i.R.fq.gz | head -2 | tail -1 >> lengths.txt
        		fi
        		done	
        	if [ -f "lengths.txt" ]; then
        	MaxLen=$(mawk '{ print length() | "sort -rn" }' lengths.txt| head -1)
        	INSERT=$(($MaxLen * 2 ))
        	INSERTH=$(($INSERT + 100 ))
        	INSERTL=$(($INSERT - 100 ))
        	SD=$(($INSERT / 5))
        	fi
#BWA for mapping for all samples.  As of version 2.0 can handle SE or PE reads by checking for PE read files
        	for i in "${NAMES[@]}"
        	do
        	if [ -f "$i.R2.fq.gz" ]; then
        		bwa mem reference.fasta $i.R1.fq.gz $i.R2.fq.gz -t $NUMProc -a -M -T 20 -A $optA -B $optB -O $optO -R "@RG\tID:$i\tSM:$i\tPL:Illumina" 2> bwa.$i.log | mawk '$6 !~ /[1-9][0-9].[SH]/'| samtools view -@$NUMProc -q 10 -SbT reference.fasta - > $i.bam 2>$i.bam.log
        	else
        		bwa mem reference.fasta $i.R1.fq.gz -t $NUMProc -a -M -T 20 -A $optA -B $optB -O $optO -R "@RG\tID:$i\tSM:$i\tPL:Illumina" 2> bwa.$i.log | mawk '$6 !~ /[1-9][0-9].[SH]/' |samtools view -@$NUMProc -q 10 -SbT reference.fasta - > $i.bam 2>$i.bam.log
        	fi
        	samtools sort -@$NUMProc $i.bam -o $i.bam 
		mv $i.bam $i-RG.bam
		samtools index $i-RG.bam
        	done
        else
        	for i in "${NAMES[@]}"
        	do
        	if [ -f "$i.R2.fq.gz" ]; then
        		bwa mem reference.fasta $i.R1.fq.gz $i.R2.fq.gz -t $NUMProc -a -M -T 20 -A $optA -B $optB -O $optO -R "@RG\tID:$i\tSM:$i\tPL:Illumina" 2> bwa.$i.log | mawk '$6 !~ /[1-9][0-9].[SH]/'| samtools view -@$NUMProc -q 10 -SbT reference.fasta - > $i.bam 2>$i.bam.log
        	else
        		bwa mem reference.fasta $i.R1.fq.gz -t $NUMProc -a -M -T 20 -A $optA -B $optB -O $optO -R "@RG\tID:$i\tSM:$i\tPL:Illumina" 2> bwa.$i.log | mawk '$6 !~ /[1-9][0-9].[SH]/'| samtools view -@$NUMProc -q 10 -SbT reference.fasta - > $i.bam 2>$i.bam.log
        	fi
        	samtools sort -@$NUMProc $i.bam -o $i.bam 
		mv $i.bam $i-RG.bam
		samtools index $i-RG.bam
        	done
        fi
fi

##Creating mapping intervals if needed, CreateIntervals function is defined later in script
#If mapping is being performed, intervals are created automatically

if [ "$MAP" != "no" ]; then
echo "Creating alignment intervals"
ls *F.bam >bamlist.list
CreateIntervals 
fi

##SNP Calling Section of code

if [ "$SNP" != "no" ]; then
	#Create list of BAM files
	ls *F.bam >bamlist.list
	#If mapping is not being performed, but intervals do not exist they are created
	if [[ "$MAP" == "no" && ! -f "filter.merged.bam" ]]; then
		CreateIntervals 
	fi
	#Check for runs from older versions to ensure the recreation of cat-RRG.bam
	if [[ "$MAP" == "no" && -f "map.bed" ]]; then
		CreateIntervals 
	fi
	#Check to make sure interval files have been created
	if [[ "$MAP" == "no" && ! -f "mapped.bed" ]]; then
		bedtools merge -i filter.merged.bam -bed > mapped.bed
	fi
	
	FB2=$(( $NUMProc / 16 ))
	export FB2
	GENOME=$(cut -f2 reference.fasta.fai | mawk '{sum = sum + $1} END {print sum}')
	PFiles=$(( $GENOME / 2500000 ))
	split -n l/$PFiles --additional-suffix=.bed -d mapped.bed mapped. 


	echo "Using FreeBayes to call SNPs"

	#Creates a population file to use for more accurate genotype calling
	
	cut -f1 -d "_" namelist > p
	paste namelist p > popmap
	rm p
	


###New implementation of SNP calling here to save on memory	
	call_genos(){
		samtools view -@$FB2 -b -1 -L mapped.$1.bed -o split.$1.bam filter.merged.bam
		samtools index split.$1.bam
		freebayes -b split.$1.bam -t mapped.$1.bed -v raw.$1.vcf -f reference.fasta -m 5 -q 5 -E 3 -V -n 10 --pooled-continuous 2> fb.$1.error.log

		if [ $? -eq 0 ]; then
    			echo "freebayes instance $1 completed successfully." >> freebayes.log
    			rm split.$1.bam*
			rm fb.$1.error.log
		else
    			echo -e "\n\nERROR: freebayes instance DID NOT COMPLETE\n\nSee below:"
			cat fb.$1.error.log
			echo -e "$?" "\t" "$1" >> freebayes.error
			exit 1
		fi

	}
	
	export -f call_genos
        call_genos2(){
		samtools view -@$FB2 -b -1 -L mapped.$1.bed -o split.$1.bam split.bam
                samtools index split.$1.bam
                freebayes -b split.$1.bam -t mapped.$1.bed -v raw.$1.vcf -f ../reference.fasta -m 5 -q 5 -E 3 -V -n 10 --pooled-continuous 
                if [ $? -eq 0 ]; then
                        rm split.$1.bam*
                else
                        echo -e "$?" "\t" "$1" >> freebayes.error
                        exit 1
                fi
        }
	export -f call_genos2
	finish_genos(){
		echo "Redoing a failed instance of FreeBayes"
		mkdir Finish.$1
		cd Finish.$1
		cp ../split.$1.bam split.bam
		cp ../mapped.$1.bed mapped.bed
		split -n l/4 --additional-suffix=.bed -d mapped.bed mapped.
		ls mapped.*.bed | sed 's/mapped.//g' | sed 's/.bed//g' | shuf | parallel --bar --halt now,fail=1 --env call_genos2 --memfree $MAXMemory -j 4 --no-notice "call_genos2 {} 2> /dev/null"
		if [ -f "freebayes.error" ]; then
			echo -e "\n\n\nFreeBayes has failed when trying to finish a previously failed instance.  Memory and processor settings need to be drastically reconfigured"
			ERROR3=1
			export ERROR3
		else
			echo "The failed instance of FreeBayes was successfully rerun"
            		ERROR3=0
			export ERROR3
			mv raw.1.vcf raw.01.vcf 2>/dev/null
			mv raw.2.vcf raw.02.vcf 2>/dev/null
			mv raw.3.vcf raw.03.vcf 2>/dev/null
			mv raw.4.vcf raw.04.vcf 2>/dev/null
			vcfcombine raw.*.vcf | sed -e 's/	\.\:/	\.\/\.\:/g' > RedoRawSNPs.vcf
			mv RedoRawSNPs.vcf ../raw.$1.vcf
        fi
		cd ..
		rm -rf Finish.$1
	}

	export -f finish_genos
	
	rm freebayes.error freebayes.log &> /dev/null

	ls mapped.*.bed | sed 's/mapped.//g' | sed 's/.bed//g' | shuf | parallel --bar --halt now,fail=5 --env call_genos --memfree $MAXMemory -j $NUMProc --no-notice "call_genos {} " 

	if [ -f "freebayes.error" ]; then
		FAILS=$( cat freebayes.error | wc -l )
		if [ $FAILS -lt 5 ]; then
			mv freebayes.error freebayes.redos
			for i in `cut -f2 freebayes.redos`
			do
			finish_genos $i
			done
			rm freebayes.redos
		else
               		echo -e "\nA previous freebayes instance failed.  dDocent will now recalibrate run parameters to use less memory.\n"
			rm freebayes.error
			LIM=$(( $NUMProc * 8 ))
        		FB2=$(( $NUMProc / 10 ))
        		export FB2
			rm mapped.*.bed
			split -n l/$LIM --additional-suffix=.bed -d mapped.bed mapped.
			echo "Using FreeBayes to call SNPs again"
			NumP=$(( $NUMProc / 4 ))
			NumP=$(( $NumP * 3 ))
			ls mapped.*.bed | sed 's/mapped.//g' | sed 's/.bed//g' | shuf | parallel --bar --halt now,fail=5 --env call_genos --memfree $MAXMemory -j $NumP --no-notice "call_genos {} " 
    		fi
	fi
    
    	if [ -f "freebayes.error" ]; then
               	FAILS=$( cat freebayes.error | wc -l )
                if [ $FAILS -lt 5 ]; then
			mv freebayes.error freebayes.redos
                        for i in `cut -f2 freebayes.redos`
                        do
                        finish_genos $i
                        done
			rm freebayes.redos
                else
			echo -e "\nA previous freebayes instance failed again.  dDocent will now recalibrate run parameters to use even less memory.\n"
       			rm freebayes.error		
            		NumP=$(( $NumP / 4 ))
                	NumP=$(( $NumP * 3 ))
			echo "Using FreeBayes to call SNPs again"
        		LIM=$(( $NUMProc * 16 ))
			rm mapped.*.bed
			split -n l/$LIM --additional-suffix=.bed -d mapped.bed mapped.
			ls mapped.*.bed | sed 's/mapped.//g' | sed 's/.bed//g' | shuf | parallel --bar --halt now,fail=1 --env call_genos --memfree $MAXMemory -j $NumP --no-notice "call_genos {} "
		fi
	fi

	if [ -f "freebayes.error" ]; then
		echo -e "\n\n\nFreeBayes has now failed a third  time, likely because of memory issues.  More resources must be allocated to finish this analysis."
		ERROR3=1
		export ERROR3
	else
            	ERROR3=0
		export ERROR3
        fi

	rm mapped.*.bed 

	mv raw.1.vcf raw.01.vcf 2>/dev/null
	mv raw.2.vcf raw.02.vcf 2>/dev/null
	mv raw.3.vcf raw.03.vcf 2>/dev/null
	mv raw.4.vcf raw.04.vcf 2>/dev/null
	mv raw.5.vcf raw.05.vcf 2>/dev/null
	mv raw.6.vcf raw.06.vcf 2>/dev/null
	mv raw.7.vcf raw.07.vcf 2>/dev/null
	mv raw.8.vcf raw.08.vcf 2>/dev/null
	mv raw.9.vcf raw.09.vcf 2>/dev/null

	vcfcombine raw.*.vcf | sed -e 's/	\.\:/	\.\/\.\:/g' > TotalRawSNPs.vcf

	if [ ! -d "raw.vcf" ]; then
		mkdir raw.vcf
	fi

	mv raw.*.vcf ./raw.vcf

	echo -e "\nUsing VCFtools to parse TotalRawSNPS.vcf for SNPs that are called in at least 90% of individuals"
	vcftools --vcf TotalRawSNPs.vcf $VCFGTFLAG 0.9 --out Final --recode --non-ref-af 0.001 --max-non-ref-af 0.9999 --mac 1 --minQ 30 --recode-INFO-all &>VCFtools.log
fi

##Checking for possible errors

if [ "$MAP" != "no" ]; then
	ERROR1=$(mawk '/developer/' bwa* 2>/dev/null | wc -l 2>/dev/null) 
fi
ERROR2=$(mawk '/error/' *.bam.log 2>/dev/null | wc -l 2>/dev/null)
if [ "$SNP" == "no" ]; then
	ERROR3=0
fi
ERRORS=$(($ERROR1 + $ERROR2 + $ERROR3))

#Move various log files to own directory
if [ ! -d "logfiles" ]; then
mkdir logfiles
fi
mv *.txt *.log log ./trim_reports ./logfiles 2> /dev/null

#Sending a completion email

if [ $ERRORS -gt 0 ]; then
        echo -e "dDocent has finished with errors in" `pwd` "\n\ndDocent started" $STARTTIME "\n\ndDocent finished" `date` "\n\nPlease check log files\n\n" `mawk '/After filtering, kept .* out of a possible/' ./logfiles/VCFtools.log` "\n\ndDocent" $VERSION "\nThe 'd' is silent, hillbilly." | mailx -s "dDocent has finished with ERRORS!" $MAIL
else
        echo -e "dDocent has finished with an analysis in" `pwd` "\n\ndDocent started" $STARTTIME "\n\ndDocent finished" `date` "\n\n" `mawk '/After filtering, kept .* out of a possible/' ./logfiles/VCFtools.log` "\n\ndDocent" $VERSION "\nThe 'd' is silent, hillbilly." | mailx -s "dDocent has finished" $MAIL
fi


}

##Function definitions

#Function for trimming reads using trimmomatic
trim_reads(){
	
	if [ -f $1.R.fq.gz ]; then	
		# paired
		fastp --in1 $1.F.fq.gz --in2 $1.R.fq.gz --out1 $1.R1.fq.gz --out2 $1.R2.fq.gz --cut_by_quality5 20 --cut_by_quality3 20 --cut_window_size 5 --cut_mean_quality 15 --correction $TW -q 15 -u 50 -j $1.json -h $1.html --detect_adapter_for_pe &> $1.trim.log
	else 
		#single
		fastp -i $1.F.fq.gz -o $1.R1.fq.gz --cut_by_quality5 20 --cut_by_quality3 20 --cut_window_size 5 --cut_mean_quality 15 -q 15 -u 50  $TW -j $1.json -h $1.html &> $1.trim.log
	fi
	mv $1.html ./trim_reports &>/dev/null && mv $1.json ./trim_reports &>/dev/null
}
	
	export -f trim_reads

TrimReads () { 
	#STACKS adds a strange _1 or _2 character to the end of processed reads, this looks for checks for errant characters and replaces them.
	#This functionality is now parallelized and will run if only SE sequences are used.
	NAMES=( `cat "namelist" `)
	STACKS=$(cat namelist| parallel -j $NUMProc --no-notice "gunzip -c {}.F.fq.gz | head -1" | mawk '$0 !~ /\/1$/ && $0 !~ /\/1[ ,	]/ && $0 !~ / 1:.*[A-Z]*/' | wc -l )
	FB1=$(( $NUMProc / 2 ))
	if [ $STACKS -gt 0 ]; then
		
		echo "Removing the _1 character and replacing with /1 in the name of every sequence"
		cat namelist | parallel -j $FB1 --no-notice "gunzip -c {}.F.fq.gz | sed -e 's:_1$:/1:g' > {}.F.fq"
		rm -f *.F.fq.gz
		cat namelist | parallel -j $FB1 --no-notice "gzip {}.F.fq"
	fi

	if [ -f "${NAMES[@]:(-1)}".R.fq.gz ]; then
	
		STACKS=$(cat namelist| parallel -j $NUMProc --no-notice "gunzip -c {}.R.fq.gz | head -1" | mawk '$0 !~ /\/2$/ && $0 !~ /\/2[ ,	]/ && $0 !~ / 2:.*[A-Z]*/'| wc -l )

		if [ $STACKS -gt 0 ]; then
			echo "Removing the _2 character and replacing with /2 in the name of every sequence"
			cat namelist | parallel -j $FB1 --no-notice "gunzip -c {}.R.fq.gz | sed -e 's:_2$:/2:g' > {}.R.fq"
			rm -f *.R.fq.gz
			cat namelist | parallel -j $FB1 --no-notice "gzip {}.R.fq"
		fi
	fi

	cat namelist | parallel -j $NUMProc "gunzip -c {}.F.fq.gz | head -2 | tail -1 >> lengths.txt"
	MLen=$(mawk '{ print length() | "sort -rn" }' lengths.txt| head -1)
    	MLen=$(($MLen / 2))
	TW="--length_required $MLen"	
	mkdir trim_reports &>/dev/null
	cat namelist | parallel --env trim_reads -j $FB1 trim_reads {}
}


#Main function for assembly
Assemble()
{
AWK1='BEGIN{P=1}{if(P==1||P==2){gsub(/^[@]/,">");print}; if(P==4)P=0; P++}'
AWK2='!/>/'
AWK3='!/NNN/'
PERLT='while (<>) {chomp; $z{$_}++;} while(($k,$v) = each(%z)) {print "$v\t$k\n";}'
SED1='s/^[ 	]*//'
SED2='s/ /	/g'
FRL=$(zcat ${NAMES[0]}.F.fq.gz | mawk '{ print length() | "sort -rn" }' | head -1)

if [ ${NAMES[@]:(-1)}.F.fq.gz -nt ${NAMES[@]:(-1)}.uniq.seqs ];then
	if [[ "$ATYPE" == "PE" || "$ATYPE" == "RPE" ]]; then
	#If PE assembly, creates a concatenated file of every unique for each individual in parallel
		cat namelist | parallel --no-notice -j $NUMProc "zcat {}.F.fq.gz | mawk '$AWK1' | mawk '$AWK2' > {}.forward"
		cat namelist | parallel --no-notice -j $NUMProc "zcat {}.R.fq.gz | mawk '$AWK1' | mawk '$AWK2' > {}.reverse"
		if [ "$ATYPE" = "RPE" ]; then
			cat namelist | parallel --no-notice -j $NUMProc "paste -d '-' {}.forward {}.reverse | mawk '$AWK3'| sed 's/-/NNNNNNNNNN/' | sort | uniq -c -w $FRL| sed -e '$SED1' | sed -e '$SED2' > {}.uniq.seqs"
		else
			cat namelist | parallel --no-notice -j $NUMProc "paste -d '-' {}.forward {}.reverse | mawk '$AWK3'| sed 's/-/NNNNNNNNNN/' | perl -e '$PERLT' > {}.uniq.seqs"
		fi
		rm *.forward
		rm *.reverse
	fi
	if [ "$ATYPE" == "SE" ]; then
	#if SE assembly, creates files of every unique read for each individual in parallel
		cat namelist | parallel --no-notice -j $NUMProc "zcat {}.F.fq.gz | mawk '$AWK1' | mawk '$AWK2' | perl -e '$PERLT' > {}.uniq.seqs"
	fi
	if [ "$ATYPE" == "OL" ]; then
	#If OL assembly, dDocent assumes that the marjority of PE reads will overlap, so the software PEAR is used to merge paired reads into single reads
		for i in "${NAMES[@]}";
        		do
        		zcat $i.R.fq.gz | head -2 | tail -1 >> lengths.txt
        		done	
        	MaxLen=$(mawk '{ print length() | "sort -rn" }' lengths.txt| head -1)
		LENGTH=$(( $MaxLen / 3))
		for i in "${NAMES[@]}"
			do
			pearRM -f $i.F.fq.gz -r $i.R.fq.gz -o $i -j $NUMProc -n $LENGTH 
			done
		cat namelist | parallel --no-notice -j $NUMProc "mawk '$AWK1' {}.assembled.fastq | mawk '$AWK2' | perl -e '$PERLT' > {}.uniq.seqs"
	fi
		
	
fi

#Create a data file with the number of unique sequences and the number of occurrences

if [ -f "uniq.seqs.gz" ]; then
	if [ uniq.seqs.gz -nt uniq.seqs ]; then
	gunzip uniq.seqs.gz 2>/dev/null
	fi
fi

if [ ! -f "uniq.seqs" ]; then
	cat *.uniq.seqs > uniq.seqs
fi
	

for i in {2..20};
do 
echo $i >> pfile
done
cat pfile | parallel -j $NUMProc --no-notice "echo -n {}xxx && mawk -v x={} '\$1 >= x' uniq.seqs | wc -l" | mawk  '{gsub("xxx","\t",$0); print;}'| sort -g > uniqseq.data
rm pfile


#Plot graph of above data
gnuplot << \EOF 
set terminal dumb size 120, 30
set autoscale
set xrange [2:20] 
unset label
set title "Number of Unique Sequences with More than X Coverage (Counted within individuals)"
set xlabel "Coverage"
set ylabel "Number of Unique Sequences"
plot 'uniqseq.data' with lines notitle
pause -1
EOF


echo -en "\007"
echo -en "\007"
echo -en "\007"
echo -e "Please choose data cutoff.  In essence, you are picking a minimum (within individual) coverage level for a read (allele) to be used in the reference assembly"

read CUTOFF
if [ "$ATYPE" == "RPE" ]; then
	parallel --no-notice -j $NUMProc mawk -v x=$CUTOFF \''$1 >= x'\' ::: *.uniq.seqs | cut -f2 | sort | uniq -c -w $FRL | sed -e 's/^[ 	]*//' | sed -e 's/ /	/g' > uniqCperindv
else
	parallel --no-notice -j $NUMProc mawk -v x=$CUTOFF \''$1 >= x'\' ::: *.uniq.seqs | cut -f2 | perl -e 'while (<>) {chomp; $z{$_}++;} while(($k,$v) = each(%z)) {print "$v\t$k\n";}' > uniqCperindv
fi
if [ "$NumInd" -gt 10 ]; then
	NUM=$(($NumInd / 2))
else
	NUM=$NumInd
fi

for ((i = 2; i <= $NUM; i++));
do
echo $i >> ufile
done

cat ufile | parallel -j $NUMProc --no-notice "echo -n {}xxx && mawk -v x={} '\$1 >= x' uniqCperindv | wc -l" | mawk  '{gsub("xxx","\t",$0); print;}'| sort -g > uniqseq.peri.data
rm ufile


#Plot graph of above data

gnuplot << \EOF 
set terminal dumb size 120, 30
set autoscale 
unset label
set title "Number of Unique Sequences present in more than X Individuals"
set xlabel "Number of Individuals"
set ylabel "Number of Unique Sequences"
plot 'uniqseq.peri.data' with lines notitle
pause -1
EOF

echo -en "\007"
echo -en "\007"
echo -en "\007"
echo -e "Please choose data cutoff.  Pick point right before the assymptote. A good starting cutoff might be 10% of the total number of individuals"

read CUTOFF2

#Prints instructions on how to move analysis to background and disown process
echo "At this point, all configuration information has been entered and dDocent may take several hours to run." 
echo "It is recommended that you move this script to a background operation and disable terminal input and output."
echo "All data and logfiles will still be recorded."
echo "To do this:"
echo "Press control and Z simultaneously"
echo "Type 'bg' without the quotes and press enter"
echo "Type 'disown -h' again without the quotes and press enter"
echo ""
echo "Now sit back, relax, and wait for your analysis to finish."

#Now that data cutoffs have been chosen, reduce data set to specified set of unique reads, convert to FASTA format,
#and remove reads with substantial amounts of adapters

mawk -v x=$CUTOFF2 '$1 >= x' uniqCperindv > uniq.k.$CUTOFF.c.$CUTOFF2.seqs
cut -f2 uniq.k.$CUTOFF.c.$CUTOFF2.seqs > totaluniqseq
mawk '{c= c + 1; print ">dDocent_Contig_" c "\n" $1}' totaluniqseq > uniq.full.fasta
LENGTH=$(mawk '!/>/' uniq.full.fasta  | mawk '(NR==1||length<shortest){shortest=length} END {print shortest}')
LENGTH=$(($LENGTH * 3 / 4))
$awk 'BEGIN {RS = ">" ; FS = "\n"} NR > 1 {print "@"$1"\n"$2"\n+""\n"gensub(/./, "I", "g", $2)}' uniq.full.fasta > uniq.fq
java -jar $TRIMMOMATIC SE -threads $NUMProc -phred33 uniq.fq uniq.fq1 ILLUMINACLIP:$ADAPTERS:2:30:10 MINLEN:$LENGTH
mawk 'BEGIN{P=1}{if(P==1||P==2){gsub(/^[@]/,">");print}; if(P==4)P=0; P++}' uniq.fq1 > uniq.fasta
mawk '!/>/' uniq.fasta > totaluniqseq
rm uniq.fq*

#If this is a PE assebmle
if [[ "$ATYPE" == "PE" || "$ATYPE" == "RPE" ]]; then
	#Reads are first clustered using only the Forward reads using CD-hit instead of rainbow
	sed -e 's/NNNNNNNNNN/	/g' uniq.fasta | cut -f1 > uniq.F.fasta
	CDHIT=$(python -c "print(max("$simC" - 0.1,0.8))")
	cd-hit-est -i uniq.F.fasta -o xxx -c $CDHIT -T 0 -M 0 -g 1 -d 100 &>cdhit.log
	mawk '{if ($1 ~ /Cl/) clus = clus + 1; else  print $3 "\t" clus}' xxx.clstr | sed 's/[>dDocent_Contig_,...]//g' | sort -g -k1 > sort.contig.cluster.ids
	paste sort.contig.cluster.ids totaluniqseq > contig.cluster.totaluniqseq
	sort -k2,2 -g contig.cluster.totaluniqseq | sed -e 's/NNNNNNNNNN/	/g' > rcluster
	#CD-hit output is converted to rainbow format
	rainbow div -i rcluster -o rbdiv.out -f 0.5 -K 10
	if [ "$ATYPE" == "PE" ]; then
		rainbow merge -o rbasm.out -a -i rbdiv.out -r 2 -N10000 -R10000 -l 20 -f 0.75
	else
		rainbow merge -o rbasm.out -a -i rbdiv.out
	fi
	#This AWK code replaces rainbow's contig selection perl script
	cat rbasm.out <(echo "E") |sed 's/[0-9]*:[0-9]*://g' | mawk ' {
		if (NR == 1) e=$2;
		else if ($1 ~/E/ && lenp > len1) {c=c+1; print ">dDocent_Contig_" e "\n" seq2 "NNNNNNNNNN" seq1; seq1=0; seq2=0;lenp=0;e=$2;fclus=0;len1=0;freqp=0;lenf=0}
		else if ($1 ~/E/ && lenp <= len1) {c=c+1; print ">dDocent_Contig_" e "\n" seq1; seq1=0; seq2=0;lenp=0;e=$2;fclus=0;len1=0;freqp=0;lenf=0}
		else if ($1 ~/C/) clus=$2;
		else if ($1 ~/L/) len=$2;
		else if ($1 ~/S/) seq=$2;
		else if ($1 ~/N/) freq=$2;
		else if ($1 ~/R/ && $0 ~/0/ && $0 !~/1/ && len > lenf) {seq1 = seq; fclus=clus;lenf=len}
		else if ($1 ~/R/ && $0 ~/0/ && $0 ~/1/) {seq1 = seq; fclus=clus; len1=len}
		else if ($1 ~/R/ && $0 ~!/0/ && freq > freqp && len >= lenp || $1 ~/R/ && $0 ~!/0/ && freq == freqp && len > lenp) {seq2 = seq; lenp = len; freqp=freq}
        }' > rainbow.fasta

	seqtk seq -r rainbow.fasta > rainbow.RC.fasta
	mv rainbow.RC.fasta rainbow.fasta

	#The rainbow assembly is checked for overlap between newly assembled Forward and Reverse reads using the software PEAR
	sed -e 's/NNNNNNNNNN/	/g' rainbow.fasta | cut -f1 | gawk 'BEGIN {RS = ">" ; FS = "\n"} NR > 1 {print "@"$1"\n"$2"\n+""\n"gensub(/./, "I", "g", $2)}' > ref.F.fq
	sed -e 's/NNNNNNNNNN/	/g' rainbow.fasta | cut -f2 | gawk 'BEGIN {RS = ">" ; FS = "\n"} NR > 1 {print "@"$1"\n"$2"\n+""\n"gensub(/./, "I", "g", $2)}' > ref.R.fq

	seqtk seq -r ref.R.fq > ref.RC.fq
	mv ref.RC.fq ref.R.fq
	LENGTH=$(mawk '!/>/' rainbow.fasta | mawk '(NR==1||length<shortest){shortest=length} END {print shortest}')
	LENGTH=$(( $LENGTH * 5 / 4))
	

	pearRM -f ref.F.fq -r ref.R.fq -o overlap -p 0.001 -j $NUMProc -n $LENGTH

	rm ref.F.fq ref.R.fq

	mawk 'BEGIN{P=1}{if(P==1||P==2){gsub(/^[@]/,">");print}; if(P==4)P=0; P++}' overlap.assembled.fastq > overlap.fasta
	mawk '/>/' overlap.fasta > overlap.loci.names
	mawk 'BEGIN{P=1}{if(P==1||P==2){gsub(/^[@]/,">");print}; if(P==4)P=0; P++}' overlap.unassembled.forward.fastq > other.F
	mawk 'BEGIN{P=1}{if(P==1||P==2){gsub(/^[@]/,">");print}; if(P==4)P=0; P++}' overlap.unassembled.reverse.fastq > other.R
	paste other.F other.R | mawk '{if ($1 ~ />/) print $1; else print $0}' | sed 's/	/NNNNNNNNNN/g' > other.FR

	cat other.FR overlap.fasta > totalover.fasta

	rm *.F *.R
fi
if [[ "$ATYPE" != "PE" && "$ATYPE" != "RPE" ]]; then
	cp uniq.fasta totalover.fasta
fi
cd-hit-est -i totalover.fasta -o reference.fasta.original -M 0 -T 0 -c $simC

sed -e 's/^C/NC/g' -e 's/^A/NA/g' -e 's/^G/NG/g' -e 's/^T/NT/g' -e 's/T$/TN/g' -e 's/A$/AN/g' -e 's/C$/CN/g' -e 's/G$/GN/g' reference.fasta.original > reference.fasta


samtools faidx reference.fasta
bwa index reference.fasta

}

##Create alignment intervals
##This takes advantage of the fact that RAD loci are very discrete.  Instead of calculating intervals for every BAM file,
##this function merges all BAM files together.  This overall BAM file 
##is used to create a single list of intervals, saving a large amount of computational time.

CreateIntervals()
{
samtools merge -@$NUMProc -b bamlist.list -f filter.merged.bam &>/dev/null
samtools index filter.merged.bam 
wait
mawk -v OFS='\t' {'print \$1,\$2'} $reference.fai > genome.file
bedtools merge -i filter.merged.bam -bed >  mapped.bed
}

#This checks that dDocent has detected the proper number of individuals and exits if incorrect
GetInfo(){
echo "$NumInd individuals are detected. Is this correct? Enter yes or no and press [ENTER]"

read Indcorrect

if [ "$Indcorrect" == "no" ]; then
        echo "Please double check that all fastq files are named Ind01.F.fq.gz and Ind01.R.fq.gz"
        exit 1
elif [ "$Indcorrect" == "yes" ]; then
            echo "Proceeding with $NumInd individuals"
else
        echo "Incorrect Input"
        exit 1
fi

#Tries to get number of processors, if not asks user
NUMProc=( `grep -c ^processor /proc/cpuinfo 2> /dev/null` ) 
NUMProc=$(($NUMProc + 0)) 

echo "dDocent detects $NUMProc processors available on this system."
echo "Please enter the maximum number of processors to use for this analysis."
        read NUMProc
        
if [ $NUMProc -lt 1 ]; then
        echo "Incorrect. Please enter the number of processing cores on this computer"
        read NUMProc
fi                
if [ $NUMProc -lt 1 ]; then
        echo "Incorrect input, exiting"
        exit 1
fi

#Tries to get maximum system memory, if not asks user
MAXMemory=$(($(grep -Po '(?<=^MemTotal:)\s*[0-9]+' /proc/meminfo | tr -d " ") / 1048576))G

echo "dDocent detects $MAXMemory maximum memory available on this system."
echo "Please enter the maximum memory to use for this analysis. The size can be postfixed with 
K, M, G, T, P, k, m, g, t, or p which would multiply the size with 1024, 1048576, 1073741824, 
1099511627776, 1125899906842624, 1000, 1000000, 1000000000, 1000000000000, or 1000000000000000 respectively."
echo "For example, to limit dDocent to ten gigabytes, enter 10G or 10g"
        read MAXMemory

while [[ -z $MAXMemory ]];
	do
	echo "Incorrect input"
	echo -e "Please enter the maximum memory to use for this analysis. The size can be postfixed with K, M, G, T, P, k, m, g, t, or p which would multiply the size with 1024, 1048576, 1073741824, 1099511627776, 1125899906842624, 1000, 1000000, 1000000000, 1000000000000, or 1000000000000000 respectively."
	echo -e "This option does not work with all distributions of Linux.  If runs are hanging at variant calling, enter 0"
	echo -e "Then press [ENTER]"
	read MAXMemory
	done

#Asks if user wants to trim reads.  This allows this part of the pipeline to be skipped during subsequent analyses
echo -e "\nDo you want to quality trim your reads?" 
echo "Type yes or no and press [ENTER]?"

read TRIM

#Asks if user wants to perform an assembly.  This allows this part of the pipeline to be skipped during subsequent analyses

echo -e "\nDo you want to perform an assembly?"
echo "Type yes or no and press [ENTER]."

read ASSEMBLY

if [ "$ASSEMBLY" == "no" ]; then
        echo -e "\nReference contigs need to be in a file named reference.fasta\n"
        sleep 1
else
	echo -e "What type of assembly would you like to perform?  Enter SE for single end, PE for paired-end, RPE for paired-end sequencing for RAD protocols with random shearing, or OL for paired-end sequencing that has substantial overlap."
	echo -e "Then press [ENTER]"
	read ATYPE

	while [[ $ATYPE != "SE" && $ATYPE != "PE" && $ATYPE != "OL" && $ATYPE != "RPE" ]];
	do
	echo "Incorrect input"
	echo -e "What type of assembly would you like to perform?  Enter SE for single end, PE for paired-end, RPE for paired-end sequencing for RAD protocols with random shearing, or OL for paired-end sequencing that has substantial overlap."
	echo -e "Then press [ENTER]"
	read ATYPE
	done
fi
#If performing de novo assembly, asks if the user wants to enter a different -c value
if [ "$ASSEMBLY" == "yes" ]; then
    echo "Reads will be assembled with Rainbow"
    echo "CD-HIT will cluster reference sequences by similarity. The -c parameter (% similarity to cluster) may need to be changed for your taxa."
    echo "Would you like to enter a new c parameter now? Type yes or no and press [ENTER]"
    read optC
    if [ "$optC" == "no" ]; then
            echo "Proceeding with default 0.9 value."
            simC=0.9
        elif [ "$optC" == "yes" ]; then
            echo "Please enter new value for c. Enter in decimal form (For 90%, enter 0.9)"
            read newC
            simC=$newC
        else
            echo "Incorrect input. Proceeding with the default value."
            simC=0.9
        fi
fi

#Asks if user wants to map reads and change default mapping variables for BWA
echo "Do you want to map reads?  Type yes or no and press [ENTER]"
read MAP
if [ "$MAP" == "no" ]; then
        echo "Mapping will not be performed"
        optA=1
    	optB=4
    	optO=6
        else
                echo "BWA will be used to map reads.  You may need to adjust -A -B and -O parameters for your taxa."
                echo "Would you like to enter a new parameters now? Type yes or no and press [ENTER]"
                read optq

        if [ "$optq" == "yes" ]; then
        echo "Please enter new value for A (match score).  It should be an integer.  Default is 1."
        read newA
        optA=$newA
                echo "Please enter new value for B (mismatch score).  It should be an integer.  Default is 4."
        read newB
        optB=$newB
                echo "Please enter new value for O (gap penalty).  It should be an integer.  Default is 6."
        read newO
        optO=$newO
        else
                echo "Proceeding with default values for BWA read mapping."
                optA=1
                optB=4
                optO=6
        fi
fi

#Does user wish to call SNPs?
echo "Do you want to use FreeBayes to call SNPs?  Please type yes or no and press [ENTER]"
read SNP

while [[ $SNP != "yes" && $SNP != "no" ]];
	do
	echo "Incorrect input"
	echo -e "Do you want to use FreeBayes to call SNPs?  Please type yes or no and press [ENTER]"
	read SNP
	done

#Asks user for email address to notify when analysis is complete
echo ""
echo "Please enter your email address.  dDocent will email you when it is finished running."
echo "Don't worry; dDocent has no financial need to sell your email address to spammers."
read MAIL
echo ""
echo ""

if [ "$ASSEMBLY" == "no" ]; then
#Prints instructions on how to move analysis to background and disown process
echo "At this point, all configuration information has been entered and dDocent may take several hours to run." 
echo "It is recommended that you move this script to a background operation and disable terminal input and output."
echo "All data and logfiles will still be recorded."
echo "To do this:"
echo "Press control and Z simultaneously"
echo "Type 'bg' without the quotes and press enter"
echo "Type 'disown -h' again without the quotes and press enter"
echo ""
echo "Now sit back, relax, and wait for your analysis to finish."
fi

if [ "$ASSEMBLY" == "yes" ]; then
echo "dDocent will require input during the assembly stage.  Please wait until prompt says it is safe to move program to the background."
fi
}

#Actually starts program
if [ -n "$1" ]; then
        main $1 2>&1 | tee temp.LOG #Log all output
else
        main 2>&1 | tee temp.LOG #Log all output
fi

mawk '!/#.*%/' temp.LOG >> dDocent_main.LOG
rm temp.LOG

#Compress Large Leftover files
gzip -f concat.fasta concat.seq rcluster rbdiv.out rbasm.out rainbow.fasta reference.fasta.original uniq.seqs uniq.fasta totaluniqseq uniq.F.fasta uniq.RC.fasta 2> /dev/null &



