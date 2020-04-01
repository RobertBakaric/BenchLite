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
package BenchLite::Stats::Matrix;


use vars qw($VERSION);

$VERSION = '0.01';

#---------------------------------------------------------#
#                     Libraries
#---------------------------------------------------------#

use strict;
use warnings;
use Data::Dumper;
use Math::Complex;
use BenchLite::Stats::Summary;

#---------------------------------------------------------#
#                      CONSTRUCTOR
#---------------------------------------------------------#

sub new {
    my ($class) = @_;

    my $self->{_mtx_} = [];

    bless $self, $class;
    return $self;
}



#---------------------------------------------------------#
#                       Get
#---------------------------------------------------------#

sub get_stats_matrix {
  my ($self) = @_;

  return $self->{_mtx_};
}

sub get_2d_matrix {
  my ($self) = @_;

  return $self->{_mtx_};
}


#---------------------------------------------------------#
#                       Compute
#---------------------------------------------------------#

sub make_2d_matrix {

  my ($self, @arg) = @_;


  die "Input array should be unbalanced 2d  array  \n" unless (ref $arg[0] eq 'ARRAY');

  my $a2d = ();
  if (@arg == 1){
    $a2d = \@arg;
  }else{
    foreach my $j (@{$arg[0]}){
      push (@{$a2d}, [$j]);
    }
    for (my $i=1; $i<@arg; $i++){
      $a2d = $self->_combine($a2d, $arg[$i]);
    }
  }

  return $a2d;

}


sub compute_stats_matrix {

  my ($self, $arg) = @_;

  $self->{_mtx_} = ();

  $self->recompute_stats_matrix($arg);

}

sub recompute_stats_matrix {

  my ($self, $arg) = @_;

  if (!$self->{_mtx_}){
    $self->{_mtx_} = [];
  }
  $self->_recurse($arg,$self->{_mtx_});

}


#---------------------------------------------------------#
#                       Private methods
#---------------------------------------------------------#


sub _combine {

  my ($self, @arg) =  @_;
  my @array = ();
  foreach my $i (@{$arg[0]}){
    foreach my $j (@{$arg[1]}){
      push(@array, [@{$i},$j]);
    }
  }
  return \@array;
}


sub _recurse {

  my ($self, $in, $out) = @_;

  for (my $i = 0;$i<@{$in};$i++){
    if (ref $in->[$i] eq 'ARRAY'){
      if (!$out->[$i]){
        $out->[$i] = [];
      }
      $self->_recurse($in->[$i], $out->[$i]);
    }else{
      if (!$out->[$i]){
        my $st = BenchLite::Stats::Summary->new();
        $st->compute_stats($in->[$i]);
        $out->[$i] = $st;
      }else{
        $out->[$i]->recompute_stats($in->[$i]);
      }
    }
  }
}


1;
