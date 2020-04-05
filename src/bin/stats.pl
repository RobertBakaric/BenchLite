#!/usr/bin/perl

use strict;
use warnings;
use Statistics::Basic qw(:all nofill);
use Data::Dumper;


use lib "../lib";

use Stats::BenchStats;


my $o = Stats::BenchStats->new();


my @arr = (2,4,3,5,67,87,4,45,6,87,8,6,2,1);
$o->compute_mean(@arr);
$o->compute_sd(@arr);

my @a = (2,4,3,5,67,87,8,6,2,1);
$o->compute_stats(\@arr);
#$o->recompute_stats(\@a);

my @v = (2,4,3,5,67,87,4,45,6,87,8,6,2,1,2,4,3,5,67,87,8,6,2,1);


my $m = mean(@v);
my $sd = stddev(@v);
print "".$o->get_mean() ."\t$m\n" ;
print "".$o->get_sd() ."\t$sd\n" ;


use Stats::BenchMatrix;


my $mt = Stats::BenchMatrix->new();

my @arr2 = ([1,2,3],[4,5,6],[7,8,9]);
my @arr3 = ([2,3,4],[5,6,7],[8,9,10]);
#my @arr2 = (2,5,8);
#my @arr3 = (3,6,9,11);

$mt->compute_stats_matrix(\@arr3);
$mt->recompute_stats_matrix(\@arr2);
#$mt->compute_stats_matrix(\@arr3);

my $mmt = $mt->get_stats_matrix();

foreach my $tt (@{$mmt}){
  foreach my $zu (@{$tt}){
    print $zu->get_mean() ."\n";
  }

}

print Dumper($mt->get_stats_matrix()) ;
