using Antlr4.Runtime;
using P8LuaGrammar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Depicofier {
    public static class Preprocessor {
        public static string Process(string source, bool strictMode) {
            var input = new AntlrInputStream(source);
            var lexer = strictMode ? (Lexer)new P8LuaLexer(input) : new CombinedLuaLexer(input);
            lexer.RemoveErrorListeners();

            var tokenStream = new CommonTokenStream(lexer);
            tokenStream.Fill();
            var tokens = tokenStream.GetTokens().ToList();

            var skipRanges = new List<Tuple<int, int>>();

            // skip comments and strings
            for (int i = 0; i < tokens.Count; i++) {
                var token = tokens[i];
                var typeName = lexer.Vocabulary.GetSymbolicName(token.Type);

                if (typeName == "NORMALSTRING" || typeName == "CHARSTRING" || typeName == "LONGSTRING" || typeName == "COMMENT" || typeName == "LINE_COMMENT" || typeName == "ALT_COMMENT") {
                    var text = token.Text;
                    var stopIndex = token.StopIndex;
                    var index = stopIndex - token.StartIndex;

                    while (index > 0 && text[index] == '\r' || text[index] == '\n') {
                        index--;
                        stopIndex--;
                    }

                    skipRanges.Add(new Tuple<int, int>(token.StartIndex, stopIndex));
                }
            }

            var lines = new List<string>();
            var startIndex = 0;

            for (int i = 0; i < source.Length; i++) {
                if (skipRanges.Count > 0 && i >= skipRanges[0].Item1 && i <= skipRanges[0].Item2) {
                    i = skipRanges[0].Item2;
                    skipRanges.RemoveAt(0);
                    continue;
                }

                var c = source[i];
                if (c == '\r' || c == '\n') {
                    lines.Add(source.Substring(startIndex, i - startIndex));

                    if (c == '\r' && i + 1 < source.Length && source[i + 1] == '\n') {
                        i++;
                    }

                    startIndex = i + 1;
                }
            }

            if (source.Length - startIndex > 0) {
                lines.Add(source.Substring(startIndex));
            }

            return Process(lines, strictMode);
        }

        public static string Process(string[] lines, bool strictMode) {
            return Process(lines.ToList(), strictMode);
        }

        public static string Process(List<string> lines, bool strictMode) { 
            for (int i = 0; i < lines.Count; i++) {
                var line = lines[i];
                var processed = ProcessLine(line, strictMode);
                lines[i] = processed;
            }
            return String.Join(Environment.NewLine, lines);
        }

        private static string ProcessLine(string line, bool strictMode) {
            var input = new AntlrInputStream(line);
            var lexer = strictMode ? (Lexer)new P8LuaLexer(input) : new CombinedLuaLexer(input);
            lexer.RemoveErrorListeners();

            var tokenStream = new CommonTokenStream(lexer);
            tokenStream.Fill();
            var tokens = tokenStream.GetTokens().ToList();

            if (tokens.Count == 0) {
                return line;
            }

            // switch alt comment style to normal
            for (int i = tokens.Count - 1; i >= 0; i--) {
                if (tokens[i].Channel == TokenConstants.HiddenChannel && tokens[i].Text.StartsWith("//")) {
                    var str = new StringBuilder(line);
                    str.Replace("//", "--", tokens[i].StartIndex, 2);
                    line = str.ToString();
                }
            }

            Func<IToken, string> tokenType = (t) => {
                return lexer.Vocabulary.GetSymbolicName(t.Type);
            };

            // remove EOF token
            if (tokens.Count > 0 && tokens[tokens.Count - 1].Type == -1) {
                tokens.RemoveAt(tokens.Count - 1);
            }

            // remove trailing comments
            for (int i = 0; i < tokens.Count; i++) {
                if (tokens[i].Channel > 0) {
                    tokens.RemoveRange(i, tokens.Count - i);
                    break;
                }
            }

            var trimmed = line.Trim();
            if (trimmed.StartsWith("?")) {
                // print shorthand
                var str = new StringBuilder();
                var endIndex = tokens[tokens.Count - 1].StopIndex;
                str.Append(string.Format("print({0})", line.Substring(tokens[0].StartIndex + 1, endIndex)));
                if (endIndex < line.Length) {
                    str.Append(line.Substring(endIndex + 1));
                }
                return str.ToString();
            }

            // if shorthand needs at minimum 5 tokens: 'if' '(' expr ')' statement
            if (tokens.Count >= 5 && tokens[0].Text == "if" && tokens[1].Text == "(") {
                // if shorthand has no elseif or end
                var then = tokens.FirstOrDefault(t => t.Text == "then");
                var elseif = tokens.FirstOrDefault(t => t.Text == "elseif");
                var end = tokens.FirstOrDefault(t => t.Text == "end");
                var hasBadKeywords = false;

                if (elseif != null && elseif.Text == "elseif") {
                    hasBadKeywords = true;
                }
                if (end != null && end.Text == "end") {
                    hasBadKeywords = true;
                }
                if (then != null && then.Text == "then") {
                    hasBadKeywords = true;
                }

                if (!hasBadKeywords) {
                    // potential if shorthand
                    var parenCount = 1;
                    var index = 2;

                    var exprEnd = -1;
                    var blockStart = -1;

                    while (index < tokens.Count) {
                        var token = tokens[index];
                        if (token.Text == "(") {
                            parenCount++;
                        }
                        else if (token.Text == ")") {
                            parenCount--;
                        }

                        if (parenCount == 0) {
                            // it can only be a shorthand if there's at least one token after the closing parenthesis
                            if (index + 1 < tokens.Count) {
                                exprEnd = index - 1;
                                blockStart = index + 1;
                            }
                            break;
                        }

                        index++;
                    }

                    if (exprEnd > -1 && blockStart > -1) {
                        // it's an if shorthand
                        var expr = GetString(line, tokens[2].StartIndex, tokens[exprEnd].StopIndex);

                        var blockEndIndex = tokens[tokens.Count - 1].StopIndex;
                        var block = GetString(line, tokens[blockStart].StartIndex, blockEndIndex);

                        var str = new StringBuilder();
                        if (tokens[0].StartIndex > 0) {
                            str.Append(line.Substring(0, tokens[0].StartIndex));
                        }
                        str.Append("if ");
                        str.Append(expr);
                        str.Append(" then ");
                        str.Append(block);
                        str.Append(" end");

                        // comments
                        if (line.Length > blockEndIndex) {
                            var comment = line.Substring(blockEndIndex + 1).Trim();
                            str.Append(" " + comment);
                        }

                        return str.ToString();
                    }
                }
            }

            return line;
        }

        private static string GetString(string line, int start, int end = -1) {
            if (end < 0) {
                return line.Substring(start);
            }
            return line.Substring(start, end - start + 1);
        }
    }
}
