package all;

use 5.006;
use strict;
use warnings;

use File::Spec ();
use File::Find ();

our $VERSION = '0.5001';

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
  my $module = shift;
  my $moduledir = module_to_file( $module );
  my $list = [];

  foreach my $incdir (@INC) {
    next if ref $incdir;

    my $dir = File::Spec->catfile($incdir, $moduledir);
    next unless -d $dir;

    my @files = ();
    File::Find::find({
        wanted => sub {
            return unless $File::Find::name =~ /\.pm$/;
            push @files, $File::Find::name;
        },
        no_chdir => 1,
    }, $dir);

    foreach my $absfile (@files) {
      my $relfile = File::Spec->abs2rel( $absfile, $incdir );
      push @$list, {
		    path   => $relfile,
		    module => file_to_module( $relfile )
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
  use all of => 'IO::';
  use all 'IO::';

  # use everything in the IO:: and Sys:: namespaces
  use all 'IO::', 'Sys::';
  use all of => 'IO::', 'Sys::';

=head1 DESCRIPTION

With the all pragma you can load multiple modules that share the same root
namespace.  This vastly reduces the amount of times you need to spend use'ing
modules.

=head1 BUGS / FEATURES

=over 4

=item *

This will remove the ability to use exported / optionally exported functions.

=back

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 COPYRIGHT

Copyright 2003 Fotango Ltd. All Rights Reserved.

Copyright 2008 Piotr Roszatycki <dexter@cpan.org>.

This module is released under the same terms as Perl itself.

=cut
