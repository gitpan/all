#!/usr/bin/perl
use Module::Build;
my $build = new Module::Build(
			      module_name => 'all',
			      license => 'perl',
			      requires => {
					   'File::Spec' => 0.01
					  },
			     );
$build->create_build_script;
