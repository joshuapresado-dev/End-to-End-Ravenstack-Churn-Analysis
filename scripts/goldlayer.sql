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
		s.account_id, 
		sum(e.total_ending_mrr) as total_mrr
	from start_accounts s 
		inner join end_accounts e
			on s.account_id = e.account_id
	group by s.account_id
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
		sum(retained_accounts.total_mrr) as retain_mrr
	from retained_accounts 
)
select
	retain_mrr/start_mrr as net_mrr_rentention_rate,
	1.0 - retain_mrr/start_mrr as net_mrr_churn_rate,
	start_mrr,
	retain_mrr
from start_mrr, retain_mrr;



-- customer churn rates--


-------------------------------------------------------------------------------


with date_range as ( 
	select generate_series('2023-02-12'::date,
						   '2024-12-31'::date,
						   interval '1 month')::date as start_date
),

start_accounts as (  
	select
		distinct d.start_date,
		rs.account_id
	from silver.ravenstack_subscriptions rs
	inner join date_range d
		on rs.start_date < d.start_date
		and (rs.end_date > d.start_date or rs.end_date is null)
),

end_accounts as (  
	select 
		distinct d.start_date,
		rs.account_id
	from silver.ravenstack_subscriptions rs
	inner join date_range d 
		on rs.start_date <= (d.start_date+interval '1 month')
		and (rs.end_date > (d.start_date+interval '1 month') or rs.end_date is null)
),

churned_accounts as(  
	select
		s.start_date,
		s.account_id
	from start_accounts s
	left outer join end_accounts e on 
		s.account_id = e.account_id
	where e.account_id is null
),

start_count as ( 
	select
		start_date,
		count(start_accounts.*)::float as n_starting
	from start_accounts
	group by start_date 
),

end_count as ( 
	select
		start_date,
		count(end_accounts.*)::float as n_ending
	from end_accounts 
	group by start_date
),
churn_count as (
	select
		start_date,
		count(churned_accounts.*) as n_churned 
	from churned_accounts
	group by start_date
)

select
	s.start_date, 
	(s.start_date+interval '1 month')::date as end_date,
	n_churned::float/n_starting::float as churn_rate,
	1.0 - n_churned::float/n_starting::float as retention_rate,
	n_starting,
	n_churned
from start_count s
	inner join churn_count c
		on s.start_date = c.start_date
	order by s.start_date; 


-- mmr customer churn rate -- 

with date_range as 
( 
	select '2024-11-01'::date as starting_date,
		   '2024-12-01'::date as ending_date
),
starting_accounts as 
( 
	select
		rs.account_id,
		sum(rs.mrr_amount) as total_starting_mrr
	from silver.ravenstack_subscriptions rs 
		inner join date_range d 
			on rs.start_date <= d.starting_date
			and (rs.end_date > d.starting_date or rs.end_date is null)
		group by rs.account_id 
	
),
end_accounts as 
( 
	select
		rs.account_id,
		sum(rs.mrr_amount) as total_ending_mrr
	from silver.ravenstack_subscriptions rs
		inner join date_range d
			on rs.start_date <= d.starting_date
			and (rs.end_date > d.ending_date or rs.end_date is null)
	group by rs.account_id 
),
churned_accounts as 
(  
	select 
		s.account_id,
		sum(s.total_starting_mrr) as total_churned_mrr
	from starting_accounts s 
	left outer join end_accounts e
		on s.account_id = e.account_id 
	where e.account_id is null
	group by s.account_id
),
downsell_accounts as 
(  
	select 
		s.account_id,
		s.total_starting_mrr-e.total_ending_mrr as downsell_amount
	from starting_accounts s
		inner join end_accounts e
			on s.account_id = e.account_id
		where e.total_ending_mrr < s.total_starting_mrr
),
start_mrr as 
(
	select
		sum(s.total_starting_mrr) as start_mrr
	from starting_accounts s
),
churned_mrr as 
( 
	select 
		sum(ca.total_churned_mrr) as churned_mrr
	from churned_accounts ca
),
downsell_mrr as 
(
	select 
		coalesce(sum(da.downsell_amount),0.0) as downsell_mrr
	from downsell_accounts da
)

select
	(churned_mrr+downsell_mrr)/start_mrr as mrr_churn_rate,
	start_mrr,
	churned_mrr,
	downsell_mrr
from start_mrr, churned_mrr, downsell_mrr;