#!/usr/bin/perl
use strict; use warnings;

my @AoA;

while ( <> ) {
  push @AoA , $_;
}

my %HoH;

foreach ( @AoA ) {
  if ( /(<<|>>) (.+) \((.+)\)/ ) {
    $HoH{$3}{$1} = $2;
  }
}

sub convert_type {
  my $symbol = shift;
  my %Symbol_Hash = ( "<<" => "new" , ">>" => "old" );
  return $Symbol_Hash{$symbol} if exists $Symbol_Hash{$symbol};
  return $symbol;
}

my $forks = 0;

foreach my $comp ( sort keys %HoH ) {
  if ( 0 == fork ) {

    my $string = "$forks: component=\"$comp\"";

    foreach my $type ( sort keys %{ $HoH{$comp} } ) {
      my $attrib = convert_type($type);
      $string = "$string $attrib=\"$HoH{$comp}{$type}\"";

    }
    open FILE, ">" , "$forks.txt" or die $!;
    print FILE "$string\n";
    close FILE;
    exit 0;
  }
  $forks++;
}

while ( -1 != wait ) {}

my @final;
for my $i ( 0 .. ( $forks - 1 ) ) {
  push @final, "$i.txt";
}

foreach my $file ( @final ) {
  open FH , "<" , $file  or die "$!: $file";
  while ( <FH> ) { print $_; }
  close FH;
}

my $deleted = unlink @final or die $!;
print "temp files deleted: $deleted\n";
