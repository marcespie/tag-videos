This is a small tagging interactive script designed for use with mpv

For instance add the following to input.conf:

    t run "xterm" "-e" "tag-videos" "-sc" "${working-directory}" "${path}"

It's more an example of what can be done with a few hundred lines of perl
and two powerful libraries (Term::ReadLine::Gnu and DBI)

One highly specific feature of this code is facilities to help you manage
duplicate tags and other stuff.

The new version introduces the use of Levenshtein distance to facilitate
removing extra mispellt tags and things like that.

Shameless pitch: this goes really well with one of my other projects
"random\_run" which among other things can take parameters from standard
input, one per line.

It's also possible to create simple lua scripts.

See the example in the lua-scripts/ directory that shows how
to have automatic OSD for existing tags.

As for the base interactive interface, it uses a lot of algorithmic tricks to make sure you don't create crazy similar tags which is often a problem
with these programs.
