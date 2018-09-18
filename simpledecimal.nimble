# Package

version       = "0.1.0"
author        = "Jedrzej Nowak"
description   = "A simple decimal library"
license       = "MIT"
skipFiles     = @["test.nim"]

# Dependencies

requires "nim >= 0.18"

task test, "run tests":
  --hints: off
  --linedir: on
  --stacktrace: on
  --linetrace: on
  --debuginfo
  --run
  setCommand "c", "simpledecimal"
