#!/usr/bin/perl

use Test::More no_plan => 1;

eval {
  use all of => IO::;
};
if (!$@) {
  ok(my $sock = IO::Socket->new());
}

1;
