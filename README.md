# Depicofier

Converts/translates PICO-8 style Lua syntax to standard clean Lua syntax. Download the [latest release](https://github.com/Enichan/Depicofier/releases) here.

This tool uses a [publicly available and well-tested Lua language grammar](https://github.com/antlr/grammars-v4/tree/master/lua) to parse PICO-8 source code, so that any enhanced or special syntax or shorthand will only be converted where it should be.

If you like this tool please consider kicking me a dollar [on Patreon](https://www.patreon.com/sharkhugseniko).

# Usage

```
Depicofier.exe [inFile] [outFile]
Or to output source to console:
Depicofier.exe [inFile] -print
Switches:
-strict   Print warnings for Lua syntax not found in Pico 8 such as binary
          operators, integer division, and bitwise shifts
```