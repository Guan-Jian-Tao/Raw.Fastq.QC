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
  Run by typing: perl T0_FASTQC_Cluster.pl -fqpath [fastq file path] -logfile [log file (.txt)] -outdir [out directory]
    Required params:
	-e|fqpath							[s]	Raw Fastq files path
	-l|logfile							[s]	Log file (.txt)
	-o|outdir							[s]	Out directory
    Example: perl T0_FASTQC_Cluster.pl -fqpath Raw_data.dir/ -logfile Log.txt -outdir fastqc.out.dir/
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
  'o|outdir=s'			=> \$opt{outdir}
) or die usage();

#check input paramaters
die usage() if $opt{help};
die usage() unless ( $opt{fqpath} );
die usage() unless ( $opt{logfile} );
die usage() unless ( $opt{outdir} );

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
	my $sh = "Fastqc_$p.sh";
	open (OUT,">$sh");
	print OUT "\#\$ \-S \/bin\/bash\n\#\$ \-j y \-V\n\#\$ \-cwd\n\#\$ \-l h\_vmem\=20G\n\#\$ -q all.q\n";
	sleep 0.1;
	print OUT "time1=`date \"+%Y-%m-%d %H:%M:%S\"` \necho T0_FASTQC_Cluster for $p starts\ at \$time1  >> $opt{logfile}\n";
	print OUT "#Main Command Line\n########\n";
	print OUT "fastqc -o $opt{outdir} -f fastq $fq1 $fq2 \n";
	print OUT "########\n";
	print OUT "time2=`date \"+%Y-%m-%d %H:%M:%S\"`\n";
	print OUT "end_dat=`date -d \"\$time2\" +%s` \nstart_dat=`date -d \"\$time1\" +%s` \ninter_s=`expr \$end_dat - \$start_dat` \ninter_m=`expr \$inter_s / 60` \necho T0_FASTQC_Cluster for $p completes at \$time2 and consumed \$inter_m minutes >> $opt{logfile} \n";
	close OUT;
	system "chmod 700 $sh";
	system "qsub $sh";
	sleep 0.1;
	print "fastqc -o $opt{outdir} -f fastq $fq1 $fq2 \n";
	sleep 0.2;
}
