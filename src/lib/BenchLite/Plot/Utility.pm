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

package BenchLite::Plot::Utility;
#---------------------------------------------------------#
#                     Libraries
#---------------------------------------------------------#

use strict;
use warnings;
use Data::Dumper;
use BenchLite::Plot::Runtime;


#---------------------------------------------------------#
#                      CONSTRUCTOR
#---------------------------------------------------------#

sub new {
    my ($class) = @_;

    #------------------------DATA-------------------------#
    my $self->{_data_}      = {};
    $self->{_R_} = ();
    $self->{_libs_} = [
      "ggplot2",
      "grid",
      "gridExtra",
      "ggpubr",
      "tidyverse",
      "scales"
    ];


    #-----------------------OUTPUT------------------------#
    $self->{_output_}       = "./";

    bless $self, $class;
    return $self;
}


#---------------------------------------------------------#
#                       Methods
#---------------------------------------------------------#


sub plot {

  my ($self,$select, $data) = @_;

  #check
  if (!$self->_check_R_libs()){
    print STDERR "Loading libraries failed!";
  };


  my $run_R = BenchLite::Plot::Runtime->new();
  #my $disc_R = BenchLite::Plot::Disc->new();
  #my $mem_R = BenchLite::Plot::Memory->new();


  $run_R->{_R_} = $self->{_R_};

  my ($r,$o,$b) = (0,0,0);
  my @runs = ();
  my @mems = ();
  my @dscs = ();
  # load data

  foreach my $plot (keys %{$select->{'plot'}}){

    if ($plot eq 'runtime'){
      my @runplots =  sort{ $a <=> $b } keys %{$select->{'plot'}->{$plot}};
      my $stop = @runplots;
      my $tr  = $stop % 3;
      my $st = ($tr==0) ? ($stop-3) : ($stop-$tr);
      foreach my $rt_plot (@runplots){
        push(@runs, $run_R->plot($r++, (($r>$st)?(1):(0)), $select->{'plot'}->{$plot}->{$rt_plot}, $data, "Test_$rt_plot\_$r"));
      }
    }elsif ($plot eq 'disc'){

    }elsif($plot eq 'memory'){

    }else{
      print "I do not recognize $plot format\n";
    }

  }


  # plot
  $run_R->plot_summary(@runs);
  #$self->plot_memory();
  #$self->plot_disc();

  return $self->{_output_};
}




#---------------------------------------------------------#
#                   Private Methods
#---------------------------------------------------------#


sub _check_R_libs {

  my ($self) = @_;

  my $ok = 0;
  my $check_fn  = << "R";
  install_load <- function (package, ...)  {
    if(package %in% rownames(installed.packages()))
      do.call('library', list(package))
    else {
      install.packages(package)
      do.call("library", list(package))
    }
  }
R

  $self->{_R_}->run($check_fn);

  foreach my $lib (@{$self->{_libs_}}){
    my $line = "install_load(\'$lib\')";
    $ok = $self->{_R_}->run($line);
  }
  return  ($ok) ? (1) : (0);
}



1;
