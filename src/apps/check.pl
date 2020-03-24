#! /usr/bin/perl


use strict;
use warnings;
use IPC::Cmd qw[can_run run];


my %sys_require=( #system-wide executables required
		'r' 		=> ['Rscript'],
		'gzip'		=> ['gzip','gunzip'],
		'tar'		=> ['tar'],
);
my %exe_require=( #core executables for each program
		'fastqc' 	=> ['fastqc'],
		'bowtie' 	=> ['bowtie'],
    'alfred'  => ['alfred'],
    'qualimap'=> ['qualimap'],
    'bedmap'  => ['bedmap'],
    'gtf2bed' => ['gtf2bed'],
    'multiqc' => ['multiqc'],
#		'bowtie2' 	=> ['bowtie2'],
		'picard' 		=> ['picard'],
		'bedtools' 		=> ['bedtools'],
		'samtools' 	=> ['samtools','bcftools'],
		'circleator' => ['circleator']
		'bamCoverage' => ['bamCoverage']
#		'gatklite' 	=> ['GenomeAnalysisTKLite.jar'],
#		'gatk' 		=> ['GenomeAnalysisTK.jar'],    # old
#		'picard' 	=> ['SortSam.jar','MarkDuplicates.jar'], # old
#		'soap'		=> ['soap'],
#		'varscan' 	=> ['varscan.jar'],
#		'soapsnp' 	=> ['soapsnp','msort','soap2sam.pl'],
		'tabix'		=> ['bgzip','tabix'],
		'vcftools'	=> ['vcftools'],
		'freebayes'	=> ['freebayes'],
#		'snap'		=> ['snap'],
		'vt'		=> ['vt'],
);


# Check sys_tools

warn "\nSys prerequisites... ok!\n\n" if &_check_exists(\%sys_require);

# Check aux tools

warn "\nAux prerequisites... ok!\n\n" if &_check_exists(\%exe_require);


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
