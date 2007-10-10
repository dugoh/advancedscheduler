// /home/dave/dev/ads_cs/AdvancedScheduler/AdvancedScheduler/JobDefinition.cs created with MonoDevelop
// User: dave at 9:38 PM 10/7/2007
//
// To change standard headers go to Edit->Preferences->Coding->Standard Headers
//

using System;
using System.Collections;
using System.Text.RegularExpressions;

namespace AdvancedScheduler
{
	public class JobDefinition : Hashtable
	{
		private Hashtable Fields;
		
		private string Command;
		private string JobName;
		
		public JobDefinition()
		{
			Fields = new Hashtable();
			Fields.Add("insert_job", "cmd");
			Fields.Add("update_job", "cmd");
			Fields.Add("delete_job", "cmd");
			
			Fields.Add("start_mins", null);
			Fields.Add("start_times", null);
			Fields.Add("start_days", null);
			Fields.Add("command", null);
			Fields.Add("conditions", null);
			Fields.Add("date_conditions", null);
			Fields.Add("std_in_file", null);
			Fields.Add("std_out_file", null);
			Fields.Add("std_err_file", null);
			Fields.Add("machine", null);
			Fields.Add("box_name", null);
			Fields.Add("permission", null);
			Fields.Add("alarm_if_fail", null);
			Fields.Add("profile", null);

		}
		
		public void SetField(string field, string val)
		{
			if ( Fields.ContainsKey(field) )
			{
				if ( (string)Fields[field] == "cmd")
				{ // handle command
					this.Command = field;
					this.JobName = val;
				}
				else
				{ // set field value
					this[field] = val;
				}
			}
			else
			{
				Console.Error.WriteLine("Encountered invalid field \"{0}\".", field);
			}
		}
		
		public string JIL
		{
			get {
				string jil = ""; 
				
				jil = "/* ---------- " + JobName + " ---------- */\n\n";
				jil += Command + ": " + JobName + "\n";
				
				foreach ( string field in this.Keys)
				{
					jil = jil + field + ": " + this[field] + "\n";
				}
				
				return jil;
			}
		}
	}
}
