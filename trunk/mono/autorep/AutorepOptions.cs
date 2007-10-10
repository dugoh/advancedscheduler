// /home/dave/dev/ads_cs/AdvancedScheduler/autorep/autorep/AutorepOptions.cs created with MonoDevelop
// User: dave at 11:42 PM 10/7/2007
//
// To change standard headers go to Edit->Preferences->Coding->Standard Headers
//

using System;
using Mono.GetOptions;

namespace AdvancedScheduler
{
	public class AutorepOptions : Options
	{
		// Long option is the variable name ("--file"), short option is -f
	    //[Option ("Write report to FILE", 'f')]
	    //public string file;

	    // Long option is the variable name ("--quiet"), short option is -q
	    [Option ("Show Job Definition (JIL)", 'q')]
	    public bool ShowJobDef;

	    // Long option is as specified ("--use-int"), no short option
	    [Option ("Specify Job name", 'J')]
	    public string JobName;

		public AutorepOptions()
		{
			base.ParsingMode = OptionsParsingMode.Both;
			//base.VerboseParsingOfOptions = true;
		}
	}
}
