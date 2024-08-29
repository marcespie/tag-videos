This is a small tagging interactive script designed for use with mpv

For instance add the following to input.conf:

t run "xterm" "-e" "tag-videos" "-c" "${working-directory}" "${path}"

It's more an example of what can be done with a few hundred lines of perl
and two powerful libraries (Term::ReadLine::Gnu and DBI)

Shameless pitch: this goes really well with one of my other projects
"random\_run" which among other things can take parameters from standard
input, one per line.
