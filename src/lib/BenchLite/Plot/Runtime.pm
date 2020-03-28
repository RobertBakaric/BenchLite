package BenchLite::Plot::Runtime;
#---------------------------------------------------------#
#                     Libraries
#---------------------------------------------------------#

use strict;
use warnings;
use Data::Dumper;


#---------------------------------------------------------#
#                      CONSTRUCTOR
#---------------------------------------------------------#

sub new {
    my ($class) = @_;

    my $self->{_plot_}  = {};

    bless $self, $class;
    return $self;
}


#---------------------------------------------------------#
#                      R code
#---------------------------------------------------------#

# note to myself : edit check-pl to include R dependencies


## logic
#
#  [[-,a,-,b],[-,a,-,B],[-,A,-,b],[-,A,-,B]]
#
#  data
#
#
#  labels
#
#
#  scale
#
#  x= "log_2_1000" -> log_2(x/1000)  || 1000  -> x/1000

sub make_plots {

  my ($self, @arg) = @_;


  my $logic    = @{$arg[0]};
  my $data     = @{$arg[1]};


  foreach my $select (){

  }
}





1;
