-- Copyright (c) 2026 Marc Espie <espie@openbsd.org>

-- Permission to use, copy, modify, and distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
--
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
-- WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
-- ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
-- WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
-- ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
-- OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

-- simple example to run display-video-tags on initial run
-- and on file load

function handle_tags(p)
    -- set up the command we want to run and capture stdout
    local result = mp.command_native({
        name = "subprocess",
        args = { "display-videos-tags", p },
        playback_only = false,  -- Prevents idle-state termination
        capture_stdout = true,
    })

    if result and result.status == 0 then
        mp.osd_message(result.stdout, 5)
    elseif result then
        mp.osd_message("Command failed: " .. (result.error or "unknown"), 5)
    else
        mp.osd_message("Command returned nil (likely killed during idle)", 5)
    end
end

-- make it so that the hook will run when file is loaded
function onFileLoaded()
    handle_tags(mp.get_property("path", "string"))
end

mp.register_event("file-loaded", onFileLoaded)

-- also link it to T in case we want to see the tags again
mp.add_key_binding("T", "show-videos-tags", handle_tags)
