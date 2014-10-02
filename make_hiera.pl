#!/usr/bin/perl

$file = $ARGV[0];

open fin, "< $file" or die "Can't open $file: $!\n";
while ($line = <fin>){
  chomp($line);
  $line =~ s/(\s+)?\$fuel_settings(\s+)?=(\s+)?parseyaml(.*)/#$1\$fuel_settings$2=$3parseyaml$4/g ;
  $line =~ s/\$(::)?fuel_settings\[([\w\'\"\$\:\{\}\-]+)\]/hiera($2)/g ;
  $line =~ s/(hiera\([\w\'\"]+\))\[([\w\'\"\$\:\{\}\-]+)\]/value_by_key($1, $2)/g ;
  # repeat N times to fix deep hashes
  for($i=0; $i < 10; $i++){
    $line =~ s/(value_by_key\(.*\))\[([\w\'\"\$\:\{\}\-]+)\]/value_by_key($1, $2)/g ;
  }
  # 10 should be enough :)
  print "$line\n";
}
close(fin);

