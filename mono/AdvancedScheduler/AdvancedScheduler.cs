// /home/dave/dev/ads_cs/AdvancedScheduler/AdvancedScheduler/MyClass.cs created with MonoDevelop
// User: dave at 12:19 AM 10/7/2007
//
// To change standard headers go to Edit->Preferences->Coding->Standard Headers
//
// project created on 10/7/2007 at 12:19 AM
using System;
using Npgsql;
using System.Data;
using System.Collections;
using System.IO;
using System.Text.RegularExpressions;

namespace AdvancedScheduler
{
	public class AdvancedScheduler
	{
		private NpgsqlConnection adsdb;
		
		private void Connect()
		{
			string connstr = "SERVER=localhost;Database=ads;User ID=ads;Password=ads";
			adsdb = new NpgsqlConnection(connstr);
			adsdb.Open();	
		}
		
		public AdvancedScheduler()
		{
			Connect();
		}
		
		public DataSet GetJobStatus(string pattern)
		{
			string sql = "Select name, last_start_time, last_end_time, status from Job where name like '" + pattern + "'";
			
			NpgsqlDataAdapter adapter = new NpgsqlDataAdapter(sql, adsdb);
			DataSet ds = new DataSet();
			adapter.Fill(ds, "Jobs");
			
			return ds;
			
		}
		
		public JobDefinition ParseJIL(TextReader instr)
		{
			
			JobDefinition jobdef = new JobDefinition();
			
			char[] delim = {':'};
			string [] keyval = new string[2];
			string jil;
			
			Regex rx = new Regex("[A-Za-z-_]+:.*"); // Looks like a JIL key/value pair
			
			while ( (jil = instr.ReadLine()) != null )
			{
				if (rx.IsMatch(jil))
				{
					keyval = jil.Split(delim, 2);
					jobdef.SetField(keyval[0], keyval[1]);
				}
				else
				{
					Console.Error.WriteLine("Warning: Malformed JIL encountered and ignored: {0}", jil);
				}
			}
			
			return jobdef;
		}
		
		public DataSet GetPendingJobs()
		{	
			string sql =  
			      "select * " 
			    + "from PendingJobs " 
			    + "where (Machine = 'titan' or Machine = 'all') "
			    + "and (assigned_agent is null "
			    + "     or assigned_agent != 'dummy') ";
						
			NpgsqlDataAdapter adapter = new NpgsqlDataAdapter(sql, adsdb);
			DataSet ds = new DataSet();
			adapter.Fill(ds, "PendingJobs");
			
			return ds;
		}
	}
}