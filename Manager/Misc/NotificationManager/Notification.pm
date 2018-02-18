package Manager::Misc::NotificationManager::Notification;

use Data::Dumper;
use String::ShellQuote;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Description Type Date Priority /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Description($args{Description});
  $self->Type($args{Type});
  $self->Date($args{Date} || $self->GetCurrentDate);
  $self->Priority($args{Priorty} || "default");
}

sub Execute {
  my ($self,%args) = @_;

}

sub GetCurrentDate {
  my ($self,%args) = @_;
  return time;
}

sub Announce {
  my ($self,%args) = @_;
  # play a notification sound, based on the type of notification
  system "play /home/andrewdo/.myconfig/.emacs.d/irc/erc/beep.wav";

  # display a temporary message, preferably using the nice notify GUI
  # thing, but this will work for now
  system "/var/lib/myfrdcsa/codebases/internal/manager/scripts/mynotify.py ".shell_quote($args{Title})." ".shell_quote($args{Contents});

  # FIXME
  system "echo \"(Parameter.set 'Duration_Stretch 0.5) ".
    "(SayText \\\"$args{Title} $args{Contents}\\\")\" | festival --pipe /etc/clear/fest.conf";
}

sub Clear {
  my ($self,%args) = @_;
  # remove the object, just skip for now
}

1;
