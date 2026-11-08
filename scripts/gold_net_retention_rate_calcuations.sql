--- find date range ---

select
	min(start_date),
	max(end_date)
from silver.ravenstack_subscriptions rs 
	where rs.end_date  is not null;


---- retention rates ---

with date_range as ( 
	select generate_series('2023-02-12'::date,
						   '2024-12-31'::date,
						   '1 month') as start_date
),
start_accounts as
( 
	select 
			d.start_date,
		   	rs.account_id, 
		   	sum(rs.mrr_amount) as total_starting_mrr
	from silver.ravenstack_subscriptions rs 
		inner join date_range d on
			rs.start_date <= d.start_date
			and (rs.end_date > d.start_date or rs.end_date is null)
	group by d.start_date, rs.account_id
),
end_accounts as
( 
	select
		d.start_date, 
		rs.account_id, 
		sum(rs.mrr_amount) as total_ending_mrr
	from silver.ravenstack_subscriptions rs 
		inner join date_range d on
			rs.start_date <= (d.start_date+interval '1 month')
			and (rs.end_date > (d.start_date+interval '1 month') or rs.end_date is null)
	group by 
			d.start_date,
			rs.account_id
),
retained_accounts as 
( 
	select
		s.start_date,
		s.account_id, 
		sum(e.total_ending_mrr) as total_mrr
	from start_accounts s 
		inner join end_accounts e
			on s.account_id = e.account_id
			and s.start_date = e.start_date
	group by s.start_date, s.account_id
),
start_mrr as 
( 
	select
		start_date,
		sum(start_accounts.total_starting_mrr) as start_mrr
	from start_accounts 
	group by start_date
),
retain_mrr as 
( 
	select 
		start_date,
		sum(retained_accounts.total_mrr) as retain_mrr
	from retained_accounts 
	group by start_date
)
select
	s.start_date::date,
	(s.start_date+interval'1 month')::date as end_date,
	s.start_mrr,
	r.retain_mrr,
	r.retain_mrr/s.start_mrr as net_mrr_retention_rate, 
	1 - (r.retain_mrr/s.start_mrr) as net_mrr_churn_rate
from start_mrr s
inner join retain_mrr r 
	on s.start_date = r.start_date
