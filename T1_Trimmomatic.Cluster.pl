#! /usr/bin/perl -w
use strict;
use warnings;
use POSIX qw(tmpnam);
use Getopt::Long;
use File::Basename;
use File::Path qw(make_path);
use Cwd qw(abs_path);
use List::MoreUtils qw(uniq);
use Time::localtime;
$|=1;

## ======================================
## Usage: see -h
## ======================================

sub usage{
  warn <<END;
  Usage:
  Run by typing: perl T1_Trimmomatic.Cluster.pl -fqpath [fastq file path] -adapter_path [Trimmomatic adapter file path] -logfile [log file (.txt)] -outdir [out directory]
    Required params:
	-e|fqpath							[s]	Raw Fastq files path
	-l|logfile							[s]	Log file (.txt)
	-o|outdir							[s]	Out directory
	-d|adapter_path						[s]	Trimmomatic adapter file path
    Example: perl T1_Trimmomatic.Cluster.pl -fqpath Raw_data.dir/ -adapter_path Trimmomatic-0.36/adapters/TruSeq3-PE.fa -logfile Log.txt -outdir Clean_data.dir/
END
  exit;
}
## ======================================
## Get options
## ======================================

my %opt;
%opt = (
	'help'				=> undef,
	'debug'				=> undef,
	'fqpath'		    => undef,
	'logfile'			=> undef,
	'outdir'			=> undef
);

die usage() if @ARGV == 0;
GetOptions (
  'h|help'				=> \$opt{help},
  'debug'				=> \$opt{debug},
  'e|fqpath=s'		=> \$opt{fqpath},
  'l|logfile=s'			=> \$opt{logfile},
  'o|outdir=s'			=> \$opt{outdir},
  'd|adapter_path=s'			=> \$opt{adapter_path}
) or die usage();

#check input paramaters
die usage() if $opt{help};
die usage() unless ( $opt{fqpath} );
die usage() unless ( $opt{logfile} );
die usage() unless ( $opt{outdir} );
die usage() unless ( $opt{adapter_path} );

########
#Main Function
########

my $pathraw = $opt{fqpath}; #folder for raw fastq files
my @files = `ls  $pathraw`;
my %data;

if(-e $opt{logfile}){
	system "rm $opt{logfile}";
}


foreach my $f (@files) {
	chomp($f);$f =~ s/\r//;
	#next unless $f =~ /dir/;
	my @g = split /\_/,$f;
	next unless $f =~/fq\.gz$/;
	next if exists $data{$g[0]};
	$data{$g[0]}=1;
	my $p= $g[0];
	my $fq1 = $pathraw.$p."_1_clean.fq.gz";
	my $fq2 = $pathraw.$p."_2_clean.fq.gz";
	my $out1_pair = $opt{outdir}.$p."_1_clean.fq.gz";
	my $out1_unpair = $opt{outdir}.$p."_1_clean.unpair.fq.gz";
	my $out2_pair = $opt{outdir}.$p."_2_clean.fq.gz";
	my $out2_unpair = $opt{outdir}.$p."_2_clean.unpair.fq.gz";
	my $sh = "Trimmomatic.$p.sh";
	open (OUT,">$sh");
	print OUT "\#\$ \-S \/bin\/bash\n\#\$ \-j y \-V\n\#\$ \-cwd\n\#\$ \-l h\_vmem\=30G\n\#\$ -q all.q\n";
	sleep 0.1;
	print OUT "time1=`date \"+%Y-%m-%d %H:%M:%S\"` \necho T1_Trimmomatic.Cluster for $p starts\ at \$time1  >> $opt{logfile}\n";
	print OUT "#Main Command Line\n########\n";
	print OUT "java -jar ./Trimmomatic-0.36/trimmomatic-0.36.jar PE -trimlog $opt{logfile} $fq1 $fq2 $out1_pair $out1_unpair $out2_pair $out2_unpair ILLUMINACLIP:$opt{adapter_path}:2:30:10 SLIDINGWINDOW:4:20 MINLEN:50 LEADING:20 TRAILING:20 \n";
	print OUT "########\n";
	print OUT "time2=`date \"+%Y-%m-%d %H:%M:%S\"`\n";
	print OUT "end_dat=`date -d \"\$time2\" +%s` \nstart_dat=`date -d \"\$time1\" +%s` \ninter_s=`expr \$end_dat - \$start_dat` \ninter_m=`expr \$inter_s / 60` \necho T1_Trimmomatic.Cluster for $p completes at \$time2 and consumed \$inter_m minutes >> $opt{logfile} \n";
	close OUT;
	system "chmod 700 $sh";
	system "qsub $sh";
	sleep 0.1;
	print "java -jar ./Trimmomatic-0.36/trimmomatic-0.36.jar PE -trimlog $opt{logfile} $fq1 $fq2 $out1_pair $out1_unpair $out2_pair $out2_unpair ILLUMINACLIP:$opt{adapter_path}:2:30:10 SLIDINGWINDOW:4:20 MINLEN:50 LEADING:20 TRAILING:20 \n";
	sleep 0.2;
}

