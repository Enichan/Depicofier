using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Depicofier {
    public static class CommandLineArguments {
        /// <summary>
        /// Parses command line arguments.
        /// </summary>
        /// <param name="arguments">String containing the arguments. Uses Environment.CommandLine if null. Does not allow escaped double quotes.</param>
        /// <returns>List of arguments.</returns>
        public static List<string> Parse(string arguments = null) {
            return Parse(false, arguments);
        }

        /// <summary>
        /// Parses command line arguments.
        /// </summary>
        /// <param name="allowEscapedDoubleQuotes">If true a sequence of \" between double quotes will be a single quote.</param>
        /// <param name="arguments">String containing the arguments. Uses Environment.CommandLine if null.</param>
        /// <returns>List of arguments.</returns>
        public static List<string> Parse(bool allowEscapedDoubleQuotes, string arguments = null) {
            Regex regex;
            bool removeFirst = false;

            if (arguments == null) {
                arguments = Environment.CommandLine;
                removeFirst = true;
            }
            List<string> args = new List<string>();

            regex = new Regex(
                allowEscapedDoubleQuotes ? "\"((\\\\\"|[^\"])*)\"+|[^\\s]+" : "\"([^\"]*)\"+|[^\\s]+",
                RegexOptions.None
            );

            foreach (Match match in regex.Matches(arguments)) {
                if (match.Success) {
                    string s = match.Value.Trim();
                    if (match.Groups[1].Success) {
                        if (allowEscapedDoubleQuotes) {
                            s = match.Groups[1].Value.Replace("\\\"", "\"");
                        }
                        else {
                            s = match.Groups[1].Value;
                        }
                    }
                    else {
                        s = match.Groups[0].Value.Trim();
                    }
                    args.Add(s);
                }
            }

            if (removeFirst) {
                args.RemoveAt(0);
            }
            return args;
        }
    }
}
