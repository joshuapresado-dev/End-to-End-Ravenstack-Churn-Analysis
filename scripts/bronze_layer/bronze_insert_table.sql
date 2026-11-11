/*
===============================================================================================
Store procedure: Load Bronze Layer (Raw data to Bronze)
===============================================================================================
Script purpose:
		This stored procedure is to insert the raw data to populate our empty 'Bronze' tables
		from our raw tables
	Actions:
		- Truncate bronze tables
		- Insert raw data values without changing or transforming any parameters

To Use:
	call bronze.load_bronze();
===============================================================================================
*/


-- Insert Data into Table --

create or replace procedure bronze.load_bronze()
language plpgsql
as $bronze_layer$
declare 
	batch_start timestamp;
	start_time timestamp;
	end_time timestamp;
	rows_loaded BIGINT;
	
begin
	
	batch_start := clock_timestamp();
	raise notice ' ';
	raise notice '============================================';
	raise notice '           Loading Bronze Layer             ';
	raise notice '============================================';
	raise notice ' ';
	
	-- Ravenstack_accounts table insert starting --
	
	
	-- Accounts Table --
	
	start_time := clock_timestamp();
	
	raise notice '>> Truncating: bronze.ravenstack_accounts';
	truncate bronze.ravenstack_accounts;
	
	raise notice '>> Loading: bronze.ravenstack_accounts';
	copy bronze.ravenstack_accounts
	from '/tmp/ravenstack_accounts.csv'
	with (FORMAT csv, header);
	
	GET DIAGNOSTICS rows_loaded = ROW_COUNT;
	
	end_time := clock_timestamp();
	
	RAISE NOTICE '>> Loaded: bronze.ravenstack_accounts';
	RAISE NOTICE '>> Rows Loaded: %', rows_loaded;
	RAISE NOTICE '>> Duration: % seconds',
		ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);
	RAISE NOTICE '';
		
	
	-- Churn Events Table --
	
	start_time := clock_timestamp();
	
	Raise notice '>> Truncating: bronze.ravenstack_churn_events';
	truncate bronze.ravenstack_churn_events; 
	
		
	raise notice '>> Loading: bronze.ravenstack_churn_events';
	copy bronze.ravenstack_churn_events
	from '/tmp/ravenstack_churn_events.csv'
	with (FORMAT csv, header);
	
	GET DIAGNOSTICS rows_loaded = ROW_COUNT;
	
	
	end_time := clock_timestamp();
	
	RAISE NOTICE '>> Loaded: bronze.ravenstack_churn_events';
	RAISE NOTICE '>> Rows Loaded: %', rows_loaded;
	RAISE NOTICE '>> Duration: % seconds',
		ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);
	RAISE NOTICE '';
	
	-- Feature Usage Table -- 
	
	start_time := clock_timestamp();
	
	Raise notice '>> Truncating: bronze.ravenstack_feature_usage';	
	truncate bronze.ravenstack_feature_usage;
	
	raise notice '>> Loading: bronze.ravenstack_feature_usage';
	copy bronze.ravenstack_feature_usage
	from '/tmp/ravenstack_feature_usage.csv'
	with (FORMAT csv, header);

	GET DIAGNOSTICS rows_loaded = ROW_COUNT;	

	end_time := clock_timestamp();
	
	
	RAISE NOTICE '>> Loaded: bronze.ravenstack_feature_usage';
	RAISE NOTICE '>> Rows Loaded: %', rows_loaded;
	RAISE NOTICE '>> Duration: % seconds',
		ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);
	RAISE NOTICE '';
	
	-- Support Tickets Table --
	
	start_time := clock_timestamp();
	
	Raise notice '>> Truncating: bronze.ravenstack_support_tickets';
	truncate bronze.ravenstack_support_tickets;
	
	raise notice '>> Loading: bronze.ravenstack_support_tickets';
	copy bronze.ravenstack_support_tickets
	from '/tmp/ravenstack_support_tickets.csv'
	with (FORMAT csv, header);
	
	GET DIAGNOSTICS rows_loaded = ROW_COUNT;
	
	end_time := clock_timestamp();
		
	RAISE NOTICE '>> Loaded: bronze.ravenstack_support_tickets';
	RAISE NOTICE '>> Rows Loaded: %', rows_loaded;
	RAISE NOTICE '>> Duration: % seconds',
		ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);
	RAISE NOTICE '';
	
	-- Subscriptions Table --
	
	start_time := clock_timestamp();
	
	Raise notice '>> Truncating: bronze.ravenstack_subscriptions';	
	truncate bronze.ravenstack_subscriptions;
	
	raise notice '>> Loading: bronze.ravenstack_subscriptions';
	copy bronze.ravenstack_subscriptions
	from '/tmp/ravenstack_subscriptions.csv'
	with (FORMAT csv, header);
	
	GET DIAGNOSTICS rows_loaded = ROW_COUNT;
	
	end_time := clock_timestamp();
	
	RAISE NOTICE '>> Loaded: bronze.ravenstack_subscriptions';
	RAISE NOTICE '>> Rows Loaded: %', rows_loaded;
	RAISE NOTICE '>> Duration: % seconds',
		ROUND(EXTRACT(EPOCH FROM (end_time - start_time))::numeric, 3);
	RAISE NOTICE '';
	
	-- END --
	
	raise notice ' ';
	raise notice '============================================';
	raise notice '          Finished Bronze Layer             ';
	raise notice '============================================';
	raise notice ' ';

	raise notice 'Total batch duration: % seconds',
		round( 
			extract(epoch from (clock_timestamp() - batch_start))::numeric, 3);
	

exception
	when others then
	
	raise notice ' ';
	raise notice '============================================';
	raise notice '           Bronze Layer Failed              ';
	raise notice '============================================';
	raise notice ' ';		

	raise notice 'Error message: %', SQLERRM;
	raise notice 'SQLSTATE: %', SQLSTATE;
	
	raise;
	
end;
$bronze_layer$;

call bronze.load_bronze();
