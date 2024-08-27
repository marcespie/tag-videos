This is a small tagging interactive script designed for use with mpv

For instance add the following to input.conf:

t run "xterm" "-e" "tag-videos" "${working-directory}" "${path}"

It's more an example of what can be done with a few hundred lines of perl
and two powerful libraries (Term::ReadLine::Gnu and DBI)
