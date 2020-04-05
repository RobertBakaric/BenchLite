#! /usr/bin/perl


use strict;
use warnings;
use IPC::Cmd qw[can_run run];


my %sys_require=( #system-wide executables required
		'r' 		=> ['Rscript','R'],
		'gzip'	=> ['gzip','gunzip'],
		'tar'		=> ['tar'],
);
my %exe_require=( #core executables for each program
		'rlibs' 	=> ['ggplot2', 'ggpubr', 'scales', 'grid', 'gridExtra', 'tidyverse'],
);

# Check sys_tools

warn "\nSys prerequisites... ok!\n\n" if &_check_exists(\%sys_require);

# Check aux tools

warn "\nAux prerequisites... ok!\n\n" if &_check_aux(\%exe_require);


print "\n\n";


sub _check_exists {

  my ($arg) = @_;

  warn "Checking ...\n";

  warn "===========================================\n";

  my $bool = 1;
  foreach my $tool (sort keys %$arg){
    foreach my $comp (@{$arg->{$tool}}){

      if (!can_run($comp)){
          warn "$comp", "." x (40-length($comp)) .  "missing!\n";
          $bool = 0;
      }else{
        warn "$comp", "." x (40-length($comp))  . "ok!\n";
      }
    }
  }
  warn "\n\nPlease install missing !!\n" if $bool == 0;
  return $bool;
}


sub _check_aux {

	my ($arg) = @_;

	warn "Checking  ...\n";

	warn "=============================================================\n";

	my $bool = 1;
	foreach my $tool (sort keys %$arg){

		if ($tool eq 'rlibs'){
			foreach my $comp (@{$arg->{$tool}}){
				my  $check = qx(Rscript -e \' if(\"$comp\" \%in\% rownames(installed.packages())){1}else{0}\');
				chomp($check);
				if ($check eq '[1] 0' ){
						warn "R Package: $comp", "." x (40-length($comp)) .  "missing!\n";
						$bool = 0;
				}else{
					warn "R Package: $comp", "." x (40-length($comp))  . "installed!\n";
				}
			}
		}else{

		}
	}
	warn "\n\nPlease install missing !!\n" if $bool == 0;
	return $bool;

}
