package Manager::Records::Context::TaskManager;

use Manager::Dialog qw (ApproveCommands Message QueryUser SubsetSelect);
use PerlLib::MySQL;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Related Tasks TaskDB TaskDBFile Files ManualRelated /

  ];

sub init {
  my ($self, %args) = @_;
  $self->TaskDBFile("/var/lib/myfrdcsa/codebases/internal/manager/scripts/tasks.pl");
  $self->ManualRelated
    (
     {
      rwhoisd => "rwhois",
      gnutran => "all",
      dbmail => "audience",
      celt => "setanta",
      Catalyst => "diamond",
     }
    );
  $self->LoadTaskDB;
  $self->GenerateRelatedTerms;
  $self->GenerateTasks;
}

sub LoadFiles {
  my ($self, %args) = @_;
  my $contentfile = "tasksforfile.pl";
  if (! -e $contentfile) {
    my $mysql = PerlLib::MySQL->new
      (DBName => "elog");

    my $r = $mysql->Do(Statement => "select * from events where Sender='Emacs-Client' and Date > '2006-05-05'");
    print Dumper($r);
    foreach my $e (values %$r) {
      print $e->{Contents}."\n";
      $self->Files->{$l[1]}++;
    }

    my $OUT;
    open(OUT, ">$contentfile");
    print OUT Dumper($self->Files);
    close(OUT);
  }

  if (! keys %{$self->Files}) {
    my $c = `cat "$contentfile"`;
    $self->Files(eval $c);
  }
}

sub LoadTaskDB {
  my ($self,%args) = @_;
  if (-f $self->TaskDBFile) {
    my $tdbfile = $self->TaskDBFile;
    $self->TaskDB(eval `cat $tdbfile`);
  } else {
    $self->TaskDB({});
  }
}

sub GenerateTasks {
  my ($self,%args) = @_;
  my @list;
  my $p = {};
  my @dirs = qw(/var/lib/myfrdcsa/codebases/internal
		/var/lib/myfrdcsa/projects
		/var/lib/myfrdcsa/codebases/data
		/var/lib/myfrdcsa/projects/work/assignments);
  foreach my $dir (@dirs) {
    foreach my $sys (split /\n/, `ls "$dir"`) {
      $p->{$sys} = 1;
    }
  }
  $self->Tasks($p);
}

sub GenerateRelatedTerms {
  my ($self,%args) = @_;
  # lookup tokens to see if they are at all related
  # related mappings
  # extract mappings
  my $related = {};
  foreach my $line (split /\n/,`ls -alrt /usr/local/share/perl/5.8.8/`) {
    # lrwxrwxrwx   1 root     staff          48 Jun  8 13:29 KBS -> /var/lib/myfrdcsa/codebases/internal/freekbs/KBS
    if ($line =~ /^.*\s(.*?) -> (.*)$/) {
      my $token = $1;
      my $system = $2;
      if ($token !~ /\.pm$/) {
	# /var/lib/myfrdcsa/codebases/internal/sorcerer/Sorcerer.pm
	$system =~ q|^.*/([^/]+)/[^/]+|;
	my $sys = $1;
	$sys =~ s/-[\d\.]+$//;
	$related->{$token}->{$sys}++;
      }
    }
  }
  $self->Related($related);
}

sub GetTasksForFile {
  my ($self,%args) = @_;
  my $file = $args{File};

  # if it is already in there, just return that
  if (exists $self->TaskDB->{$file}) {
    return $self->TaskDB->{$file};
  }

  # lookup if there is a direct relation
  my $t1 = $self->LookupTasksForFile(File => $file);
  if (scalar keys %$t1) {
    return $t1;
  }

  # otherwise lookup relations
  my $t2 = $self->EstimateRelated(File => $file);
  if (scalar keys %$t2) {
    return $t2;
  }

  # as a last resort, look at the file contents
  return {};
}

sub EstimateRelated {
  my ($self,%args) = @_;
  foreach my $w (split /\//,$args{File}) {
    if ($w =~ /^(.*)\.pm$/i) {
      return $self->EstimateRelated(File => $1);
    }
    if (exists $self->ManualRelated->{$w}) {
      return {
	      $w => 1,
	     };
    } elsif (exists $self->ManualRelated->{lc($w)}) {
      return {
	      lc($w) => 1,
	     };
    } elsif (exists $self->Tasks->{$w}) {
      return {
	      $w => 1,
	     };
    } elsif (exists $self->Tasks->{lc($w)}) {
      return {
	      lc($w) => 1,
	     };
    } elsif (exists $self->Related->{$w} or
	exists $self->Related->{lc($w)}) {
      return $self->Related->{$w};
    }
  }
}

sub LookupTasksForFile {
  my ($self,%args) = @_;
  # very stupid, simple system for now
  my $file = $args{File};
  if ($file =~ q|^/var/lib/myfrdcsa/codebases/internal/([^/]+)/|) {
    return {
	    $1 => 1,
	   };
  } elsif ($file =~ q|^/var/lib/myfrdcsa/codebases/releases/([^/]+)/|) {
    my $sys = $1;
    $sys =~ s/-.*//;
    return {
	    $sys => 1,
	   };
  } elsif ($file =~ q|^/var/lib/myfrdcsa/projects/([^/]+)/|) {
    return {
	    $1 => 1,
	   };
  } elsif ($file =~ q|^/var/lib/myfrdcsa/codebases/data/([^/]+)/|) {
    return {
	    $1 => 1,
	   };
  } elsif ($file =~ q|^/var/lib/myfrdcsa/projects/work/assignments/[^/]+/([^/]+)|) {
    return {
	    $1 => 1,
	   };
  }
  return {};
}

sub QueryUserAboutMappings {
  my ($self,%args) = @_;
  $self->Files({});
  $self->LoadFiles;
  my @tasklist = sort keys %{$self->Tasks};
  foreach my $file (sort {$self->Files->{$b} <=> $self->Files->{$a}} keys %{$self->Files}) {
    # print "$file\t".$self->Files->{$file}."\n";
    my $tasks = $self->GetTasksForFile(File => $file);
    if (! keys %$tasks) {
      Message(Message => "What is the task for this file (".$self->Files->{$file}.") : $file");
      my @tasks = SubsetSelect(Set => \@tasklist);
      if (! (scalar @tasks) and ! (scalar keys %{$self->TaskDB->{$file}})) {
	$self->TaskDB->{$file}->{""} = 1;
      } else {
	foreach my $task (@tasks) {
	  $self->TaskDB->{$file}->{$task}++;
	}
      }
      $self->SaveMappings;
    }
  }
}

sub SaveMappings {
  my ($self,%args) = @_;
  print "Saved\n";
  my $OUT;
  open(OUT, ">".$self->TaskDBFile);
  print OUT Dumper($self->TaskDB);
  close(OUT);
}

1;
