using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Depicofier {
    public struct Replacement {
        public readonly int Start;
        public readonly int Length;
        public readonly string Text;

        public Replacement(int start, int end, string text) {
            Start = start;
            Length = end - start + 1;
            Text = text;
        }

        public string Replace(string source) {
            var str = new StringBuilder();
            if (Start > 0) {
                str.Append(source.Substring(0, Start));
            }
            string endStr = null;
            var end = Start + Length;
            if (end < source.Length) {
                endStr = source.Substring(end, source.Length - end);
            }
            if (Length > 0) {
                //Console.WriteLine("appending \'" + Text + "\'");
                str.Append(Text);
            }
            if (endStr != null) {
                str.Append(endStr);
            }
            return str.ToString();
        }
    }
}
