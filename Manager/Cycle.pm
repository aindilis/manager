package Manager::Cycle;

# system responsible for maintaining planning cycle, i.e. with Verber,
# etc.

$VERSION = '1.00';
#use strict;
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / / ];

sub init {
  my ($self, %args) = (shift,@_);
}

sub Execute {
  my ($self, %args) = (shift,@_);
}

1;
