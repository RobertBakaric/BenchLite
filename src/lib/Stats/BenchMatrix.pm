package Stats::BenchMatrix;
#---------------------------------------------------------#
#                     Libraries
#---------------------------------------------------------#

use strict;
use warnings;
use Data::Dumper;
use Math::Complex;
use Stats::BenchStats;

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


#---------------------------------------------------------#
#                       Compute
#---------------------------------------------------------#


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
        my $st = Stats::BenchStats->new();
        $st->compute_stats($in->[$i]);
        $out->[$i] = $st;
      }else{
        $out->[$i]->recompute_stats($in->[$i]);
      }
    }
  }
}


1;
