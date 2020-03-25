package Bench::BenchLite;
#---------------------------------------------------------#
#                     Libraries
#---------------------------------------------------------#

use strict;
use warnings;
use Statistics::Basic qw(:all nofill);
use Data::Dumper;
use Math::Complex;

#---------------------------------------------------------#
#                      CONSTRUCTOR
#---------------------------------------------------------#

sub new {
    my ($class) = @_;

    $self->{_mean_} = 0;
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
#                     Set/Push
#---------------------------------------------------------#


sub compute_mean {
  my ($self, @arg) = @_;

  my $sum = 0;
  foreach my $x (@arg){
    $sum +=$x;
  }
  $self->{_mean_} = $sum/@arg;
}

sub compute_var {
  my ($self, @arg) = @_;

  $self->compute_mean(@arg);

  my $sum = 0;
  foreach my $x (@arg){
    $sum += (($x-$self->{_mean_})**2);
  }
  $self->{_var_} = $sum/@arg;
}

sub compute_sd {
  my ($self, @arg) = @_;

  $self->compute_var(@arg);
  $self->{_sd_} = sqrt($self->{_var_});
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
  my $d = $x- $self->{_mean_};
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
