package all;

use strict;
use warnings;

use IO::Dir;
use File::Spec;
use File::Find::Rule;

our $VERSION = '0.5';

sub import {
  my $class = shift;
  my $of    = shift;
  my $args  = [ @_ ];
  if ($of ne 'of') {
    unshift @$args, $of;
  }
  my $caller  = caller();
  foreach my $arg (@$args) {
    my $modules = find_modules( $arg );
    foreach my $module (@$modules) {
      my $package = $module->{ module };
      eval {
	require $module->{ path };
	$package->import;
      };
      if ($@) {
	warn( $@ );
      }
    }
  }
  1;
}

sub find_modules {
  my $root = shift;
  my $rootfile = module_to_file( $root );
  my $list = [];
  foreach my $dir (@INC) {
    my @files = File::Find::Rule->file()
                                ->name( '*.pm' )
			        ->in(
				     File::Spec->catfile(
							 $dir,
							 $rootfile
							)
				    );
    foreach my $file (@files) {
      my $file = File::Spec->abs2rel( $file, $dir );
      push @$list, {
		    path   => $file,
		    module => file_to_module( $file )
		   };
    }
  }
  return $list;
}

sub file_to_module {
  my $file = shift;
  $file    =~ s/\.pm$//;
  my @list = File::Spec->splitpath( $file );
  shift @list;
  join('::',  @list)
}

sub module_to_file {
  my $module = shift;
  File::Spec->catfile( split( /\::/, $module ) )
}

1;

__END__

=head1 NAME

all - pragma to load all packages under a namespace

=head1 SYNOPSIS

  # use everything in the IO:: namespace
  use all of => IO::;
  use all IO::;

  # use everything in the IO:: and Sys:: namespaces
  use all IO::, Sys::;
  use all of => IO::, Sys::;

=head1 DESCRIPTION

With the all pragma you can load multiple modules that share the same root
namespace.  This vastly reduces the amount of times you need to spend use'ing
modules.

=head1 BUGS / FEATURES

=over 4

=item

This will remove the ability to use exported / optionally exported functions.

=back

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright 2003 Fotango Ltd. All Rights Reserved.

This module is released under the same terms as Perl itself.

=cut
