#!/usr/bin/perl
#  Copyright 2020 Robert Bakaric
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
# 

=head1 NAME
	bench - Simple Benchmark tool for CLI applications 
=head1 SYNOPSIS
	Usage:

	-p	Testing ... (file.bench)  : file containing a list of cmd's to be benchmarked
	-l	Log file                  : file containing execution logs
	-o	output                    : directory contiaining outputs of each tool together with detailed benchmark statistics
	-b	bootstrap                 : the number of times a measurments are to be repeated
	-d	Delta T in sec            : timeframe in which memory consumption should be recorded
	-i	Session Id                : benchmark session identifier segregating different benchmarkings within the same framework
	-f	Monitor flags             : CLI options to be monitored (currently only those taking files are subjected to filesize measurments)


	Example of  my.bench file :
	
	
		#Tool -- comment line
		tool -i in -o out 
		tool2 -i in2 -o out2 


	Execute:
	bench -f "-i -o" -l My_Log_Date -o My_Bench_Out -b 10 -d 10 -s 1  -p my.bench



=head1 DESCRIPTION
	Benchmarking is the practice of comparing processes and performance metrics to 
	industry standard best practice solutions. Parameters typically considered 
	within a measurment process are:
		
		a) quality of the resulting output, 
		b) execution time 
		c) memory usage 
		d) disc usage 

	"bench" is a simple cli application that utilizes all of the above stated quantifiations 
        schemas and crunches out a simple descriptive statistical summary for a set of measurments
        obtained from direct cli app executions

=head1 AUTHOR
Robert Bakaric <robertbakaric@zoho.com>
=head1 LICENSE
  
	#  Copyright 2020 Robert Bakaric
	#  
	#  This program is free software; you can redistribute it and/or modify
	#  it under the terms of the GNU General Public License as published by
	#  the Free Software Foundation; either version 2 of the License, or
	#  (at your option) any later version.
	#  
	#  This program is distributed in the hope that it will be useful,
	#  but WITHOUT ANY WARRANTY; without even the implied warranty of
	#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	#  GNU General Public License for more details.
	#  
	#  You should have received a copy of the GNU General Public License
	#  along with this program; if not, write to the Free Software
	#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
	#  MA 02110-1301, USA.
	#  
	# 
 
=head1 ACKNOWLEDGEMENT
 
=cut





use strict;
#use warnings;
use Time::HiRes;
use Getopt::Long;
use File::Basename qw( fileparse );
use File::Path qw( make_path );
use File::Spec;
use Proc::ProcessTable;
use IO::CaptureOutput qw/capture_exec/;
use Statistics::Basic qw(:all nofill);

my ($help, $par, $logfile, $out, $boot, $deltaT, $id, $flags, $quite);
GetOptions ("p=s" => \$par,
            "h" => \$help,
            "l=s" => \$logfile,
            "o=s" => \$out,
            "b=i" => \$boot,
            "d=i" => \$deltaT,
            "i=s" => \$id,
            "f=s" => \$flags,
            "q"  => \$quite
            );

if($help  || !$par || !$id){
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

##--------------- Testing Parser ----------------#

my @tests = ();

if (-e $par && $par =~/\.bench/){
  open(I, "<", $par) || die "$!";
  while(<I>){
    chomp;
    next if /#/;
    push(@tests, $_);
  }
  close I;
}else{
  @tests = split(";", $par);
}


$flags = "xxx" unless $flags;
$out = "benchmarks" unless $out;
$boot = 1 unless $boot;


my $t_id = 0;
my $outlog = '';



if ( !$logfile ) {
  my $timestamp = getLoggingTime();
  $logfile = "logs-$timestamp";
}

if ( !$outlog ) {
    $outlog = File::Spec->catfile( $out, $logfile);
}


if ( !-d $out ) {
    make_path $out or die "Failed to create path: $out";
}
if ( !-d $outlog ) {
    make_path $outlog or die "Failed to create path: $outlog";
}


print "Evaluating  ...\n" ;

foreach my $t (@tests) {
  $t_id++;

  my $pid = $$;

  print "$t ... ";


  for (my $b = 1; $b <= $boot; $b++){

    my $forks = 0;
    for (1 .. 1) {
      my $pid = fork;
      if (not defined $pid) {
         warn 'Could not fork';
         next;
      }
      if ($pid) {
        $forks++;

        my $mem = 1;
        my $mem_avrg = 0;
        my $mem_sum = 0;
        my $mem_max = 0;
        my $mem_cnt = 0;
        my @mem;

        while ($mem > 0) {
          sleep $deltaT;
          $mem =  &memory_usage($pid+2);
          push(@mem,$mem);
          $mem_max = $mem if $mem > $mem_max;
          $mem_cnt++;
          $mem_sum +=$mem;
          $mem_avrg = $mem_sum/$mem_cnt;
        }

        open(OM, ">>", "$outlog/$id.mem.log") || die "$!";
        print OM "#Tool\tBoot\tPID\tMemAvg(MB)\tMemMax(MB)\tMem(MB)_[$deltaT sec]\n" if $t_id == 1 && $b == 1 ;
        print OM "$t\t$b\t".($pid+2)."\t".(sprintf("%.2f",$mem_avrg)). "\t$mem_max\t" . join(",",@mem) . "\n";
        close OM;

      } else {

        # Time
        my @pmts = split(" ",$t);
        my $start_time = [Time::HiRes::gettimeofday()];
          system("$t > $outlog/$pid.log");
        my ($user, $system, $child_user, $child_system) = times;
        my $clock =  Time::HiRes::tv_interval($start_time);


        # Memory
        my $ppd = $$ +2;
        my @flags = split(",",$flags);
        my @flag_res = ();

        for (my $q=0; $q<@pmts; $q++){
          foreach my $flg (@flags) {
            if ($pmts[$q] eq $flg){
              my $d = qx(du -b $pmts[$q+1]);
              $d=~/^(.*?)\s+/;
              push(@flag_res,$1);
            }
          }
        }

        open(OT, ">>", "$outlog/$id.ts.log") || die "$!";
        print OT "#Tool\tBoot\tPID\tUserTime\tSysTime\tTotTime\tDiscUsage:@flags\n" if $t_id == 1 && $b == 1 ;
        print OT "$t\t$b\t$ppd\t$child_user\t$child_system\t$clock\t@flag_res\n";
        close OT;

        exit;
      }
    }

    for (1 .. $forks) {
       my $pid = wait();
    }
  }

  print " Done! \n";

}

## -------------Summary stats


print "\nSummary statistics:\n\n";

open (M, "<", "$outlog/$id.mem.log" ) || die "$!";
open (T, "<","$outlog/$id.ts.log" ) || die "$!";



my %TooL = ();
while(<M>){
  chomp;
  next if /#/;
  my @l = split("\t",$_);
  $TooL{$l[0]}->[0] = $l[2];
  push(@{$TooL{$l[0]}->[1]},$l[4]);
  $TooL{$l[0]}->[2]++;
}
print "Memory:\nPID\tMeanMem\tSDofMeanMem\t#ofBootstrapIter\tTool\n";
foreach (keys %TooL){
  print "$TooL{$_}->[0]\t" . (mean($TooL{$_}->[1])) ."\t".(stddev($TooL{$_}->[1])) ."\t$TooL{$_}->[2]\t$_\n";
}


%TooL = ();
while(<T>){
  chomp;
  next if /#/;
  my @l = split("\t",$_);
  $TooL{$l[0]}->[0] = $l[2];
  push(@{$TooL{$l[0]}->[1]},$l[5]);
  $TooL{$l[0]}->[2]++;
  $TooL{$l[0]}->[3] = $l[6];
  $TooL{$l[0]}->[4] = $l[7];
}
print "\nTime/Space:\nPID\tMeanTime\tSDofMeanTime\t#ofBootstrapIter\tTool\n";
foreach (keys %TooL){
  print "$TooL{$_}->[0]\t" . (mean($TooL{$_}->[1])) ."\t".(stddev($TooL{$_}->[1])) ."\t$TooL{$_}->[2]\t$TooL{$_}->[3]\t$TooL{$_}->[4]\t$_\n";
}

close M;
close T;


if ($quite) {
  rmtree $out || die "$_";
}



##   -- Helper Functions --

sub memory_usage() {

    my $pp = shift;
    my $t = new Proc::ProcessTable;
    foreach my $got (@{$t->table}) {
        next unless $got->pid eq $pp;
        return (sprintf ("%.2f", $got->size / 1000000));
    }

}


sub getLoggingTime {

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    my $nice_timestamp = sprintf ( "%04d%02d%02d_%02d-%02d-%02d", $year+1900,$mon+1,$mday,$hour,$min,$sec);
    return $nice_timestamp;

}
