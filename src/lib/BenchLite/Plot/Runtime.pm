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
  $x_scale = "scale_x_$arg[0](breaks = trans_breaks(\"$arg[0]\", function(x) $1^x), labels = trans_format(\"$arg[0]\", math_format($1^.x)))";
}else{

}


if ($arg[0] =~/log(\d+)/){
  $y_scale = "scale_y_$arg[0](breaks = trans_breaks(\"$arg[0]\", function(x) $1^x), labels = trans_format(\"$arg[0]\", math_format($1^.x))) + ";
  $annotation = "annotation_logticks()";
}else{

}


my $Rcode << R;


#  Load Libraries
library(ggplot2)
library(grid)
library(gridExtra)
library(ggpubr)
library(tidyverse)
library(scales)

make_runtime_plot <- function(tdf, Title) {
  p <-ggplot(tdf, aes(x=$x, y=$y, group=$groups, color=$groups)) +
    geom_line()+
    geom_point()+
    $x_scale +
    $y_scale +
    scale_color_brewer(palette="Paired")+
    $annotation +
    labs(x = "$x_lab", y = "$y_lab", title = Title)+
    theme_classic() +
    theme(plot.title = element_text(hjust = 0.5),
          legend.position="bottom")

  return(p)
}

df <- read.table("C:/Users/Neva/Documents/Robert/MemRunTable.tsv",header = TRUE,sep="\t",stringsAsFactors = FALSE)

# Make a new column
df\$Machine_Tool <- paste(df\$Machine, df\$Tool, sep="_")

# Reorder columns
df <- df[,c(1:2,9,3:8)]
tidy_data <- as_tibble(df)

svg("Runtime.svg",width=10, height=8)

p1 <- make_runtime_plot(filter(tidy_data, Type == 'Complete' & Process == 'Compress'), "Compress") +
  xlab("")
p2 <- make_runtime_plot(filter(tidy_data, ((Type == 'Lossy' & Tool == 'sfq') | (Type == 'Complete' & Tool == 'spring') ) & Process == 'Compress'), "")
p3 <- make_runtime_plot(filter(tidy_data, Type == 'Complete' & (Process == 'Decompress' | Process == 'Decompress-M')), "Decompress (RamMode)") +
  xlab("") + ylab("")
p4 <- make_runtime_plot(filter(tidy_data, ((Type == 'Lossy' & Tool == 'sfq') | (Type == 'Complete' & Tool == 'spring') ) & (Process == 'Decompress' | Process == 'Decompress-M')), "") +
  ylab("")
p5 <- make_runtime_plot(filter(tidy_data, Type == 'Complete' & (Process == 'Decompress' | Process == 'Decompress-D')), "Decompress (DiscMode)") +
  xlab("") + ylab("")
p6 <- make_runtime_plot(filter(tidy_data, ((Type == 'Lossy' & Tool == 'sfq') | (Type == 'Complete' & Tool == 'spring') ) & (Process == 'Decompress' | Process == 'Decompress-D')), "") +
  ylab("")

pp <- ggarrange(p1, p3, p5, p2, p4, p6, ncol=3, nrow=2, align = "v", common.legend = TRUE, legend="bottom")
text = paste("       Lossy","              Complete", sep = "                                          ")
annotate_figure(pp,
                top = text_grob("Common title", face = "bold", size = 16),
                left = text_grob(text, color = "black", rot = 90, size = 14))
dev.off()


R

  my $R = Statistics::R->new();
  $R->startR;
  $R->send($Rcode);
  $R->stopR();


}





1;
