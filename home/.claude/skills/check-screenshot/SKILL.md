---
name: check-screenshot
description: Look at the screenshot(s) the user just took on this machine. Use whenever the user refers to a screenshot without giving a path — "see the screenshot", "check the latest sshot", "look at what I just captured", "see the last two screenshots", "as in the screenshot" — or invokes /check-screenshot.
---

# Check screenshot

The user takes screenshots with their own `sshot` script (Hyprland: Super+PrtSc for a region
copied to the clipboard, Super+Shift+PrtSc for a region opened in swappy). Both save to:

    ~/tmp/sshots/screenshot_YYYY-MM-DD_HH-MM-SS.png

The timestamp is local time, so the names sort chronologically: the newest file is the last one
by name.

## What to do

1. List the newest files. `ls` is aliased in the user's shell, so bypass the alias:

       command ls ~/tmp/sshots | tail -5

2. Pick what the user meant:
   - No qualifier, "latest", "last", "just took": the newest file.
   - "last two", "last 3", "these screenshots": that many, newest last.
   - A time or description ("the one from around 6:30", "the earlier one"): match on the
     timestamp in the name.
   - Arguments passed to the skill are the same kind of qualifier (a count, a time, or a hint
     about what to look for).
3. Open each chosen file with the Read tool, using its absolute path
   (`/home/samin/tmp/sshots/...`). Read several in one turn when more than one was asked for.
4. Carry on with whatever the user asked about the screenshot. Do not describe the image back
   to them unless that is the question; they know what they captured.

## Things to watch

- If the newest screenshot is more than a few minutes old, or its content plainly has nothing to
  do with the question, say which file you opened and when it was taken rather than guessing
  silently. The capture may have been cancelled (slurp exits on Escape and leaves no file or an
  empty one).
- A 0-byte file is a cancelled capture: skip it and take the one before.
- The screenshots are usually a cropped region, not the full screen, so coordinates in the image
  are not screen coordinates.
- If the directory is missing or empty, tell the user no screenshot was found there; do not go
  hunting through other directories.
