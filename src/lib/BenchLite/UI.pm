package BenchLite::UI;
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

    my $self->{_script_}  = {};

    bless $self, $class;
    return $self;
}



#---------------------------------------------------------#
#                       Get
#---------------------------------------------------------#

sub get_cmd {
  my ($self) = @_;
  return $self->{_script_}->{"cmd"};
}

sub get_plot {
  my ($self) = @_;
  $self->_rm_plot_dupl();
  return $self->{_script_}->{"plot"};
}

sub get_head {
  my ($self) = @_;
  return $self->{_script_}->{"head"};
}

sub get_script {
  my ($self) = @_;

  $self->_rm_plot_dupl();
  return $self->{_script_};
}

#---------------------------------------------------------#
#                       Parser
#---------------------------------------------------------#

sub run_shell {
  my ($self, $shell) = @_;


  while(<>){
    ## parse
    ## evaluate
    ## return
  }

}


sub parse_script{

  my ($self,$arg) = @_;

  open (SC, "<", $arg) || die "$!";

  my $i = 0;

  while (<SC>){
    chomp;
    # skip all that is irellevant
    next if /#/ || /^$/ || /^ *$/;

    if (/%/){
      if (/(Tags:|Flags:)/){
        $self->_eval_label($_,$i);
      }elsif(/Classes:/){
        $self->_eval_head($_);
      }elsif(/Plot/){
        $self->_eval_plot($_);
      }
    }else{
      $self->{_script_}->{"cmd"}->{$i++}->{"exe"} = $_;
    }
  }
  close SC;




}



#---------------------------------------------------------#
#                       Private
#---------------------------------------------------------#



sub _eval_plot {

  my ($self, $plot) = @_;

  if($plot =~ /%Plot:(.*)/){
    my $c = $1;
    $self->_parse_desc($c, "plot", "runtime");
    $self->_parse_desc($c, "plot", "memory");
    $self->_parse_desc($c, "plot", "disc");
  }elsif($plot =~ /%PlotRuntime:(.*)/){
    my $c = $1;
    $self->_parse_desc($c, "plot", "runtime");
  }elsif($plot =~ /%PlotDisc:(.*)/){
    my $c = $1;
    $self->_parse_desc($c, "plot", "disc");
  }elsif($plot =~ /%PlotMemory:(.*)/){
    my $c = $1;
    $self->_parse_desc($c, "plot", "memory");
  }else{
    die "$plot : Not a proper plot syntax!";
  }


}



sub _eval_head {

  my ($self, $head) = @_;

  if($head =~ /%TagClasses:(.*)/){
    my $c = $1;
    $self->_parse_desc($c, "head", "tags");
  }elsif($head =~ /%FlagClasses:(.*)/){
    my $c = $1;
    $self->_parse_desc($c, "head", "flags");
  }else{
    die "$head : Not a proper head syntax!";
  }

}

sub _eval_label {

  my ($self, $lab, $i) = @_;

  if ($lab =~ /%Tags:(.*)/){
    my $t = $1;
    $self->_parse_cmd($t, "cmd", $i, "tags");
  }elsif($lab =~ /%Flags:(.*)/){
    my $f = $1;
    $self->_parse_cmd($f, "cmd", $i, "flags");
  }else{
    die "$lab : Not a proper cmd syntax!";
  }

}


sub _parse_desc {
  my ($self, $desc, $cmd, $what) = @_;

  $desc =~ s/ //g;
  my @mtx = ();
  foreach my $p (split(",", $desc)){
    if ($cmd eq "plot"){
      if ($p=~/\//){
        my @os = split("/", $p);
        push(@mtx, \@os);
      }else{
        push(@mtx, [$p]);
      }
    }else{
      push(@{$self->{_script_}->{$cmd}->{$what}},$p);
    }
  }

  if ($cmd eq "plot"){
    my $mtx = BenchLite::Stats::Matrix->new();
    push(@{$self->{_script_}->{$cmd}->{$what}} ,@{$mtx->make_2d_matrix(@mtx)});
  }




}

sub _parse_cmd {
  my ($self, $plot, $cmd, $i, $what) = @_;

  $plot =~ s/ //g;
  foreach my $p (split(",", $plot)){
    push(@{$self->{_script_}->{$cmd}->{$i}->{$what}},$p);
  }
}


sub _rm_plot_dupl {

  my ($self)  = @_;

  foreach my $k (keys %{$self->{_script_}->{"plot"}}){
    my $tmp = $self->_uniq(@{$self->{_script_}->{"plot"}->{$k}});
    $self->{_script_}->{"plot"}->{$k} = $tmp;
  }



}

sub _uniq {

  my ($self,@arr) = @_;

    my %seen;my @out;
    foreach my $k (@arr){
      next if (defined $seen{join("",@$k)});
      push(@out, $k);
      $seen{join("",@$k)}++;
    }

    return \@out;
}

1;
