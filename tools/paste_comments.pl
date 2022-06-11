#!/usr/bin/perl -w

use strict;

my $base = 0x8000;
my $src = shift(@ARGV);
my $heading = "";
my @heading;
my @label;
my @comment;

open(SRC,"<".$src) or die;
while(<SRC>) {
  # Accumulate headings - comments on their own line
  if(/^\s*;\s*(.*)$/) {
    $heading .= "; " . $1 . "\n";
    $heading =~ y/\r//d; # suppress CR
  }

  # Bind accumulated headings to the next address found
  # and clear accumulator
  if(/^([0-9A-Fa-f]{4})/) { # code
    my $addr = hex($1) - $base;
    $heading[$addr] = $heading unless defined($heading[$addr]);
    $heading = "";
  } elsif(/^\.([PQRS][0-9A-Fa-f]{3})/) { # labels
    my $addr = $1;
    $addr =~ y/PQRS/89AB/;
    $addr = hex($addr) - $base;
    $heading[$addr] = $heading unless defined($heading[$addr]);
    $heading = "";
  }

  # Bind comments on code and labels to their respective address
  if(/^([0-9A-Fa-f]{4}).*\s;\s*(.*)$/) { # code comments
    my $addr = hex($1) - $base;
    my $comment = $2;
    $comment =~ y/\r//d;
    $comment[$addr] = $comment;
  } elsif(/^\.([PQRS][0-9A-Fa-f]{3})\s*;\s*(.*)$/) { # label comments
    my $addr = $1;
    my $label = $2;
    $addr =~ y/PQRS/89AB/;
    $addr = hex($addr) - $base;
    $label =~ y/\r//d; # suppress CR
    $label[$addr] = "; " . $label . "\n";
  }
}
close(SRC);

# Copy lines from standard input, insert headings and substitute comments
# Hold labels over for one line, to print them after address-triggered
# headings
my $da65label = "";
# Read lines into $_ until EOF
while(<>) {
  if(/;\s*([0-9A-Fa-f]{4})\s+[0-9A-Fa-f]{2}.*$/) { # hex dump after instr.
    my $addr = hex($1) - $base;
    print $heading[$addr] if defined($heading[$addr]);
    print $label[$addr] if defined($label[$addr]);
  }
  print $da65label; # now print held-over label
  $da65label = "";
  y/\r//d; # suppress CR in $_
  # replace hex dump in $_ with comment
  s[;\s*([0-9A-Fa-f]{4})\s+[0-9A-Fa-f]{2}.*$]
    ["; ".(defined($comment[hex($1)-$base])?$comment[hex($1)-$base]:"")]e;
  s/\s*;\s*$/\n/; # suppress trailing whitespace
  if(/^[^;]+:$/) { # label without instruction
    $da65label = $_;
  } else {
    print$_;
  }
}
