#!/usr/bin/perl
#  Copyright 2020 Robert Bakaric and Neva Skrabar
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

package Bench::BenchLite;


=head1 NAME

Bench::BenchLite - Simple Benchmark module for batch based CLI applications

=head1 SYNOPSIS

    use Bench::BenchLite;
    my $object = Bench::BenchLite->new();
    print $object->as_string;

=head1 DESCRIPTION

Benchmarking is the practice of comparing processes and performance metrics to
industry standard best practice solutions. Parameters typically considered
within a measurment process are:

  a) quality of the resulting output,
  b) execution time
  c) memory usage
  d) disc usage

"BenchLite" is a simple module for building fast and simple  benchmarking applications
under Unix environment.

=head1 LICENSE

The softare is released under the General Public License. See L<perlartistic>.

=head1 AUTHOR

Robert Bakaric and Neva Skrabar

=head1 SEE ALSO

L<perlpod>, L<perlpodspec>


=head2 Methods



=over 12

=item C<new>

Constructor: returns a new Bench::BenchLite object.


=begin html
 <br>Figure 1.<IMG SRC="figure.jpg"><br>
=end html


=item C<as_string>

Returns a stringified representation of
the object. This is mainly for debugging
purposes.

=back

=cut



#---------------------------------------------------------#
#                     Libraries
#---------------------------------------------------------#

use strict;
use warnings;
use Time::HiRes;
use File::Basename qw( fileparse );
use File::Path qw( make_path );
use File::Spec;
use Proc::ProcessTable;
use IO::CaptureOutput qw/capture_exec/;
use Statistics::Basic qw(:all nofill);
use Data::Dumper;


#---------------------------------------------------------#
#                      CONSTRUCTOR
#---------------------------------------------------------#

sub new {
    my ($class) = @_;

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();

    my %hash = ();
    my $def_out = "" . $sec . "_" ."$mday" ."_" . ($mon+1) . "_" .  ($year%100);

    my $self->{_name_}   = "Bench";
    $self->{_date_} = $sec . "s" . $min . "m" . $hour . "h" .   $mday . "d" . ($mon+1) . "m" . ($year%100) . "y";
    $self->{_suffix_} = ".bench";
    $self->{_output_} = "./Bench";
    $self->{_log_} = "Bench.log";
    $self->{_stats_} = 0;
    $self->{_stats_table_} = ();
    $self->{_def_name_} = $def_out;
    $self->{_bootstrap_} = 0;
    $self->{_delta_} = 1;

    $self->{_logic_} = 0;


    bless $self, $class;
    return $self;
}


#---------------------------------------------------------#
#                  Public methods
#---------------------------------------------------------#

sub benchmark {

  my ($self, $arg) = @_;

  # make a working directory

  $self->_makepath("$self->{_output_}/$self->{_def_name_}");

  my $cmds = $self->_parse_script($arg);

  print "Benchmarking  ...\n" ;

  foreach my $c (sort {$a <=> $b} keys %{$cmds->{"cmd"}}) {
    my $pid = $$;
    print "$pid -- $cmds->{cmd}->{$c}->{exe} ... ";

    for (my $b = 1; $b <= $self->{_bootstrap_}; $b++){

      my $forks = 0;
      for (1 .. 1) {
        my $pid = fork;
        if (not defined $pid) {
           warn 'Could not fork';
           next;
        }

        if ($pid) {
          $forks++;
          # Memory
          $self->_measure_memory(
                         "deltaT" => $self->{_delta_},
                         "pid"    => $pid+2,
                         "cmds"   => $cmds,
                         "swtch"  => [$c,$b]
                         );
        } else {
          my $ppd = $$ + 2;
          # Time
          $self->_measure_runtime(
                          "pid"    => $ppd,
                          "cmds"   => $cmds,
                          "swtch"  => [$c,$b]
                          );
          # Disc
          $self->_measure_disc(
                          "pid"    => $ppd,
                          "cmds"   => $cmds,
                          "swtch"  => [$c,$b]
                          );
          exit;
        }
      }

      for (1 .. $forks) {
         my $pid = wait();
      }
    }

    print " Done! \n";

  }


  $self->_load_stats();

  return 1;
}


#---------------------------------------------------------#
#                       Getters
#---------------------------------------------------------#


sub get_summary_stats {

  my ($self) = @_;

  return $self->{_stats_table_};
}


sub get_raw_stats {

  my ($self, $flag) = @_;

  if ($self->{_stats_}  == 0){
    die "$!\nYou need to run: \$obj->compute_stats() first!";
  }

  if ($flag eq "as_string") {

    return Dumper($self->{_stats_table_});

  }elsif ($flag eq "as_table"){

    return $self->_make_table();

  }elsif ($flag eq "as_object"){

    return $self->{_stats_table_};

  }else{

    die "$!\n$flag not recognized!\n";

  }
  
}



#---------------------------------------------------------#
#                  Private methods
#---------------------------------------------------------#



sub _compute_summary_stats {

  my ($self) = @_;




  $self->{_summary_table_} = \%hash;
}

sub _make_table {

  my ($self) = @_;

  ## hash to tsv
}


sub _parse_results {

  my ($self, $tab, $waht, $file) = @_;

  my %hash = %{$tab};

  my ($boot, $mes, $x) = (0,0,0);
  my @log   = ();
  my @avg   = ();
  my @cmd   = ();


  open (IN, "<", $file) || die "$!";

  while(<IN>){
    chomp;
    if (/^#(.*)/){
      my @head = split("\t", $1);
      foreach my $col (@head){
        if ($col eq "Bootstrap"){
          $boot = $x;
        }elsif( $col eq "Cmd"){
          $mes = $x;
        }
        $x++;
      }
    }else{
      my @data  = split("\t", $_);

      if ($dat[$boot] < $max){
        push (@{$tab->{$waht}{"logic"}}, \@log );
        push (@{$tab->{$waht}{"data"}},  \@avgdat );
        push (@{$tab->{$waht}{"cmd"}},   \@cmd );
      }
      @log   = @data[0..($boot-1)];
      @avgdat   = $sef->_avrg(@data[$boot..($mes-1)]);
      @cmd   = @data[$mes..(@data-1)];


    }
  }


    push (@{$tab->{$waht}{"logic"}}, \@log );
    push (@{$tab->{$waht}{"data"}},  \@avgdat );
    push (@{$tab->{$waht}{"cmd"}},   \@cmd );
  close IN;

}


sub _load_stats {

  my ($self) = @_;

  my %table = ();
  # open Runtime

  $self->_parse_results(\%table, "runtime", "$self->{_output_}/$self->{_def_name_}/$self->{_name_}.rtime.log");

  $self->_parse_results(\%table, "memory", "$self->{_output_}/$self->{_def_name_}/$self->{_name_}.mem.log");

  $self->_parse_results(\%table, "disc", "$self->{_output_}/$self->{_def_name_}/$self->{_name_}.disc.log");


  $self->{_stats_table_} = \%table;

}


sub _measure_memory {

  my ($self, %arg) = @_;

  my $mem = 1;
  my @mem = ();
  while ($mem > 0) {
    sleep $arg{"deltaT"};
    $mem = $self->_memory_usage($arg{"pid"});
    push(@mem,$mem);
  }

  open(OM, ">>", "$self->{_output_}/$self->{_def_name_}/$self->{_name_}.mem.log") || die "$!";

  print OM "#"
    .join("\t",@{$arg{"cmds"}->{"header-tags"}})
    ."\tBootstrap"
    ."\tPID"
    ."\tMemAvg(MB)"
    ."\tMemSD(MB)"
    ."\tMemMax(MB)"
    ."\tMem(MB)_[$arg{deltaT} sec]"
    ."\tCmd"
    ."\n" if $arg{"swtch"}->[0] == 0 && $arg{"swtch"}->[1] == 1 ;

  print OM ""
    .join("\t",@{$arg{"cmds"}->{"cmd"}->{$arg{"swtch"}->[0]}->{"tags"}})
    ."\t" . $arg{"swtch"}->[1]
    ."\t" . $arg{"pid"}
    ."\t" . mean(@mem)
    ."\t" . stddev(@mem)
    ."\t" . $self->_max(@mem)
    ."\t" . join(",",@mem)
    ."\t" . $arg{"cmds"}->{"cmd"}->{$arg{"swtch"}->[0]}->{"exe"}
    ."\n";

  close OM;

}

sub _measure_runtime{

  my ($self, %arg) = @_;

  my $start_time = [Time::HiRes::gettimeofday()];
  system("$arg{cmds}->{cmd}->{$arg{swtch}->[0]}->{exe} 2> $self->{_output_}/$self->{_def_name_}/$self->{_log_}");
  my ($user, $system, $child_user, $child_system) = times;
  my $clock =  Time::HiRes::tv_interval($start_time);

  open(OT, ">>", "$self->{_output_}/$self->{_def_name_}/$self->{_name_}.rtime.log") || die "$!";

  print OT "#"
    .join("\t",@{$arg{"cmds"}->{"header-tags"}})
    ."\tBootstrap"
    ."\tPID"
    ."\tUserTime"
    ."\tSysTime"
    ."\tTotTime"
    ."\tCmd"
    ."\n" if $arg{"swtch"}->[0] == 0 && $arg{"swtch"}->[1] == 1 ;

  print OT ""
    .join("\t",@{$arg{"cmds"}->{"cmd"}->{$arg{"swtch"}->[0]}->{"tags"}})
    ."\t" . $arg{"swtch"}->[1]
    ."\t" . $arg{"pid"}
    ."\t" . $child_user
    ."\t" . $child_system
    ."\t" . $clock
    ."\t" . $arg{"cmds"}->{"cmd"}->{$arg{"swtch"}->[0]}->{"exe"}
    ."\n";

  close OT;

}


sub _measure_disc {

  my ($self,%arg) = @_;

  my @flags = @{$arg{"cmds"}->{"cmd"}->{$arg{"swtch"}->[0]}->{"flags"}};
  my @cmd   = split(" ",$arg{"cmds"}->{"cmd"}->{$arg{"swtch"}->[0]}->{"exe"});
  my @flag_res = ();

  for (my $q=0; $q<@cmd; $q++){
    for (my $f = 0; $f < @flags; $f++) {
      if ($cmd[$q] eq $flags[$f]){
        my $d = qx(du -b $cmd[$q+1]);
        $d=~/^(.*?)\s+/;
        $flag_res[$f] = $1;
      }
    }
  }


  open(OD, ">>", "$self->{_output_}/$self->{_def_name_}/$self->{_name_}.disc.log") || die "$!";

  print OD "#"
    .join("\t",@{$arg{"cmds"}->{"header-tags"}})
    ."\tBootstrap"
    ."\tPID"
    ."\tDiscUsageFlags:"
    .join("\t",@{$arg{"cmds"}->{"header-flags"}})
    ."\tCmd"
    ."\n" if $arg{"swtch"}->[0] == 0 && $arg{"swtch"}->[1] == 1 ;

  print OD ""
    .join("\t",@{$arg{"cmds"}->{"cmd"}->{$arg{"swtch"}->[0]}->{"tags"}})
    ."\t" . $arg{"swtch"}->[1]
    ."\t" . $arg{"pid"}
    ."\t" . join("\t",@flag_res)
    ."\t" . $arg{"cmds"}->{"cmd"}->{$arg{"swtch"}->[0]}->{"exe"}
    ."\n";

  close OD;

}


sub _parse_script{

  my ($self,$arg) = @_;

  open (SC, "<", $arg) || die "$!";

  my %schema = ();
  my $i = 0;

  while (<SC>){
    chomp;
    next if /#/ || /^$/ || /^ *$/;
    if (/%Tags:(.*)/){
      my $t = $1;
      $t =~ s/ //g;
      foreach my $tag (split(",", $t)){
        push(@{$schema{"cmd"}{$i}{"tags"}},$tag);
      }
    }elsif(/%Flags:(.*)/){
      my $f = $1;
      $f =~ s/ //g;
      foreach my $flag (split(",", $f)){
        push(@{$schema{"cmd"}{$i}{"flags"}},$flag);
      }
    }elsif(/%TagClasses:(.*)/){
      my $c = $1;
      $c =~ s/ //g;
      foreach my $head (split(",", $c)){
        push(@{$schema{"header-tags"}},$head);
      }
    }elsif(/%FlagClasses:(.*)/){
      my $c = $1;
      $c =~ s/ //g;
      foreach my $head (split(",", $c)){
        push(@{$schema{"header-flags"}},$head);
      }
    }
    else{
      $schema{"cmd"}{$i++}{"exe"} = $_;
    }
  }
  close SC;

  return \%schema;
}


sub _makepath {

  my ($self,$directory) = @_;

  if ( !-d $directory ) {
      make_path $directory or die "Failed to create path: $directory";
  }
}


sub _max{

  my ($self, @arg) = @_;

  my $max = 0;
  foreach my $m (@arg){
    $max = $m if $m > $max;
  }
  return $max;
}


sub _memory_usage() {

    my ($self,$pp) = @_;

    my $t = new Proc::ProcessTable;
    foreach my $got (@{$t->table}) {
        next unless $got->pid eq $pp;
        return (sprintf ("%.2f", $got->size / 1000000));
    }

}


1;

=pod

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
=cut
