using Antlr4.Runtime;

namespace P8LuaGrammar {
    partial class CombinedLuaParser : ILuaParser {
        public ParserRuleContext Chunk() {
            return chunk();
        }
    }
}
