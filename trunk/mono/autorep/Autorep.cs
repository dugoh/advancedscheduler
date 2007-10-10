// /home/dave/dev/ads_cs/AdvancedScheduler/AdvancedScheduler/Autorep.cs created with MonoDevelop
// User: dave at 1:24 AM 10/7/2007
//
// To change standard headers go to Edit->Preferences->Coding->Standard Headers
//

using System;
using System.Data;
using AdvancedScheduler;

namespace AdvancedScheduler
{
	public class Autorep
	{
		public static int Main(string[] args)
		{

			AutorepOptions opts = new AutorepOptions();
			opts.ProcessArgs(args);
			
			if ( opts.JobName == null)
			{
				Console.WriteLine("No job specified! Use -J jobname.");
				return 1;
			}
			
			string reqjob = opts.JobName.Length > 0 ? opts.JobName : "";

			if ( opts.ShowJobDef )
			{
				Console.WriteLine("Showing JIL...");
			}
			else
			{
				ShowRunRecord(reqjob);
			}

			return 0;
		}
		
		private static void ShowRunRecord(string reqjob)
		{
			AdvancedScheduler ads = new AdvancedScheduler();
			DataSet jobs = ads.GetJobStatus(reqjob);
			
			string format    = "{0,-35}  {1,-25}  {2,-25}  {3,-6}";
			string hdrformat = format;
			
			Console.WriteLine(hdrformat, "Job Name", "Last Start", "Last End", "Status");
			Console.WriteLine(format, "".PadRight(35,'-'), "".PadRight(25,'-'), "".PadRight(25,'-'), "".PadRight(6,'-'));
			
			foreach (DataRow JobRecord in jobs.Tables[0].Rows)
			{
				Console.WriteLine(format, JobRecord[0], JobRecord[1], JobRecord[2], JobRecord[3] );
			}
		}
		
	}
}
