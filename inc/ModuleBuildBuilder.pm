package ModuleBuildBuilder;

use strict;
use Module::Build;
use vars qw(@ISA);
@ISA = qw(Module::Build);

sub ACTION_distdir {
  my $self = shift;
  $self->SUPER::ACTION_distdir(@_);
  
  my $base = $INC{'Module/Build/Base.pm'};
  open my($fh), $base or die "Couldn't read $base: $!";
  my %subs = map {$_,1} map +(/^\s*sub (\w+)/)[0], <$fh>;

  my @need_doc = sort grep !$subs{$_}, $self->valid_properties;
  $self->run_perl_script(File::Spec->catfile($self->dist_dir, qw(lib Module Build.pm)),
			 ['-pi',
			  '-e',
			  qq[s{<autogenerated_accessors>}{ join "\\n\\n", map "=item \$_()", qw(@need_doc) }e] ],
			 [],
			);
}