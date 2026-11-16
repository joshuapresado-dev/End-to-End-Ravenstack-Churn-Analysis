/*
==============================================================================================================================
DDL: Create Dim Fact Views
==============================================================================================================================
Script Purpose:
		This procedure is to create the fact tables for our dataset, preparing the date to be used for EDA or business decisions
		using a constellation schema
	Actions:
		- Drop Views if it exists
		- Create views using silver and gold dim tables
==============================================================================================================================
*/

--- Fact Creation ---
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------

drop view if exists gold.fact_subscriptions;
create or replace view gold.fact_subscriptions as 
select
	row_number() over () as subscription_key,
	rs.subscription_id as subscription_id,    
	rs.account_id as account_id,
	ra.industry as industry,
	ra.country as country_abbr,
	ra.signup_date as signup_date,
	rs.start_date  as start_date,
	rs.end_date as end_date,
	rs.plan_tier as plan_tier,
	rs.mrr_amount as monthly_recurring_revenue,
	rs.seats as number_of_seats, 
	ra.referral_source as referrals,
	rs.is_trial as trial,
	rs.churn_flag as churn_flag,
	rs.downgrade_flag as downgrade,
	rs.upgrade_flag as upgrade,
	rs.auto_renew_flag as auto_renew	
from silver.ravenstack_subscriptions rs
left join silver.ravenstack_accounts ra
	on rs.account_id = ra.account_id;

--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------	


drop view if exists gold.fact_feature_usage;
create or replace view gold.fact_feature_usage as
select
	row_number() over() as feature_key,
    rfu.usage_id,
    rfu.subscription_id,
    rs.account_id,
    rfu.usage_date,
    rfu.feature_name,
    rfu.usage_count,
    rfu.usage_duration,
    rfu.error_count,
    rfu.is_beta_feature
from silver.ravenstack_feature_usage rfu
left join silver.ravenstack_subscriptions rs
    on rfu.subscription_id = rs.subscription_id;

--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------	

drop view if exists gold.fact_support_tickets;
create or replace view gold.fact_support_tickets as
select
	ticket_id,
    account_id,
    submitted_at,
    closed_at,
    resolution_time_hours,
    priority,
    first_response_time_minutes,
    satisfaction_score,
    UPPER(escalation_flag)::boolean as escaltion_flag,
    case 
    	when closed_at is not null then TRUE
    	else FALSE
    end as is_resolved
from silver.ravenstack_support_tickets;

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

drop view if exists gold.fact_churn_events;
create or replace view gold.fact_churn_events as 
select
	rce.churn_event,
	da.account_key,
	da.account_id,
	da.company_number,
	da.plan_tier,
	da.signup_date, 
	rce.churn_date,
	rce.refund_amount_usd,
	UPPER(rce.is_reactivation)::boolean,
	UPPER(rce.preceding_downgrade_flag)::boolean,
	UPPER(rce.preceding_upgrade_flag)::boolean,
	rce.reason_code 
from silver.ravenstack_churn_events rce
left join gold.dim_accounts da 
	on da.account_id = rce.account__id;
