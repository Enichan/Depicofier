using Antlr4.Runtime.Tree;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Depicofier {
    public interface ILuaListener : IParseTreeListener {
        LuaListener Parent { get; set; }
    }
}
