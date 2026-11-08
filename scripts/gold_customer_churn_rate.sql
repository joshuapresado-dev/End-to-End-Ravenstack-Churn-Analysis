--- customer churn rate ---

with date_range as ( 
	select generate_series('2023-02-12'::date,
						   '2024-12-31'::date,
						   interval '1 month')::date as start_date_dr
),

start_accounts as ( 
	select
		distinct d.start_date_dr as starting_date,
		rs.account_id as start_account_id
	from silver.ravenstack_subscriptions rs
	inner join date_range d
		on rs.start_date < d.start_date_dr
		and (rs.end_date > d.start_date_dr or rs.end_date is null)
	
),

end_accounts as (  
	select 
		distinct d.start_date_dr as ending_date,
		rs.account_id as end_account_id
	from silver.ravenstack_subscriptions rs
	inner join date_range d
		on rs.start_date < d.start_date_dr
		and (rs.end_date > (d.start_date_dr + interval '1 month') or rs.end_date is null)
		
),

churned_accounts as ( 
	select
		s.starting_date,
		s.start_account_id as churned_account_id
	from start_accounts s
	left outer join end_accounts e
		on s.start_account_id = e.end_account_id
		and s.starting_date = e.ending_date
	where e.end_account_id is null
),

start_count as ( 
	select 
		starting_date,
		count(start_accounts.*) as n_start
	from start_accounts
	group by starting_date
),

churn_count as ( 
	select
		starting_date,
		count(churned_accounts.*) as n_churned
	from churned_accounts
	group by starting_date
)

select
	s.starting_date,
	(s.starting_date + interval '1 month')::date,
	n_churned::float/n_start::float as churn_rate,
	1-n_churned::float/n_start::float as retention_rate,
	n_start,
	n_churned
from start_count s
	inner join churn_count c
	on s.starting_date = c.starting_date
	order by s.starting_date
