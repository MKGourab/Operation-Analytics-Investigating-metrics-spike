create database cs2;
use cs2;

/* Calculate the weekly user engagement */
SELECT EXTRACT(WEEK FROM a.occurred_at) AS week_num,
COUNT(DISTINCT a.user_id) AS users_engaged
FROM events a
GROUP BY week_num;

/* Calculate the user growth for product */
SELECT year,week_num,active_users,
SUM(active_users) OVER (ORDER BY year,week_num ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS total_active_users 
FROM(SELECT EXTRACT(YEAR FROM u.activated_at) AS year, 
EXTRACT(WEEK FROM u.activated_at) AS week_num,  
COUNT(DISTINCT u.user_id) AS active_users FROM users u  
WHERE state='active' GROUP BY year,week_num ORDER BY year,week_num )a;

/* Calculate the weekly retention of users-sign up cohort */
SELECT a.user_id, a.signup_week, b.engagement_week, b.engagement_week-a.signup_week as retention_week 
FROM((SELECT DISTINCT user_id, EXTRACT(WEEK FROM occurred_at) AS signup_week FROM events 
WHERE event_type = 'signup_flow'AND event_name = 'complete_signup'AND EXTRACT(WEEK FROM occurred_at) = 18) a 
LEFT JOIN(SELECT DISTINCT user_id, EXTRACT(WEEK FROM occurred_at) AS engagement_week
FROM events WHERE event_type = 'engagement') b 
ON a.user_id = b.user_id) ORDER BY a.user_id;

/* Calculate the weekly engagement per device */
SELECT EXTRACT(YEAR FROM occurred_at) AS year,
EXTRACT(WEEK FROM occurred_at) AS week, device,
COUNT(DISTINCT user_id) AS Count 
FROM events WHERE event_type = 'engagement' GROUP BY year,week,device  ORDER BY year,week,device;

/* Calculate the email engagement metrics */
SELECT 
100.0*SUM(CASE WHEN email_cat='email_open' THEN 1 ELSE 0 END)/SUM(CASE WHEN email_cat='email_sent' THEN 1 ELSE 0 END) AS email_open_rate,
100.0*SUM(CASE WHEN email_cat='email_click' THEN 1 ELSE 0 END)/SUM(CASE WHEN email_cat='email_sent' THEN 1 ELSE 0 END) AS email_clicked_rate
FROM
(SELECT *,CASE WHEN action IN ('sent_weekly_digest','sent_reengagement_email') THEN 'email_sent' 
WHEN action IN ('email_open') THEN 'email_open' 
WHEN action in ('email_clickthrough') THEN 'email_click' END AS email_cat FROM email_events)a;


