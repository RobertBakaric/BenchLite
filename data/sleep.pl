use strict;
use Getopt::Long;

my ($help, $script, $limit, $out);
GetOptions ("i=s" => \$script,
            "h" => \$help,
            "x=i" => \$limit,
            "o=s" => \$out,
            );

if($help  || !$script ){
  print "Usage:\n\n";
  print "\t-i\tInput file\n";
  print "\t-x\tlimit\n";
  print "\t-o\toutput\n";
  exit(0);
}

my $d = int($limit/10);
my @a = ();
for (my $i = 0; $i<$limit;$i++){
  if ($i%$d == 0){
    sleep 1;
  }
  push(@a,$i);
}

sleep 2;

if ($out){
  open (O, ">", $out) || die "$!";
  print O "@a";
  close O;
}else{
  print  "@a";
}
