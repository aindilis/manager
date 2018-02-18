isRunningP(ShellCommand,Result) :-
	atomic_list_concat(['ps auxwww | grep -iE ',ShellCommand,' | grep -v grep | wc -l'],'',Command),
	view([command,Command]),
	shell_command(Command,Result).

startRecordingAudio(Room) :-
	atomic_list_concat(['/var/lib/myfrdcsa/codebases/internal/manager/scripts/control-audio.pl -a start-recording -r ',Room],'',Command),
	shell_command_async(Command).

stopRecordingAudio(Room) :-
	atomic_list_concat(['/var/lib/myfrdcsa/codebases/internal/manager/scripts/control-audio.pl -a stop-recording -r ',Room],'',Command),
	shell_command_async(Command).
