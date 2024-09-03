This is a small tagging interactive script designed for use with mpv

For instance add the following to input.conf:

t run "xterm" "-e" "tag-videos" "-c" "${working-directory}" "${path}"

It's more an example of what can be done with a few hundred lines of perl
and two powerful libraries (Term::ReadLine::Gnu and DBI)

Shameless pitch: this goes really well with one of my other projects
"random\_run" which among other things can take parameters from standard
input, one per line.

It's also possible to create simple lua scripts
For instance, the following will run tag-videos on every new stream if it's not been tagged already, while showing existing tags.

    function on_file_change(name, value)
	if value ~= nil then
	    mp.commandv("run", "display-videos-tags", tostring(value))
	    mp.commandv("run", "xterm", "-geometry", "+0+0", "-e", "tag-videos", "-q", tostring(value))
	end
    end

    mp.observe_property("stream-open-filename", "string", on_file_change)

