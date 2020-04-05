use strict;
use lib "./";
use tmp;

my $z = tmp->new();

my $a = [[1,2],[2,3]];
my $b = [[4,5],[6,7]];

$z->copycomp_matrix($a);

