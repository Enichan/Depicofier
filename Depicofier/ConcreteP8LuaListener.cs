using Antlr4.Runtime.Misc;
using P8LuaGrammar;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Depicofier {
    public class ConcreteP8LuaListener : P8LuaListener, ILuaListener {
        public LuaListener Parent { get; set; }

        public override void EnterCompoundStatement([NotNull] P8LuaParser.CompoundStatementContext context) {
            Parent.EnterCompoundStatement(context);
        }

        public override void EnterOperatorComparison([NotNull] P8LuaParser.OperatorComparisonContext context) {
            Parent.EnterOperatorComparison(context);
        }

        public override void EnterNumber([NotNull] P8LuaParser.NumberContext context) {
            Parent.EnterNumber(context);
        }
    }
}
