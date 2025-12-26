This is a small tagging interactive script designed for use with mpv

For instance add the following to input.conf:

    t run "xterm" "-e" "tag-videos" "-c" "${working-directory}" "${path}"

It's more an example of what can be done with a few hundred lines of perl
and two powerful libraries (Term::ReadLine::Gnu and DBI)

One highly specific feature of this code is facilities to help you manage
duplicate tags and other stuff.

The new version introduces the use of Levenshtein distance to facilitate
removing extra mispellt tags and things like that.

Shameless pitch: this goes really well with one of my other projects
"random\_run" which among other things can take parameters from standard
input, one per line.

It's also possible to create simple lua scripts
For instance, the following will run tag-videos on every stream change if it's not been tagged already, while showing existing tags:

    function display_tags()
	p = mp.get_property("path", "string")
	mp.commandv("run", "tag-videos", "-q", "-X", "xterm,-geometry,+0+0,-e", p)
    end
    mp.register_event("file_loaded", display_tags)

It's probably possible to write a proper luadbi interface to the database, so that the tags could be added as properties on load and shown within mpv's interface.

As for the base interactive interface, it uses a lot of algorithmic tricks to make sure you don't create crazy similar tags which is often a problem
with these programs.
