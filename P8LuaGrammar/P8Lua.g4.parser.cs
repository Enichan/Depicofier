using Antlr4.Runtime;

namespace P8LuaGrammar {
    partial class P8LuaParser : ILuaParser {
        public ParserRuleContext Chunk() {
            return chunk();
        }
    }
}
