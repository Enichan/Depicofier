using Antlr4.Runtime;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace P8LuaGrammar {
    public interface ILuaParser {
        ParserRuleContext Chunk();
    }
}
