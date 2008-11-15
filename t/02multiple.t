#!/usr/bin/perl

use Test::More 'no_plan';

eval {
  use all 'IO::' ,'Sys::';
};
if (!$@) {
  ok(my $sock = IO::Socket->new());
  ok(Sys::Hostname::hostname());
}

1;