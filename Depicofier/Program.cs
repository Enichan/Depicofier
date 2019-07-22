using Antlr4.Runtime;
using Antlr4.Runtime.Tree;
using P8LuaGrammar;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Depicofier {
    class Program {
        static void Main() {
            var args = CommandLineArguments.Parse();
            var print = false;
            var strict = false;

            for (int i = args.Count - 1; i >= 0; i--) {
                var arg = args[i].ToLowerInvariant();
                if (arg == "-print") {
                    print = true;
                    args.RemoveAt(i);
                }
                if (arg == "-strict") {
                    strict = true;
                    args.RemoveAt(i);
                }
            }

            if (args.Count < (print ? 1 : 2)) {
                Console.WriteLine("Usage:");
                Console.WriteLine("Depicofier.exe [inFile] [outFile]");
                Console.WriteLine("Or to output source to console:");
                Console.WriteLine("Depicofier.exe [inFile] -print");
                Console.WriteLine("Switches:");
                Console.WriteLine("-strict   Print warnings for Lua syntax not found in Pico 8 such as binary");
                Console.WriteLine("          operators, integer division, and bitwise shifts");
                return;
            }

            var sourceFile = args[0];
            var outFile = print ? null : args[1];

            if (!File.Exists(sourceFile)) {
                Console.WriteLine("File '" + sourceFile + "' not found");
                Environment.Exit(2);
            }

            if (print) {
                Console.WriteLine(Depicofy.Clean(File.ReadAllText(sourceFile), strict));
            }
            else {
                Depicofy.CleanFile(sourceFile, outFile, false, strict);
            }
        }
    }
}
