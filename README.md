# End-to-End-Ravenstack-Churn-Analysis

Building an end-to-end Date WareHouse with PostgreSQL, using an comprehensive ETL process, data modelling and a churn analysis.


## Executive Summary

*post findings here*

### Building the Data Warehouse

#### Objective 

To develop a data warehouse with PostgreSQL to analyze churn and retention within customer subscriptions for RavenStack using data-driven business decisions.

#### Specifications

The main objective of is to develop an end-to-end ELT Pipeline to transform raw data into a structured dataset for a churn analysis.

The pipeline will follow the Medallion Architecture:
1. **Bronze Layer:** Load the raw dataset into PostgreSQL and keeping the original data
2. **Silver Layer:** Clean, and standardize the data to ensure consistency.
3. **Gold Layer:** Create analytical views using dimension and fact tables to support churn, cohort and customer retention analysis.

<img width="1259" height="655" alt="image" src="https://github.com/user-attachments/assets/39cab4ff-e1cd-4efe-a92b-56e3e5cc6e87" />

##### Bronze Layer


 
## Licensing

This dataset is fully synthetic and distributed under a permissive MIT-like license.

You may use or remix it for learning, research, or portfolio purposes.

**All rights to this dataset belong to River @ Rivalytics.**

