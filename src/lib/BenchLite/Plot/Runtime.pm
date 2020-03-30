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
use Array::Utils qw(:all);
#---------------------------------------------------------#
#                      CONSTRUCTOR
#---------------------------------------------------------#

sub new {
    my ($class) = @_;

    my $self->{_R_}  = ();
    $self->{_x_scale_} = 'log10';
    $self->{_y_scale_} = 'log10';
    $self->{_x_unit_}  = 'MB';
    $self->{_y_unit_}  = 's';

    $self->{_x_unit_div_}  = 1_000_000;
    $self->{_x_unit_div_}  = 1;



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

sub plot {

  my ($self,$s,$lines,$data,$title) = @_;

    # make plot function

    $self->_set_dafaults();

    #make x-y axis
    my @name = ();
    my @yval  = ();
    my @ysd   = ();
    my @xval  = ();
    my @xsd   = ();
    print "\n\n\n";

print Dumper($lines);
print "\n\n\n";
print Dumper($data->{'runtime'}->{'logic'});
print "\n\n\n";


    foreach my $line (@{$lines}){
      my @selection =();
      for (my $i=0; $i < @{$line}; $i++){
        my @sel = ();
        for(my $j = 0; $j< @{$data->{'runtime'}->{'logic'}}; $j++){
          if ($data->{'runtime'}->{'logic'}->[$j]->[$i] eq $line->[$i] || $line->[$i] eq '-'){
            push (@sel, $j);
            print " $data->{'runtime'}->{'logic'}->[$j]->[$i] eq $line->[$i] \
            $data->{'runtime'}->{'data'}->[$j]->[4]; # runtime \
            $data->{'runtime'}->{'data'}->[$j]->[5]; # runtime sd \
            \n";
          }
        }
        if (@selection > 0) {
          my @isect = intersect(@selection, @sel);
          print "(@isect), (@sel), (@selection) \n";
          @selection = @isect;
        }else{
          @selection =@sel;
        }
        #})
      }

      foreach my $l (@selection){
        push(@name,join("_", @{$data->{'runtime'}->{'logic'}->[$l]}));
        push(@yval, $data->{'runtime'}->{'data'}->[$l]->[4]/$self->{_y_unit_div_});
        push(@ysd,  $data->{'runtime'}->{'data'}->[$l]->[5]/$self->{_y_unit_div_});
        push(@xval, $data->{'disc'}->{'data'}->[$l]->[0]/$self->{_x_unit_div_});
        push(@xsd,  $data->{'disc'}->{'data'}->[$l]->[1]/$self->{_x_unit_div_});
      }
    }

    #set data vectors

    my $x = "FileSize";
    my $y = "Runtime";
    my $group_by = "Identifier";


    $self->{_R_}->set("$group_by", \@name);
    $self->{_R_}->set("$y", \@yval);
    $self->{_R_}->set("$y\_sd", \@ysd);
    $self->{_R_}->set("$x", \@xval);
    $self->{_R_}->set("$x\_sd", \@xsd);

    # plot vectors in series of 3's
    $self->{_R_}->run("data <- data.frame($group_by, $x, $x\_sd, $y, $y\_sd)");

    $self->{_R_}->run(
      $self->_make_plot_obj(
        $x, $y, $group_by, "$x ($self->{_x_unit_})","$y ($self->{_y_unit_})", "$title"
      )
    );

    $self->{_R_}->run("p$s <- make_runtime_plot(data) + xlab(\"\") "); #
    $self->{_R_}->run("p$s");

}


# remember to check for dependencies!!
#### NOt finished work in progress ...!!!!!!!!
=pod
sub _plot {

  my ($self ) = @_;


my $Rcode << "R";

svg("Runtime.svg",width=10, height=8)

pp <- ggarrange(p1, p3, p5, p2, p4, p6, ncol=3, nrow=2, align = "v", common.legend = TRUE, legend="bottom")
text = paste("       Lossy","              Complete", sep = "                                          ")
annotate_figure(pp,
                top = text_grob("Common title", face = "bold", size = 16),
                left = text_grob(text, color = "black", rot = 90, size = 14))
dev.off()


R



}
=cut


sub _set_dafaults{

  my ($self) = @_;

  if ($self->{_x_unit_} eq 'B'){
    $self->{_x_unit_div_} = 1;
  }elsif($self->{_x_unit_} eq 'MB'){
    $self->{_x_unit_div_} = 1_000_000;
  }elsif($self->{_x_unit_} eq 'GB'){
    $self->{_x_unit_div_} = 1_000_000_000;
  }else{
    die "_x_unit_ : $self->{_x_unit_} not properly set (B,MB,GB)\n";
  }

  if ($self->{_y_unit_} eq 's'){
    $self->{_y_unit_div_} = 1;
  }elsif($self->{_x_unit_} eq 'm'){
    $self->{_y_unit_div_} = 60;
  }elsif($self->{_x_unit_} eq 'h'){
    $self->{_y_unit_div_} = 3600;
  }elsif($self->{_x_unit_} eq 'd'){
    $self->{_y_unit_div_} = 86400;
  }else{
    die "_y_unit_ : $self->{_x_unit_} not properly set (s,m,h,d)\n";
  }


}


sub _make_plot_obj {

  my ($self,$x,$y,$group_by,$x_lab,$y_lab, $title) = @_;

  my $x_scale = "";
  my $y_scale  = "";
  my $annotation = "";


  if ($self->{_x_scale_} =~/log(\d+)/){
    $x_scale = "scale_x_$self->{_x_scale_}(breaks = trans_breaks(\"$self->{_x_scale_}\", function(x) $1^x), labels = trans_format(\"$self->{_x_scale_}\", math_format($1^.x))) + ";
  }else{
    $x_scale = "";
  }


  if ($self->{_y_scale_} =~/log(\d+)/){
    $y_scale = "scale_y_$self->{_x_scale_}(breaks = trans_breaks(\"$self->{_y_scale_}\", function(x) $1^x), labels = trans_format(\"$self->{_y_scale_}\", math_format($1^.x))) +";
    $annotation = "annotation_logticks() +";
  }else{
    $y_scale = "";
    $annotation ="";
  }

  return << "R";

  make_runtime_plot <- function(tdf) {
    wdth <- (max(tdf\$$x) - min(tdf\$$x)) * 0.02
    p <-ggplot(tdf, aes(x=$x, y=$y, group=$group_by, color=$group_by)) +
      geom_errorbar(aes(x=$x, ymin=$y-$y\_sd, ymax=$y+$y\_sd), width=wdth, size=.4) +
      geom_line()+
      geom_point()+
      $x_scale
      $y_scale
      scale_color_brewer(palette="Paired")+
      $annotation
      labs(x = "$x_lab", y = "$y_lab", title = \"$title\")+
      theme_classic() +
      theme(plot.title = element_text(hjust = 0.5), legend.position="bottom")

    return(p)
  }
R

}




1;
