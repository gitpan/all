#!/usr/bin/perl

use Test::More 'no_plan';

eval {
  use all 'IO::';
};
if (!$@) {
  ok(my $sock = IO::Socket->new());
}

1;
