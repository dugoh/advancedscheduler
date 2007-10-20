// /home/dave/dev/ads_cs/AdvancedScheduler/agent/agent/Main.cs created with MonoDevelop
// User: dave at 7:25 AM 10/9/2007
//
// To change standard headers go to Edit->Preferences->Coding->Standard Headers
//
// project created on 10/9/2007 at 7:25 AM
using System;
using System.Data;
using AdvancedScheduler;
using System.Threading;

namespace AdvancedScheduler
{
	class MainClass
	{
		private static int EXIT_FLAG; // visible to all threads, only changed in one place
		
		public static int Main(string[] args)
		{
			EXIT_FLAG = 0;
			
			Thread WorkMgrThr = new Thread(new ThreadStart(WorkManager));
			WorkMgrThr.Start();
			
			Thread SetStatusThr = new Thread( new ThreadStart(SetStatus) );
			SetStatusThr.Start();
			
			// Figure out how to manage multiple threads
			Thread ExecWrkThr = new Thread(new ThreadStart(ExecWork));
			ExecWrkThr.Start();
			
			WorkMgrThr.Join();
			ExecWrkThr.Join();
			
			return 0;
			
		}
		
		private static void WorkManager ()
		{
			Console.WriteLine("WorkManager thread Started");
			
			AdvancedScheduler ads = new AdvancedScheduler();
			
			DataSet pending = ads.GetPendingJobs();
			
			foreach ( DataRow job in pending.Tables[0].Rows )
			{
				Console.WriteLine("{0}", job.ToString());
			}
			
			Console.WriteLine("WorkManager thread Exiting");
		}
		
		private static void ExecWork()
		{
			Console.WriteLine("ExecWork thread Started");
			
			
			
			Console.WriteLine("ExecWork thread Exiting");
		}
		
		private static void SetStatus()
		{
			Console.WriteLine("SetStatus thread Started");
			
						
			Console.WriteLine("SetStatus thread Exiting");
			
		}
	}
}