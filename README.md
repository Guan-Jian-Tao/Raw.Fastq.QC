# Raw.Fastq.QC
-----

***Example:***
>perl T0\_FASTQC\_Cluster.pl -h
>
>Usage:
>
  Run by typing: perl T0_FASTQC_Cluster.pl -fqpath [fastq file path] -logfile [log file (.txt)] -outdir [out directory]

    Required params:
        -e|fqpath                                                       [s]     Raw Fastq files path
        -l|logfile                                                      [s]     Log file (.txt)
        -o|outdir                                                       [s]     Out directory
    Example: perl T0_FASTQC_Cluster.pl -fqpath Raw_data.dir/ -logfile ExperimentalDesign.txt Log.txt -outdir fastqc.out.dir/

>perl T0_Q30.pl -h -h
>
>Usage:

>  Run by typing: perl T0_Q30.pl -fqpath [fastq file path] -logfile [log file (.txt)] -outdir [out directory]

    Required params:
        -e|fqpath                                                       [s]     Raw Fastq files path
        -l|logfile                                                      [s]     Log file (.txt)
        -o|outdir                                                       [s]     Out directory
	Example: perl T0_Q30.pl -fqpath Raw_data.dir/ -logfile Log.txt -outdir fastqc.out.dir/

>perl T1_Trimmomatic.Cluster.pl -h
>
>Usage:

>Run by typing: perl T1_Trimmomatic.Cluster.pl -fqpath [fastq file path] -adapter_path [Trimmomatic adapter file path] -logfile [log file (.txt)] -outdir [out directory]
>
    Required params:
        -e|fqpath                                                       [s]     Raw Fastq files path
        -l|logfile                                                      [s]     Log file (.txt)
        -o|outdir                                                       [s]     Out directory
        -d|adapter_path                                         [s]     Trimmomatic adapter file path
    Example: perl T1_Trimmomatic.Cluster.pl -fqpath Raw_data.dir -adapter_path Trimmomatic-0.36/adapters/TruSeq3-PE.fa -logfile Log.txt -outdir Clean_data.dir/