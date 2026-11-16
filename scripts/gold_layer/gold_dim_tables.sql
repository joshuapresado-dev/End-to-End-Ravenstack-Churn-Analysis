--DIM Creation--
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

drop view if exists gold.dim_accounts;
create or replace view gold.dim_accounts as
select
	row_number() over () as account_key,
	ra.account_id as account_id,
	ra.account_name as account_name,
	ra.industry as industry,
	ra.country as country_abbr,
	ra.signup_date as signup_date,
	ra.referral_source
from silver.ravenstack_accounts ra;

--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

drop view if exists gold.dim_plan;
create or replace view gold.dim_plan as
select
    row_number() over (
        order by plan_tier, billing_frequency
    ) as plan_key,
    plan_tier,
    billing_frequency
from (
    select distinct
        plan_tier,
        billing_frequency
    from silver.ravenstack_subscriptions
) p;

--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

drop view if exists gold.dim_reporting_period;
create or replace view gold.dim_reporting_period as
with date_series_cte as (
select 
	generate_series(min(rs.start_date)::date,
					max(rs.end_date)::date,
					interval '4 weeks')::date as start_date_dr
	from silver.ravenstack_subscriptions rs
	where end_date is not null
)

select
	row_number() over () as date_key,
	start_date_dr as start_date,
	(start_date_dr + interval '4 weeks')::date as end_date
from date_series_cte;

--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

drop view if exists gold.dim_feature;
create or replace view gold.dim_feature as
select
	distinct rfu.feature_name,
	is_beta_feature
from  silver.ravenstack_feature_usage rfu
order by rfu.feature_name;


--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------



--------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------END-------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------


