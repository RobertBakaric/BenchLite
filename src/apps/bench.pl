#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use lib "../lib";

#---------------------------------------------------------#
#                PiedPiper construction
#---------------------------------------------------------#

# construct object manager
use Bench::BenchLite;
my $bench = Bench::BenchLite->new();

#---------------------------------------------------------#
#                      CLI
#---------------------------------------------------------#

my ($help, $script, $logfile, $out, $boot, $deltaT, $id, $flags, $quite);
GetOptions ("p=s" => \$script,
            "h" => \$help,
            "l=s" => \$logfile,
            "o=s" => \$out,
            "b=i" => \$boot,
            "d=i" => \$deltaT,
            "i=s" => \$id,
            "f=s" => \$flags,
            "q"  => \$quite
            );

if($help  || !$script ){
  print "Usage:\n\n";
  print "\t-p\tTesting ... (file.bench)\n";
  print "\t-l\tLog file\n";
  print "\t-o\toutput\n";
  print "\t-b\tbootstrap\n";
  print "\t-d\tDelta T in sec\n";
  print "\t-i\tSession Id\n";
  print "\t-f\tMonitor flags\n";
  print "\n\nExample *.bench file :\n";
  print "#Tool -> line not read because of #\n";
  print "tool -i in -o out \n";
  print "tool2 -i in2 -o out2 \n";
  print "\n\nExecute:\n";
  print "bench -f \"-i -o\" -l My_Log_Date -o My_Bench_Out -b 10 -d 10 -s 1  -p my.bench\n";

  exit(0);
}

#---------------------------------------------------------#
#                     Set defaults
#---------------------------------------------------------#

$boot = 1 unless $boot;

# bootstrap mode set to 0 means only a single cmd execution will be preformed
$bench->{_bootstrap_} = $boot;

# define the output path
$bench->{_output_} = "./Benchmarks";
$bench->{_log_} = "Bench.log";
$bench->{_delta_} = 1;

# execute *.bench script
$bench->benchmark($script);

# get benchmark results
my $table  = $bench->get_summary_stats();

print Dumper($table);
