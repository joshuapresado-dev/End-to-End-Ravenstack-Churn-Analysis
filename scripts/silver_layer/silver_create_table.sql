/*
===============================================================================================
DDL: Create Empty Silver Tables
===============================================================================================
Script purpose:
		This prodcure is simply creating and preparing our silver tables to insert our bronze data into
	Actions:
		- Drop Table is it exists
		- Creating Empty tables with the correct parameters to the orignal raw dataset
		- Added metadata column for creation date
===============================================================================================
WARNING: IF USED YOU WILL EMPTY AND LOSE ALL DATA IN THE SILVER LAYERS
-----------------------------------------------------------------------------------------------
								USE WITH CAUTION
===============================================================================================
*/

-- Load data into table for silver layer -- 

drop table if exists silver.ravenstack_accounts;

create table silver.ravenstack_accounts ( 
	account_id VARCHAR(50),
	account_name VARCHAR(50),
	industry VARCHAR(50),
	country VARCHAR(50),
	signup_date date,
	referral_source VARCHAR(50),
	plan_tier VARCHAR(50),
	seats INT,
	is_trial VARCHAR(50),
	churn_flag VARCHAR(50),
	dwh_create_date timestamp default CURRENT_TIMESTAMP
);

drop table if exists silver.ravenstack_churn_events; 

create table silver.ravenstack_churn_events( 
	churn_event VARCHAR(50),
	account__id VARCHAR(50),
	churn_date date,
	reason_code VARCHAR(50),
	refund_amount_usd FLOAT,
	preceding_upgrade_flag VARCHAR(50),
	preceding_downgrade_flag VARCHAR(50),
	is_reactiviation VARCHAR(50),
	feedback_text VARCHAR(50),
	dwh_create_date timestamp default CURRENT_TIMESTAMP
);

drop table if exists silver.ravenstack_feature_usage;

create table silver.ravenstack_feature_usage(
	usage_id VARCHAR(50),
	subscription_id VARCHAR(50),
	usage_date date,
	feature_name VARCHAR(50),
	usage_count INT,
	usage_duration INT,
	error_count INT,
	is_beta_feature VARCHAR(50),
	dwh_create_date timestamp default CURRENT_TIMESTAMP
);

drop table if exists silver.ravenstack_subscriptions;

create table silver.ravenstack_subscriptions( 
	subscription_id VARCHAR(50),
	account_id VARCHAR(50),
	start_date date,
	end_date date,
	plan_tier VARCHAR(50),
	seats INT,
	mrr_amount FLOAT,
	arr_amount FLOAT,
	is_trial VARCHAR(50),
	upgrade_flag VARCHAR(50),
	downgrade_flag VARCHAR(50),
	churn_flag VARCHAR(50),
	billing_frequency VARCHAR(50),
	auto_renew_flag VARCHAR(50),
	dwh_create_date timestamp default CURRENT_TIMESTAMP
);

drop table if exists silver.ravenstack_support_tickets;

create table silver.ravenstack_support_tickets ( 
	ticket_id VARCHAR(50),
	account_id VARCHAR(50),
	submitted_at date,
	closed_at timestamp,
	resolution_time_hours FLOAT,
	priority VARCHAR(50),
	first_response_time_minutes FLOAT,
	satisfation_score FLOAT,
	escalation_flag VARCHAR(50),
	dwh_create_date timestamp default CURRENT_TIMESTAMP	
);

