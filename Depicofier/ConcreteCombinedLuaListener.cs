using Antlr4.Runtime;
using Antlr4.Runtime.Misc;
using P8LuaGrammar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Depicofier {
    public class ConcreteCombinedLuaListener : CombinedLuaListener, ILuaListener {
        public LuaListener Parent { get; set; }

        public override void EnterCompoundStatement([NotNull] CombinedLuaParser.CompoundStatementContext context) {
            Parent.EnterCompoundStatement(context);
        }

        public override void EnterOperatorComparison([NotNull] CombinedLuaParser.OperatorComparisonContext context) {
            Parent.EnterOperatorComparison(context);
        }

        public override void EnterNumber([NotNull] CombinedLuaParser.NumberContext context) {
            Parent.EnterNumber(context);
        }

        public override void EnterOperatorMulDivMod([NotNull] CombinedLuaParser.OperatorMulDivModContext context) {
            Parent.EnterOperatorMulDivMod(context);
        }
    }
}
