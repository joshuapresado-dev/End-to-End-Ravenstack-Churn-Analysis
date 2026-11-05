-- just standardizing --


create or replace procedure silver.load_silver()
language plpgsql
as $silver_layer$
declare 
	batch_start timestamp;
	start_time timestamp;
	end_time timestamp;
	rows_loaded BIGINT;
	
begin
	
	batch_start := clock_timestamp();
	raise notice ' ';
	raise notice '============================================';
	raise notice '           Loading Silver Layer             ';
	raise notice '============================================';
	raise notice ' ';
	

		start_time := clock_timestamp();
	
		raise notice '>> Truncating: silver.ravenstack_accounts';

		truncate silver.ravenstack_accounts; 
		
		
		raise notice '>> Inserting: silver.ravenstack_accounts';
		insert into silver.ravenstack_accounts (
			account_id,
			account_name,
			industry,
			country,
			signup_date,
			referral_source,
			plan_tier,
			seats,
			is_trial,
			churn_flag
		)
		
		select
			trim(ra.account_id) as account_id,
			trim(ra.account_name) as account_name,
			initcap(trim(ra.industry)) as industry,
			UPPER(trim(ra.country)) as country,
			ra.signup_date::date as signup_date,
			lower(trim(ra.referral_source)) as referral_source,
			initcap(trim(ra.plan_tier)),
			ra.seats::numeric,
			ra.is_trial::boolean as is_trial,
			ra.churn_flag::boolean as churn_flag
		from bronze.ravenstack_accounts ra;
		
		GET DIAGNOSTICS rows_loaded = ROW_COUNT;
		
		end_time := clock_timestamp();
	
		RAISE NOTICE '>> Loaded: silver.ravenstack_accounts';
		RAISE NOTICE '>> Rows Loaded: %', rows_loaded;
		RAISE NOTICE '>> Duration: % seconds',
			ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);
		RAISE NOTICE ''; 
		
		-- look into churn_events -- 
		
		start_time := clock_timestamp();
	
		raise notice '>> Truncating: silver.ravenstack_churn_events';
		truncate silver.ravenstack_churn_events;
		
		raise notice '>> Inserting: silver.ravenstack_churn_events';
		insert into silver.ravenstack_churn_events 
		(
			churn_event,
			account_id,
			churn_date,
			reason_code,
			refund_amount_usd,
			preceding_upgrade_flag,
			preceding_downgrade_flag,
			is_reactivation,
			feedback_text
		)
		
		select
			trim(rce.churn_event),
			trim(rce.account__id) as account_id,
			rce.churn_date::date as churn_date,
			lower(trim(rce.reason_code)) as reason_code,
			round(rce.refund_amount_usd::numeric,2) as refund_amount_usd,
			rce.preceding_upgrade_flag::boolean,
			rce.preceding_downgrade_flag::boolean,
			rce.is_reactiviation::boolean as is_reactivation,
			rce.feedback_text 
		from bronze.ravenstack_churn_events rce; 
		
		GET DIAGNOSTICS rows_loaded = ROW_COUNT;
		
		end_time := clock_timestamp();
	
		RAISE NOTICE '>> Loaded: silver.ravenstack_churn_events';
		RAISE NOTICE '>> Rows Loaded: %', rows_loaded;
		RAISE NOTICE '>> Duration: % seconds',
			ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);
		RAISE NOTICE ''; 
		
		-- look into feature usage --
		
		start_time := clock_timestamp();
		
		raise notice '>> Truncating: silver.ravenstack_feature_usage';
		truncate silver.ravenstack_feature_usage;
		
		raise notice '>> Inserting: silver.ravenstack_feature_usage';
		insert into silver.ravenstack_feature_usage  ( 
			usage_id,
			subscription_id,
			usage_date,
			feature_name,
			usage_count, 
			usage_duration,
			error_count,
			is_beta_feature
		)
		
		select
			trim(rfu.usage_id),
			trim(rfu.subscription_id),
			rfu.usage_date::date as usage_date,
			lower(trim(rfu.feature_name)) as feature_name,
			rfu.usage_count,
			rfu.usage_duration,
			rfu.error_count,
			rfu.is_beta_feature::boolean is_beta_feature
		from bronze.ravenstack_feature_usage rfu;
		
		GET DIAGNOSTICS rows_loaded = ROW_COUNT;
		
		end_time := clock_timestamp();
	
		RAISE NOTICE '>> Loaded: silver.ravenstack_feature_usage';
		RAISE NOTICE '>> Rows Loaded: %', rows_loaded;
		RAISE NOTICE '>> Duration: % seconds',
			ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);
		RAISE NOTICE ''; 
		
		
		-- look into subscriptions --
		start_time := clock_timestamp();
		
		raise notice '>> Truncating: silver.ravenstack_subscriptions';		
		truncate silver.ravenstack_subscriptions;
		
		raise notice '>> Inserting: silver.ravenstack_subscriptions';
		insert into silver.ravenstack_subscriptions ( 
			subscription_id,
			account_id,
			start_date,
			end_date,
			plan_tier,
			seats,
			mrr_amount,
			arr_amount,
			is_trial,
			upgrade_flag,
			downgrade_flag,
			churn_flag,
			billing_frequency,
			auto_renew_flag
		)
		
		select
			trim(rs.subscription_id),
			trim(rs.account_id),
			rs.start_date::date as start_date,
			rs.end_date::date as end_date, -- null represents active subscription --
			initcap(trim(rs.plan_tier)) as plan_tier,
			rs.seats::integer,
			round(rs.mrr_amount::numeric,2) as mrr_amount,
			round(rs.arr_amount::numeric,2) as arr_amount,
			rs.is_trial::boolean as is_trial,
			rs.upgrade_flag::boolean as upgrade_flag,
			rs.downgrade_flag::boolean as downgrade_flag,
			rs.churn_flag::boolean as churn_flag,
			lower(trim(rs.billing_frequency)) as billing_frequency,
			rs.auto_renew_flag::boolean as auto_renew_flag
		from bronze.ravenstack_subscriptions rs; 
		
		GET DIAGNOSTICS rows_loaded = ROW_COUNT;
		
		end_time := clock_timestamp();
	
		RAISE NOTICE '>> Loaded: silver.ravenstack_subscriptions';
		RAISE NOTICE '>> Rows Loaded: %', rows_loaded;
		RAISE NOTICE '>> Duration: % seconds',
			ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);
		RAISE NOTICE ''; 
		
		
		
		-- look into support tickets -- 
		
		start_time := clock_timestamp();
		
		raise notice '>> Truncating: silver.ravenstack_support_tickets';
		truncate silver.ravenstack_support_tickets;
		
		raise notice '>> Inserting: silver.ravenstack_support_tickets';
		insert into silver.ravenstack_support_tickets ( 
			ticket_id,
			account_id,
			submitted_at,
			closed_at,
			resolution_time_hours,
			priority,
			first_response_time_minutes,
			satisfaction_score,
			escalation_flag
		)
		
		select 
			trim(rst.ticket_id),
			trim(rst.account_id),
			rst.submitted_at::date as submitted_at,
			rst.closed_at::date as closed_at,
			rst.resolution_time_hours::numeric,
			lower(trim(rst.priority)) as priority,
			rst.first_response_time_minutes::numeric,
			rst.satisfation_score as satisfaction_score,
			rst.escalation_flag::boolean as escalation_flag
		from bronze.ravenstack_support_tickets rst; 

		GET DIAGNOSTICS rows_loaded = ROW_COUNT;
		
		end_time := clock_timestamp();
	
		RAISE NOTICE '>> Loaded: silver.ravenstack_support_tickets';
		RAISE NOTICE '>> Rows Loaded: %', rows_loaded;
		RAISE NOTICE '>> Duration: % seconds',
			ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);
		RAISE NOTICE ''; 
		
		
	-- END --
	
	raise notice ' ';
	raise notice '============================================';
	raise notice '          Finished Silver Layer             ';
	raise notice '============================================';
	raise notice ' ';

	raise notice 'Total batch duration: % seconds',
		round( 
			extract(epoch from (clock_timestamp() - batch_start))::numeric, 3);
	

exception
	when others then
	
	raise notice ' ';
	raise notice '============================================';
	raise notice '           Silver Layer Failed              ';
	raise notice '============================================';
	raise notice ' ';		

	raise notice 'Error message: %', SQLERRM;
	raise notice 'SQLSTATE: %', SQLSTATE;
	
	raise;
	
end;
$silver_layer$;

call silver.load_silver();