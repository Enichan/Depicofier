using Antlr4.Runtime;
using P8LuaGrammar;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Depicofier {
    public static class Depicofy {
        private static string Clean(string source, Action<string> log, bool strictMode) {
            log("Strict mode: " + strictMode);
            log("Preprocessing if and print shorthand syntax...");
            var processed = Preprocessor.Process(source, strictMode);
            var pass1Cleaned = "";
            var pass2Cleaned = "";
            {
                log("Pass 1: Lexing and parsing source...");
                var input = new AntlrInputStream(processed);
                var lexer = strictMode ? (Lexer)new P8LuaLexer(input) : new CombinedLuaLexer(input);
                lexer.RemoveErrorListeners();

                var tokens = new CommonTokenStream(lexer);
                var parser = strictMode ? (ILuaParser)new P8LuaParser(tokens) : new CombinedLuaParser(tokens);
                parser.RemoveErrorListeners();

                log("Pass 1: Processing compound statements...");
                var context = parser.Chunk();
                var listener = new LuaListener(strictMode ? (ILuaListener)new ConcreteP8LuaListener() : (ILuaListener)new ConcreteCombinedLuaListener(), input, processed);
                pass1Cleaned = listener.ReplaceCompoundStatements(context);
            }

            {
                log("Pass 2: Lexing and parsing source...");
                var input = new AntlrInputStream(pass1Cleaned);
                var lexer = strictMode ? (Lexer)new P8LuaLexer(input) : new CombinedLuaLexer(input);
                lexer.RemoveErrorListeners();

                var tokens = new CommonTokenStream(lexer);
                var parser = strictMode ? (ILuaParser)new P8LuaParser(tokens) : new CombinedLuaParser(tokens);
                parser.RemoveErrorListeners();

                log("Processing remaining enhanced syntax...");
                var context = parser.Chunk();
                var listener = new LuaListener(strictMode ? (ILuaListener)new ConcreteP8LuaListener() : (ILuaListener)new ConcreteCombinedLuaListener(), input, pass1Cleaned);
                pass2Cleaned = listener.ReplaceRemaining(context);
            }

            log("Done");
            return pass2Cleaned;
        }

        public static string Clean(string source, bool strictMode) {
            return Clean(source, (s) => { }, strictMode);
        }

        public static void Clean(string source, string outFile, bool silent, bool strictMode) {
            Action<string> log = (s) => {
                if (!silent) {
                    Console.WriteLine(s);
                }
            };

            File.WriteAllText(outFile, Clean(source, log, strictMode));
            log("Saved source as '" + outFile + "'");
        }

        public static void CleanFile(string file, string outFile, bool silent, bool strictMode) {
            var source = File.ReadAllText(file);
            Clean(source, outFile, silent, strictMode);
        }
    }
}
