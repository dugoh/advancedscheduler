// /home/dave/dev/ads_cs/AdvancedScheduler/jil/jil/Main.cs created with MonoDevelop
// User: dave at 1:46 PM 10/7/2007
//
// To change standard headers go to Edit->Preferences->Coding->Standard Headers
//
// project created on 10/7/2007 at 1:46 PM
using System;
using System.IO;
using AdvancedScheduler;

namespace AdvancedScheduler
{
	class JIL
	{
		public static void Main(string[] args)
		{
			
			AdvancedScheduler ads = new AdvancedScheduler();				
			JobDefinition jd = ads.ParseJIL(Console.In);
			
			Console.WriteLine(jd.JIL);
		}
	}
}