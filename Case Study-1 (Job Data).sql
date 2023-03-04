create database jobdata;
use jobdata;
/* Calculate the number of jobs reviewed per hour per day for November 2020 */
SELECT ds, ROUND(1.0*COUNT(job_id)*3600/sum(time_spent),2) as Jobs_reviewed_Per_Hour
from job_data
where event IN('Transfer', 'Decision') AND ds BETWEEN '2020-11-01' AND '2020-11-30' GROUP BY ds ;

/* Calculate 7 day rolling average of throughput */
WITH x AS
(SELECT ds, COUNT(job_id) AS num_jobs, sum(time_spent) as total_time from job_data
where event IN('Transfer', 'Decision') AND ds BETWEEN '2020-11-01' AND '2020-11-30'
GROUP BY ds)
SELECT ds, ROUND(1.0*sum(num_jobs) OVER (ORDER BY ds rows between 6 preceding AND
current row)/sum(total_time) over (order by ds rows between 6 preceding AND current
row),2) as throughput_7d from x;

/* Calculate the percentage share of each language in the last 30 days */
select language, count(*)*12.5 as Percentage_Share from job_data where ds between '2020-11-01' and '2020-11-30' group by language;

/* How will you display duplicates from the table */
select * from
(select *,row_number()over(partition by job_id) as rownum
from job_data)a where rownum>1;