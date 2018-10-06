# Test volume

Drive 0 will auto-boot, loading `R.CH200P` from drive 1 (where the
build process puts it) into sideways RAM bank 13 (adjust for your Beeb
if necessary).

Also, test programs:

* `$.CHEXP` - Challenger RAM "explorer" - shows each page in turn.
  Press SPACE to get to the next one
  
* `$.CHTEST` - Challenger RAM test - determines size of RAM, then
  fills pages with a few different values and checks each time that
  the values were retained afterwards. **This will erase the RAM
  disc** - also, you might need to do a power cycle after running it,
  as the Challenger ROM doesn't seem to always reset things properly
  afterwards

Drive 1 is where the patched ROM goes.
