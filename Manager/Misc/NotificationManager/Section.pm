package Manager::Misc::NotificationManager::Section;

use PerlLib::Collection;
use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Type Color SectionColor Description MyEntries /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Type($args{Type} || "One Time");
  $self->Color($args{Color} || "");
  $self->SectionColor($args{SectionColor} || "");
  $self->Description($args{Description});
  $self->MyEntries
    (PerlLib::Collection->new
     (
      Type => "Manager::Misc::NotificationManager::Notification",
     ));
  $self->MyEntries->Contents({});
}

sub Execute {
  my ($self,%args) = @_;

}

1;
