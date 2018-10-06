# Test volume

Drive 0 will auto-boot, loading `R.CH200P` from drive 1 (where the
build process puts it) into sideways RAM bank 13 (adjust for your Beeb
if necessary).

Also, test programs:

* `$.CHEXP` - Challenger RAM "explorer" - shows each page in turn.
  Press SPACE to get to the next one

Drive 1 is where the patched ROM goes.
