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
package BenchLite::Plot::Runtime;
#---------------------------------------------------------#
#                     Libraries
#---------------------------------------------------------#

use strict;
use warnings;
use Data::Dumper;
use Statistics::R;

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
#  x= "log2_1000" -> log2(x/1000)  || 1000  -> x/1000

sub make_plots {

  my ($self, @arg) = @_;


  my $logic    = @{$arg[0]};
  my $data     = @{$arg[1]};


  foreach my $select (){

  }
}


# remember to check for dependencies!!
#### NOt finished work in progress ...!!!!!!!!
sub _plot {

  my ($self, ) = @_;


  my $x_scale = "";
  my $y_scale  = "";
  my $annotation = "";


  if ($arg[0] =~/log(\d+)/){
    $x_scale = "scale_x_$arg[0](breaks = trans_breaks(\"$arg[0]\", function(x) $1^x), labels = trans_format(\"$arg[0]\", math_format($1^.x))) + ";
  }else{
    $x_scale = "";
  }


  if ($arg[0] =~/log(\d+)/){
    $y_scale = "scale_y_$arg[0](breaks = trans_breaks(\"$arg[0]\", function(x) $1^x), labels = trans_format(\"$arg[0]\", math_format($1^.x))) +";
    $annotation = "annotation_logticks() +";
  }else{
    $y_scale = "";
    $annotation ="";
  }



# this needs to be split into
my $Rcode << R;

svg("Runtime.svg",width=10, height=8)

pp <- ggarrange(p1, p3, p5, p2, p4, p6, ncol=3, nrow=2, align = "v", common.legend = TRUE, legend="bottom")
text = paste("       Lossy","              Complete", sep = "                                          ")
annotate_figure(pp,
                top = text_grob("Common title", face = "bold", size = 16),
                left = text_grob(text, color = "black", rot = 90, size = 14))
dev.off()


R

  my $R = Statistics::R->new();

  $R->set( $arg[xxx], \@runtime ) ;
  $R->set( $arg[xxx], \@runtime_sd ) ;
  $R->set( $arg[xxx], \@input ) ;

  my $out2 = $R->run($Rcode);


}



sub _make_table_and_plot_fn{

  my ($self, @arg) = @_;

  my $return  = "";
  foreach my $p (){
    my $tab = "";
    foreach my $col (@arg){
      $tab .= " $col, ";
    }

    my $table =  "df <- data.frame($tab stringsAsFactors = FALSE)\n";
    my $plot = "p1 <- make_runtime_plot(df, $title) + xlab("")\n";
    $return .= $table . $plot;
  }

  return $return;


}


sub _make_plot_fn {

  my ($self,$x,$y,$group,$x_scale,$y_scale,$x_lab,$y_lab,$annotation) =@_;


  return << "R";

  make_runtime_plot <- function(tdf, Title) {
    p <-ggplot(tdf, aes(x=$x, y=$y, group=$groups, color=$groups)) +
      geom_line()+
      geom_point()+
      $x_scale
      $y_scale
      scale_color_brewer(palette="Paired")+
      $annotation
      labs(x = "$x_lab", y = "$y_lab", title = Title)+
      theme_classic() +
      theme(plot.title = element_text(hjust = 0.5),
            legend.position="bottom")

    return(p)
  }


R


}


sub _load_libraries {


  my ($self) =@_;

  my $util = BenchLite::Plot::Utility->new();

  my @lib = (
  "library(ggplot2)",
  "library(grid)",
  "library(gridExtra)",
  "library(ggpubr)",
  "library(tidyverse)",
  "library(scales)"
  );

  $util->load_lib(\@lib);
  return $util->get_code();

}



1;
