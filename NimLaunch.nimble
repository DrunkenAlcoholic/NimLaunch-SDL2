# Package

version       = "0.3.1"
author        = "DrunkenAlcoholic / Vyrnexis"
description   = "NimLaunch in SDL2 for native X11 and Wayland"
license       = "MIT"
srcDir        = "src"
bin           = @["nimlaunch"]


# Dependencies

requires "nim >= 2.0"
requires "sdl2"
requires "parsetoml"


# Build tasks

# Native Nim builds
task nimRelease, "Release build optimized for current CPU (fastest local binary)":
  mkDir("bin")
  exec "nim c -d:release -d:danger --opt:speed --passC:'-march=native -mtune=native -ffunction-sections -fdata-sections' --passL:'-Wl,--gc-sections -s' -o:./bin/nimlaunch src/nimlaunch.nim"

task nimReleasePortable, "Release build with generic x86_64 baseline (portable)":
  mkDir("bin")
  exec "nim c -d:release --opt:size --passC:'-march=x86-64 -mtune=generic -ffunction-sections -fdata-sections' --passL:'-Wl,--gc-sections -s' -o:./bin/nimlaunch src/nimlaunch.nim"

task nimDebug, "Debug build with native compiler":
  mkDir("bin")
  exec "nim c -d:debug --debuginfo --lineTrace:on --stackTrace:on --opt:none -o:./bin/nimlaunch src/nimlaunch.nim"

# Zig-based builds (portable)
task zigRelease, "Release build with Zig compiler optimized for current CPU":
  mkDir("bin")
  exec "nim c -d:release -d:danger --opt:speed --cc:clang --clang.exe='./zigcc' --clang.linkerexe='./zigcc' --passC:'-target x86_64-linux-gnu -mcpu=native -ffunction-sections -fdata-sections' --passL:'-target x86_64-linux-gnu -mcpu=native -Wl,--gc-sections -s' -o:./bin/nimlaunch ./src/nimlaunch.nim"

task zigReleasePortable, "Release build with Zig compiler (portable)":
  mkDir("bin")
  exec "nim c -d:release --opt:size --cc:clang --clang.exe='./zigcc' --clang.linkerexe='./zigcc' --passC:'-target x86_64-linux-gnu -mcpu=x86_64 -ffunction-sections -fdata-sections' --passL:'-target x86_64-linux-gnu -mcpu=x86_64 -Wl,--gc-sections -s' -o:./bin/nimlaunch ./src/nimlaunch.nim"

task zigDebug, "Debug build with Zig compiler":
  mkDir("bin")
  exec "nim c -d:debug --debuginfo --lineTrace:on --stackTrace:on --opt:none --cc:clang --clang.exe='./zigcc' --clang.linkerexe='./zigcc' -o:./bin/nimlaunch ./src/nimlaunch.nim"
