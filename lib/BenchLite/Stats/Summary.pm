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
package BenchLite::Stats::Summary;


use vars qw($VERSION);

$VERSION = '0.01';

#---------------------------------------------------------#
#                     Libraries
#---------------------------------------------------------#

use strict;
use warnings;
use Data::Dumper;
use Math::Complex;

#---------------------------------------------------------#
#                      CONSTRUCTOR
#---------------------------------------------------------#

sub new {
    my ($class) = @_;

    my $self->{_mean_} = 0;
    $self->{_sd_}   = 0;
    $self->{_var_}  = 0;
    $self->{_max_}  = 0;
    $self->{_min_}  = 2**31;

    $self->{_i_}  = 0;
    $self->{_m2_} = 0;


    bless $self, $class;
    return $self;
}



#---------------------------------------------------------#
#                       Get
#---------------------------------------------------------#


sub get_mean {
  my ($self) = @_;

  if ($self->{_i_} > 0){
    $self->_finalize_Welford();
  }

  return $self->{_mean_};
}

sub get_var {
  my ($self) = @_;

  if ($self->{_i_} > 0){
    $self->_finalize_Welford();
  }

  return $self->{_var_};
}

sub get_sd {
  my ($self) = @_;

  if ($self->{_i_} > 0){
    $self->_finalize_Welford();
  }

  return $self->{_sd_};
}

sub get_max {
  my ($self) = @_;

  return $self->{_max_};
}

sub get_min {
  my ($self) = @_;
  return $self->{_min_};
}


#---------------------------------------------------------#
#                        Compute
#---------------------------------------------------------#


sub compute_max {
  my ($self, @arg) = @_;

  foreach my $m (@arg){
    $self->{_max_} = $m if $m > $self->{_max_};
  }

}

sub compute_min {
  my ($self, @arg) = @_;

  foreach my $m (@arg){
    $self->{_min_} = $m if $m < $self->{_min_};
  }
}

sub compute_mean {
  my ($self, @arg) = @_;

  die "Error: compute_mean: @arg \n" if @arg == 0;

  my $sum = 0;
  foreach my $x (@arg){
    $sum +=$x;
  }
  $self->{_mean_} = $sum/@arg;
}

sub compute_var {
  my ($self, @arg) = @_;
  die "Error: compute_var: @arg \n" if @arg == 0;

  $self->compute_mean(@arg);

  my $sum = 0;
  foreach my $x (@arg){
    $sum += (($x - $self->{_mean_})**2);
  }
  $self->{_var_} = $sum/@arg;
}

sub compute_sd {
  my ($self, @arg) = @_;

  $self->compute_var(@arg);
  $self->{_sd_} = sqrt($self->{_var_});
}



sub compute_stats {

  my ($self, $arg) = @_;

  ($self->{_sd_},
   $self->{_mean_},
   $self->{_var_},
   $self->{_m2_},
   $self->{_i_},
   $self->{_max_},
   $self->{_min_}) = (0,0,0,0,0,0,0);

  $self->recompute_stats($arg);

}

sub recompute_stats {

  my ($self, $arg) = @_;

  if (ref $arg eq 'ARRAY'){
    foreach my $x (@{$arg}){
      $self->_Welford($x,$self->{_m2_}, $self->{_i_});
    }
  }else{
    $self->_Welford($arg,$self->{_m2_}, $self->{_i_});
  }

}


#---------------------------------------------------------#
#                 Private methods
#---------------------------------------------------------#

sub _Welford {
  my ($self,$x,$m,$i) = @_;

  $self->{_i_}++;
  my $d = $x - $self->{_mean_};
  $self->{_mean_} += $d/$self->{_i_};
  my $d2 = $x-$self->{_mean_};
  $self->{_m2_} += $d*$d2;

}

sub _finalize_Welford {
  my ($self) = @_;

  if ($self->{_i_} < 2){
    $self->{_var_} = 'NaN';
    $self->{_sd_} = 'NaN';
  }else{
    $self->{_var_} = $self->{_m2_}/$self->{_i_};
    $self->{_sd_} = sqrt($self->{_var_});
  }
  $self->{_i_}  = 0;
  $self->{_m2_} = 0;
}



1;
