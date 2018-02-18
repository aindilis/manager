package Manager::AgentLib;

# developmental agent helper library for eventual UniLang::Agent::Agent integration

# sub Agent::Ask {
#   my ($self,%args) = (shift,@_);
#   my $res = $self->SendMessage
#     (Recipient => $args{Recipient},
#      Contents => $args{Contents})
#       unless $args{Recipient} and $args{Contents};
#   if ($res eq "agent not connected") {
#     # perhaps ask to spawn agent, maybe unilang does this automatically
#   }
# }

1;
