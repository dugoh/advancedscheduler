create or replace view CurrentStatus
as 
	select job.JobID, Box_Name, Name, Status, StartTime, EndTime
	from Job 
		left join RunRecord rec
			on rec.JobID = job.JobID
	where (rec.JobID is null or Current = true);