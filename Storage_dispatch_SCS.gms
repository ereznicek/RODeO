$Title Arbitrage and Ancillary Services for a Price Taking Storage Facility

$OnText

This model determines optimal behavior for a storage, generator or DR facility.
Storage facilities include battery, pumped hydro, hydrogen, or compressed air.

The model assumes price-taking behavior.  The intent of the model is to allow
either perfect knowledge or forecast prices at user-specified forecast horizons.

Based on original model written March and April 2012 by Aaron Townsend
Edited by Josh Eichman, Masha Koleva, and Omar J. Guerra

Notes:
To run as DR device set output values to 0 except output_eff which must be >0
To run as storage device set values for input and output as desired
To run as baseload DR device setup same as for DR device and set base_op_instance=1
When loading files with multiple devices, each column header entry must match the device number

ToDo:
Determine the resoultion (1 min)
Detemrine the input range (e.g., exactly a 24 hour rolling window)
    Solar forecast are released every hour for an entire day
Create file of optimized storage setpoint
Create file to keep track of predicted and actual values


$OffText
*===============================================================================
* This toggle switches an iteration mode which updates the product break-even cost
$if not set run_opt_breakeven      $set run_opt_breakeven   1
* If considering NEM benefits
*       Assumes: NEM benefits are for energy only (does not affect demand charges)
*                Must pay non-bypassable charges on any net metered electricity
*                Example1: for TOU_bin 1, hour 1, 3MWh consumed, 1MWh produced. End of month result: Pay for 2MWh of energy at import rate, pay for 1MWh of NBC (NBC charge components are included in the regular import rate (NDC, DWR bond charge, etc.)
*                Example2: for TOU_bin 1, hour 1, 1MWh consumed, 0MWh produced. TOU_bin 1, hour 2, 0MWh conusumed, 3MWh produced. End of month result: Receive NSCR rate for 2MWh pay NBC for 1 MWh
$if not set NEM_nscr               $set NEM_nscr            0
*===============================================================================
*set defaults for parameters usually passed in by a calling program
*so that this script can be run directly if desired

$if not set Max_input_prof_inst         $set Max_input_prof_inst            Max_input_cap_ones_hourly
$if not set Max_output_prof_inst        $set Max_output_prof_inst           Max_output_cap_ones_hourly
$if not set product_consumed_inst       $set product_consumed_inst          Product_consumption_flat_hourly
$if not set elec_rate_instance          $set elec_rate_instance             5a3430585457a3e3595c48a2_hourly_dummy_SanDiego
$if not set load_prof_instance          $set load_prof_instance             Additional_load_none_hourly
$if not set AS_price_inst               $set AS_price_inst                  Ancillary_services_hourly
$if not set Device_parameters_inst      $set Device_parameters_inst         Devices_parameters_empty
$if not set Device_ren_params_inst      $set Device_ren_params_inst         Devices_ren_parameters_empty
$if not set energy_purchase_price_inst  $set energy_purchase_price_inst     Energy_purchase_prices_Wholesale_MWh_NRELstandardscenarioGA2050
$if not set energy_sale_price_inst      $set energy_sale_price_inst         Energy_sale_prices_Wholesale_MWh_hourly
$if not set MACRS_instance              $set MACRS_instance                 MACRS_depreciation_schedule
$if not set NG_price_instance           $set NG_price_instance              NG_price_Price1_hourly
$if not set NSCR_instance               $set NSCR_instance                  NSCR
$if not set product_price_prof_inst     $set product_price_prof_inst        Product_price_Price1_hourly
$if not set ren_prof_instance           $set ren_prof_instance              renewable_profiles_PV_WPSP
$if not set outdir                      $set outdir                         Projects\SCS\Output
$if not set indir                       $set indir                          Projects\SCS\Data_files\TXT_files
$call 'if not exist %outdir%\nul mkdir %outdir%'

$if not set file_name_instance     $set file_name_instance     "SCS_gridimports_1hstor_test"
$if not set devices_instance       $set devices_instance       1
$if not set use_alt_devices        $set use_alt_devices        0
$if not set use_all_devices        $set use_all_devices        1
$if not set use_smart_charging     $set use_smart_charging     1
$if not set soft_cons_device_inst  $set soft_cons_device_inst  0
$if not set devices_ren_instance   $set devices_ren_instance   1
$if not set input_cap_instance     $set input_cap_instance     1
$if not set output_cap_instance    $set output_cap_instance    0
$if not set Renewable_MW_instance  $set Renewable_MW_instance  0

* Set the limiting price (must be less than infinity)
$if not set price_cap_instance     $set price_cap_instance     1000000000
$if not set max_output_cap_inst    $set max_output_cap_inst    Inf
* "max_input_cap_inst" must be greater than load profile otherwise infeasibilities occur
$if not set max_input_cap_inst     $set max_input_cap_inst     Inf
$if not set allow_import_instance  $set allow_import_instance  1
* by default allow_sales_instance should be 1; however, when it is 0, sales variables should be prohibited
$if not set allow_sales_instance   $set allow_sales_instance   0

$if not set input_LSL_instance     $set input_LSL_instance     0
$if not set output_LSL_instance    $set output_LSL_instance    0
$if not set Input_start_cost_inst  $set Input_start_cost_inst  0
$if not set Output_start_cost_inst $set Output_start_cost_inst 0
* Efficiency takes into account compressor. Otherwise, take 0.613669
$if not set input_efficiency_inst  $set input_efficiency_inst  0.611
$if not set output_efficiency_inst $set output_efficiency_inst 0.6

$if not set renew_cap_cost_inst    $set renew_cap_cost_inst    1027645
$if not set input_cap_cost_inst    $set input_cap_cost_inst    1672000
*1503000
$if not set input_cap_alt_cst_inst $set input_cap_alt_cst_inst 0
$if not set output_cap_cost_inst   $set output_cap_cost_inst   0
$if not set ProdStor_cap_cost_inst $set ProdStor_cap_cost_inst 554.4
$if not set ProdComp_cap_cost_inst $set ProdComp_cap_cost_inst 5000
$if not set renew_FOM_cost_inst    $set renew_FOM_cost_inst    15246
$if not set input_FOM_cost_inst    $set input_FOM_cost_inst    12800
$if not set input_FOM_alt_cst_inst $set input_FOM_alt_cst_inst 0
$if not set output_FOM_cost_inst   $set output_FOM_cost_inst   0
$if not set renew_VOM_cost_inst    $set renew_VOM_cost_inst    0
$if not set input_VOM_cost_inst    $set input_VOM_cost_inst    1.3
$if not set output_VOM_cost_inst   $set output_VOM_cost_inst   0

$if not set in_heat_rate_instance  $set in_heat_rate_instance  0
$if not set out_heat_rate_instance $set out_heat_rate_instance 0
$if not set storage_cap_instance   $set storage_cap_instance   8
$if not set storage_set_instance   $set storage_set_instance   1
$if not set storage_init_instance  $set storage_init_instance  0.16
$if not set storage_final_instance $set storage_final_instance 0.16
$if not set stor_dissipation_inst  $set stor_dissipation_inst  0.0
$if not set reg_cost_instance      $set reg_cost_instance      0
$if not set min_runtime_instance   $set min_runtime_instance   0
$if not set ramp_penalty_instance  $set ramp_penalty_instance  0

$if not set wacc_instance          $set wacc_instance          0.07
* The equity percentage is calculated based on wacc = 7% so, it has to be recalculated if wacc is changed
$if not set perc_equity_instance   $set perc_equity_instance   0.419
* Rate of return (ROR) and rate of equity (ROE) are company and project specific
$if not set ror_instance           $set ror_instance           0.0489
$if not set roe_instance           $set roe_instance           0.104
$if not set debt_interest_instance $set debt_interest_instance 0.0481
* combined federal and local taxes
$if not set cftr_instance          $set cftr_instance          0.2795
$if not set bonus_deprec_instance  $set bonus_deprec_instance  0.5
$if not set inflation_inst         $set inflation_inst         0.019
$if not set study_years_inst       $set study_years_inst       7
* Next two values change the resoultion of the optimization
*    hourly: 8760, 1     15min: 35040, 0.25       5min: 105120, 0.08333333333       1min: 525600, 0.01666666666
$if not set op_length_instance     $set op_length_instance     8760
$if not set op_period_instance     $set op_period_instance     8760
$if not set int_length_instance    $set int_length_instance    1
$if not set lookahead_instance     $set lookahead_instance     0

$if not set energy_only_instance   $set energy_only_instance   1
* Setting storage dissipation term (stor_dissipation_inst above) greater than zero increases CF above specified value and can cause infeasibilities if dissipation and/or CF are too large
$if not set Product_use_instance   $set Product_use_instance   1
* Product conversion instance sets the units that will be used for storage of product (e.g., Hydrogen [LHV] 0.033322222 (MWh/kg), electricity 1 (MWh/MWh)
$if not set product_conv_inst      $set product_conv_inst      0.033322222
$if not set CF_opt_instance        $set CF_opt_instance        1
$if not set CF_adj_inst            $set CF_adj_inst            0.4
$if not set Product_price_instance $set Product_price_instance 100
$if not set base_op_instance       $set base_op_instance       0
$if not set NG_price_adj_instance  $set NG_price_adj_instance  1
$if not set REC_price_inst         $set REC_price_inst         0

* Select to run retail or wholesale analysis (0=wholesale, 1=retail, 2=hybrid (retail for purchase and wholesale for sale))
$if not set run_retail_instance    $set run_retail_instance    0
$if not set NBC_instance           $set NBC_instance           19.19
$if not set one_active_device_inst $set one_active_device_inst 1
$if not set ITC_inst               $set ITC_inst               0
* Next values are used to initialize for real-time operation and shorten the run-time
*    To turn off set current_int = -1, next_int = 1 and max_int_instance = Inf
$if not set current_int_instance   $set current_int_instance   -1
$if not set next_int_instance      $set next_int_instance      1
$if not set current_stor_instance  $set current_stor_instance  0.5
$if not set current_max_instance   $set current_max_instance   0.8
$if not set max_int_instance       $set max_int_instance       Inf
$if not set read_MPC_file_instance $set read_MPC_file_instance 0

*Assumptions for the Low Carbon Fuel Standard
$if not set EneDens_inst           $set EneDens_inst           120
$if not set EER_inst               $set EER_inst               2.5
$if not set Grid_CarbInt_inst      $set Grid_CarbInt_inst      81.49
$if not set CI_base_line_inst      $set CI_base_line_inst      88.62
$if not set LCFS_price_inst        $set LCFS_price_inst        180


*        energy_only_instance = 0, 1 (1 = Energy only operation, 0 = All ancillary services included)
*        CF_adj_inst = adjusts the amount of product consumed from the uploaded file as capacity factor (%)
*        Product_price_instance = adjusts the value of product from the uploaded "Product_price" file in $/kg
*        Product_use_instance = 0, 1, or 2 for non-elec product production  (0=no extra product, 1=constant profile, 2=daily requirement)
*        base_op_instance = 0, 1 (0 = normal operation, 1 = baseload input operation)
*        base_pwr_instance = fraction of power setting   (0.198346561 for 100 and 0.793386238 for 400)   (revised: 0.7935049289 80%CF, eff=0.7)
*        NG_avg_price_instance = multiplier for adjusting natural gas price (i.e., NG_price = NG_price * NG_price_adj     (AVG = 6.8598 for ERCOT 2006, 4.21118 for CAISO 0711 2022, 3.61115 for CAISO 2012)
*        CF_opt_instance = 0, 1 for selecting optimization method (0 runs with fixed CF, 1 finds optimal CF)

Files
         input_echo_file         /%outdir%\Storage_dispatch_inputs_%file_name_instance%.csv/
         results_file            /%outdir%\Storage_dispatch_results_%file_name_instance%.csv/
         summary_file            /%outdir%\Storage_dispatch_summary_%file_name_instance%.csv/
         summary_file_yearly     /%outdir%\Storage_dispatch_summary-yearly_%file_name_instance%.csv/
         RT_out_file             /%outdir%\Real_time_output_values.csv/
         results_file_devices    /%outdir%\Storage_dispatch_resultsDevices_%file_name_instance%.csv/
         summary_file_devices    /%outdir%\Storage_dispatch_summaryDevices_%file_name_instance%.csv/
;

Sets
         interval          hourly time intervals in study period /1 * %op_length_instance%/
         months            months in study period                /1 * 12/
         month_interval(months,interval) a map of hours and months
         days              number of daily periods in study      /1 * 365/
         timed_dem_period  number of timed demand periods        /1 * 6/
         TOU_energy_period number of TOU energy bins             /1 * 10/
* You can select only the first device by setting "devices" equal to "/1/". Also, files loaded need to have at least two value columns.
         devices_load      Create set to manage lots of columns then parse down based on selection of devices above       / 1 * 200 /
         devices_ren_load  Create set to manage lots of columns then parse down based on selection of devices_ren above   / 1 * 200 /
         devices(devices_load)           number of devices modeled             /1 * %devices_instance%/
         devices_ren(devices_ren_load)   number of renewable devices included  /1 * %devices_ren_instance%/
         years             number of years in the study period /1 * %study_years_inst%/
;

Parameters
         elec_purchase_price(interval)           "electricity price in each interval ($/MWh)"
         elec_sale_price(interval)               "electricity price in each interval ($/MWh)"
         regup_price(interval)                   "price paid for regulation up ancillary service ($/MW)"
         regdn_price(interval)                   "price paid for regulation down ancillary service ($/MW)"
         spinres_price(interval)                 "price paid for spinning reserve ancillary service ($/MW)"
         nonspinres_price(interval)              "price paid for nonspinning reserve ancillary service ($/MW)"
         NG_price(interval)                      "natural gas price in each interval ($/MMBtu)"
         elec_purchase_price_forecast(interval)  "electricity price forecast in each interval ($/MWh)"
         elec_sale_price_forecast(interval)      "electricity price forecast in each interval ($/MWh)"
         product_consumed(interval,devices)      "Amount of product consumed by end user each interval (units depend on product_converion"
         product_price(interval,devices)         "Price for product for each interval ($/units depend on product_conversion)"
         renewable_signal(interval,devices_ren)  "Renewable generation signal (MW) (range from 0 to 1)"
         meter_mnth_chg(interval)                "monthly charge for meter ($/meter/month)"
         Renewable_power(interval,devices_ren)   "Scaled renewable signal based on 'Renewable_MW'"
         Fixed_dem(months)                       "Fixed demand charge $/MW-month"
         Timed_dem(timed_dem_period)             "Timed demand charge $/MW-month"
         TOU_energy_prices(TOU_energy_period)    "TOU Energy prices for each bin $/MWh"
         Load_profile(interval)                  "Load profile (MW)"

         Max_input_cap(interval,devices)         "Maximum capacity for input"
         Max_output_cap(interval,devices)        "Maximum capacity for output"

         input_capacity_MW(devices)              input capacity of storage facility (MW)                 /1 %input_cap_instance%/
         output_capacity_MW(devices)             output capacity of storage facility (MW)                /1 %output_cap_instance%/
         storage_capacity_hours(devices)         storage capacity of storage facility (hours at rated INPUT capacity)            /1 %storage_cap_instance%/
         storage_set_final(devices)              Turns on or off storage final value (set to zero if capacity factor is 100%)    /1 %storage_set_instance%/
         storage_init(devices)                   Storage level at beginning of simulation (interval = 1)                         /1 %storage_init_instance%/
         storage_final(devices)                  Storage level at end of simulation (interval = operating_period_length)         /1 %storage_final_instance%/
         storage_dissipation(devices)            Storage dissipation term as a percentage of input power (MW)                    /1 %stor_dissipation_inst%/

         output_LSL_fraction(devices)            output lower sustainable limit as a fraction of the output capacity             /1 %output_LSL_instance%/
         output_regup_limit_fraction(devices)    regulation up capacity limit as a fraction of the output capacity (value set below)
         output_regdn_limit_fraction(devices)    regulation down capacity limit as a fraction of the output capacity (value set below)
         output_spinres_limit_fraction(devices)  spinning reserve capacity limit as a fraction of the output capacity (value set below)
         output_nonspinres_limit_fraction(devices) nonspinning reserve capacity limit as a fraction of the output capacity (value set below)

         input_LSL_fraction(devices)             input lower sustainable limit as a fraction of the input capacity               /1 %input_LSL_instance%/
         input_regup_limit_fraction(devices)     regulation up capacity limit as a fraction of the input capacity (value set below)
         input_regdn_limit_fraction(devices)     regulation down capacity limit as a fraction of the input capacity (value set below)
         input_spinres_limit_fraction(devices)   spinning reserve capacity limit as a fraction of the input capacity (value set below)
         input_nonspinres_limit_fraction(devices) nonspinning reserve capacity limit as a fraction of the input capacity (value set below)

         input_efficiency(devices)               "efficiency of storage mechanism"                       /1 %input_efficiency_inst%/
         output_efficiency(devices)              "efficiency of conversion back to electricity"          /1 %output_efficiency_inst%/
         input_heat_rate(devices)                "heat rate of facility (MMBtu/MWh produced)"            /1 %in_heat_rate_instance%/
         output_heat_rate(devices)               "heat rate of facility (MMBtu/MWh produced)"            /1 %out_heat_rate_instance%/
         input_startup_cost(devices)             "cost to startup the input side ($/MW-start)"           /1 %Input_start_cost_inst%/
         output_startup_cost(devices)            "cost to startup the output side ($/MW-start)"          /1 %Output_start_cost_inst%/
         renew_cap_cost(devices_ren)             "upfront capital cost ($/MW)"                           /1 %renew_cap_cost_inst%/
         input_cap_cost(devices)                 "upfront capital cost ($/MW)"                           /1 %input_cap_cost_inst%/
         input_cap_alt_cost(devices)             "upfront capital cost for alternate option ($/MW)"      /1 %input_cap_alt_cst_inst%/
         output_cap_cost(devices)                "upfront capital cost ($/MW)"                           /1 %output_cap_cost_inst%/
         ProdStor_cap_cost(devices)              "upfront capital cost ($/units depend)"                 /1 %ProdStor_cap_cost_inst%/
         ProdComp_cap_cost(devices)              "upfront product additional capital cost ($/units/h)"   /1 %ProdComp_cap_cost_inst%/
         renew_FOM_cost(devices_ren)             "yearly FOM cost ($/MW-year)"                           /1 %renew_FOM_cost_inst%/
         input_FOM_cost(devices)                 "yearly FOM cost ($/MW-year)"                           /1 %input_FOM_cost_inst%/
         input_FOM_alt_cost(devices)             "yearly FOM cost for alternate option ($/MW-year)"      /1 %input_FOM_alt_cst_inst%/
         output_FOM_cost(devices)                "yearly FOM cost ($/MW-year)"                           /1 %output_FOM_cost_inst%/
         renew_VOM_cost(devices_ren)             "VOM cost ($/MWh)"                                      /1 %renew_VOM_cost_inst%/
         input_VOM_cost(devices)                 "VOM cost ($/MWh)"                                      /1 %input_VOM_cost_inst%/
         output_VOM_cost(devices)                "VOM cost ($/MWh)"                                      /1 %output_VOM_cost_inst%/
         active_devices(devices)                 Value to set active devices                             /1 1/

         product_use(devices)                    "Determines if product is outputted or not (toggle)"    /1 %Product_use_instance%/
         product_price_adj(devices)              "Determines if price of outputted product"              /1 %Product_price_instance%/
         CF_adjust(devices)                      "Define CF for product (if CF_opt = 0)"                 /1 %CF_adj_inst%/

         energy_only(devices)                    "Sets different services for different devices"                 /1 %energy_only_instance%/
         baseload_operation(devices)             "Determines if input is operated with baseload duty cycle"      /1 %base_op_instance%/
         Renewable_MW(devices_ren)               "Installed renewable capacity (MW)"                             /1 %Renewable_MW_instance%/
         NG_price_adj                            "Average price of natural gas ($/MMBTU)"                        /%NG_price_adj_instance%/
         NBC                                     "NEM2 Non-bypassable charges ($/MWh) see tarrif sheet 2.c."     /%NBC_instance%/

         deprec_base_reduction                   "Fraction of the capital cost which serves as basis for depreciation"
         inflation_vec(years)                    "Inflation vector for revenues"
;


*===============================================================================
* Parameters for post-processing results
*===============================================================================
Parameters
         elec_in_MWh_vec(devices)              MWh of electricity bought over the simulated time period
         elec_output_MWh_vec(devices)          MWh of electricity sold over the simulated time period
         output_input_ratio_vec(devices)       ratio of elec output to elec output
         input_capacity_factor_vec(devices)    capacity factor for buying side of the facility
         output_capacity_factor_vec(devices)   capacity factor for the selling side of the facility
         avg_regup_MW_vec(devices)             average capacity sold to regup (MW per interval)
         avg_regdn_MW_vec(devices)             average capacity sold to regdn (MW per interval)
         avg_spinres_MW_vec(devices)           average capacity sold to spinning reserve (MW per interval)
         avg_nonspinres_MW_vec(devices)        average capacity sold to nonspinning reserve (MW per interval)

         num_input_starts_vec(devices)         number of compressor or input power system starts
         num_output_starts_vec(devices)        number of turbine or output power system starts

         fuel_cost_vec(devices)                cost of fuel (dollars)
         elec_cost_vec(devices)                cost of electricity (dollars)
         elec_cost_ren_vec(devices_ren)        market value of renewable electricity sold to the grid (dollars)
         VOM_cost_val_vec(devices)             cost of VOM (dollars)
         arbitrage_revenue_vec(devices)        operating profits due to electricity purchases and sales (dollars)
         regup_revenue_vec(devices)            operating profits due to regulation up AS market (dollars)
         regdn_revenue_vec(devices)            operating profits due to regulation down AS market (dollars)
         spinres_revenue_vec(devices)          operating profits due to spinning reserve AS market (dollars)
         nonspinres_revenue_vec(devices)       operating profits due to nonspinning reserve AS market (dollars)
         product_revenue_vec(devices)          operating profits due to selling product (dollars)
         product_sold_total(devices)           total product sold (units depend on product_conversion)
         REC_revenue_vec(devices_ren)          REC revenue ($)
         startup_costs_vec(devices)            cost due to startups
         actual_operating_profit_vec(devices)  actual operating profits (dollars)

         renew_cap_cost2_vec(devices_ren)      capital cost
         input_cap_cost2_vec(devices)          capital cost
         input_cap_cost2_alt_vec(devices)      capital cost alternative
         output_cap_cost2_vec(devices)         capital cost
         renew_FOM_cost2_vec(devices_ren)      FOM cost
         input_FOM_cost2_vec(devices)          FOM cost
         input_FOM_cost2_alt_vec(devices)      FOM cost alternative
         output_FOM_cost2_vec(devices)         FOM cost
         renew_VOM_cost2_vec(devices_ren)      VOM cost
         input_VOM_cost2_vec(devices)          VOM cost
         output_VOM_cost2_vec(devices)         VOM cost
         ProdStor_cap_cost2_vec(devices)       Product storage cost
         ProdComp_cap_cost2_vec(devices)       Product additional cost (compressor)
         renewable_sales_vec(devices_ren)      Revenue from renewables sales ($)
         curtailment_sum_vec(devices)          Sum of curtailment over the region

         Storage_revenue_vec(devices)          Track the storage revenue from the storage only (no renewable charging) ($)
         Renewable_only_revenue_vec(devices)   Track the revenue portion from renewables ($)
         Renewable_max_revenue_vec(devices_ren)    Calculate the maximum revenue from renewables without any storage installed ($)
         Renewable_electricity_in_vec(devices_ren) Calculate the amount of renewable electricity coming in for sale and storage (MWh)
         Input_elec_import_vec(devices)       Calculate the amount of imported electricity to the input devices (MWh)

         curtailment(interval)                 calculate renewable curtialment (MW)
         curtailment_vec(interval,devices_ren) calculate renewable curtialment (MW)
         storage_level_MWh_tot(interval,devices) combined renewable and non-renewable storage level

         LCFS_revenue_vec(devices)             Low Carbon Fuel Standard (LCFS) credit revenue ($)
         renewable_sales                       Revenue from renewables sales ($)
         Taxes                                 Taxes used for outputs ($)
         Debts                                 Debts used for outputs ($)
         input_cap_costPERprod                 Input capital cost per product sold
         input_FOM_costPERprod                 Input fixed operating cost per product sold
         LCFS_revenuePERprod                   Low Carbon Fuel Standard (LCFS) credit revenue per product sold
         Energy_chargePERprod                  Energy charge per product sold
         Fixed_demand_chargePERprod            Fixed demand charge per product sold
         Timed_demand_chargePERprod            Timed demand charge per product sold
         Meters_costPERprod                    Meter cost per product sold
         Storage_costPERprod                   Storage cost per product sold
         Compressor_costPERprod                Additional equipment cost per product sold
         TaxesPERprod                          Taxes per product sold
         DebtsPERprod                          Debts per product sold
         to_NPV(years)                         Value to convert to NPV
         product_revenue_years(years)          Product revenue for each year
         product_revenue_yearly2(years)        Product revenue for each year (second value used)
         Total_product_sold                    Calculate the total amount of product sold or produced
;

Scalars
         Renewable_cap_costPERprod             Renewable capital cost per prouduct ($ per prouduct)
         Renewable_FOM_costPERprod             Renewable FOM per prouduct ($ per prouduct)
         Renewable_revenuePERprod              Renewable revenue per prouduct ($ per prouduct)
         Renewable_cost                        Renewable total cost per prouduct ($ per prouduct)
         product_break_even_cost               Product break-even cost ($ per product)
         starttime                             track starttime
;
starttime = jnow;

* Load te electricity rate information
$include %indir%\Tariff_files\%elec_rate_instance%.txt

*===============================================================================
* Scalar used as tolerance for iterative approach
*===============================================================================
Scalar
         epsilon                 convergence tolerance between two iterations  /2/
;

Scalars
         interval_length         length of each interval (hours)                                                 /%int_length_instance%/
         optimization_length     number of intervals in entire analysis                                          /%op_length_instance%/
         operating_period_length number of intervals in each operating period (rolling solution window)          /%op_period_instance%/
*set operating period length to full year length (8760 or 8784) to do full-year optimization without rolling window
         look_ahead_length       number of additional intervals to look past the current operating period        /%lookahead_instance%/

         max_sys_output_cap      output capacity of entire system (MW)                                           /%max_output_cap_inst%/
         max_sys_input_cap       input capacity of entire system (MW)                                            /%max_input_cap_inst%/

         VOM_cost                "variable O&M cost associated with selling electricity ($/MWh)"                 /0/
         reg_cost                "variable costs associated with providing regulation ($/MW-h)"                  /%reg_cost_instance%/
         REC_price               "Renewable Energy Credits (RECs) ($/MWh)"                                       /%REC_price_inst%/

         product_conversion      "product unit conversion (e.g., H2 LHV 0.033322222 (MWh/kg), elec 1 (MWh/MWh)"  /%product_conv_inst%/

         CF_opt                  "Select optimization criteria for system"                                       /%CF_opt_instance%/
         run_retail              "Select to run retail or wholesale analysis (0=wholesale, 1=retail, 2=hybrid (retail for purchase and wholesale for sale))" /%run_retail_instance%/
         one_active_device       "Enables equation to ensure that charge/discharge do not happen simultaneously" /%one_active_device_inst%/

         min_output_on_intervals 'minimum number of intervals the output side of the facility can be on at a time' /%min_runtime_instance%/
         min_input_on_intervals  'minimum number of intervals the input side of the facility can be on at a time' /%min_runtime_instance%/

         current_interval        'current interval for real-time optimization runs'                              /%current_int_instance%/
         next_interval           'next interval for real-time optimization runs'                                 /%next_int_instance%/
         current_storage_lvl     'current storage level for real-time optimization runs (0-100%, 0-1)'           /%current_stor_instance%/
         current_monthly_max     'current monthly maximum demand for real-time optimization runs (0-100%, 0-1)'  /%current_max_instance%/
         max_interval            'maximum interval for real-time optimization runs'                              /%max_int_instance%/
         read_MPC_file           'read controller values from csv file'                                          /%read_MPC_file_instance%/
         ramp_penalty            'set ramp penalty for input and output devices'                                 /%ramp_penalty_instance%/
         allow_import            'Allows or restricts imports 0=no imports, 1=allows imports'                    /%allow_import_instance%/
         allow_sales             'Restricts sales if = 0'                                                        /%allow_sales_instance%/
         nominal_penalty         'Used to add penalty price that is not considered in the results'               /0.000001/
         price_cap               'Set price cap for input prices'                                                /%price_cap_instance%/

         EneDens                 "Energy density of fuel (e.g., H2 = 120 MJ/kg"                                  /%EneDens_inst%/
         EER                     "Energy economy ratio relative to alternative fuel"                             /%EER_inst%/
         Grid_CarbInt            "Carbon intensity of electricity from the grid (gCO2e/MJ)"                      /%Grid_CarbInt_inst%/
         CI_base_line            "Base line carbon intensity for the displaced fuel and current year (gCO2e/MJ)" /%CI_base_line_inst%/
         LCFS_price              "Low Carbon Fuel Standard (LCFS) credit prices ($ per credit)"                  /%LCFS_price_inst%/

         ITC                     "Business Energy Investment Tax Credit (ITC) (fraction between 0 and 1)"        /%ITC_inst%/
         wacc                    "Weighted average capital cost (wacc) [-]"                                      /%wacc_instance%/
         cftr                    "Combined federal and local taxes     [-]"                                      /%cftr_instance%/
         bonus_depreciation      "Bonus depreciation fraction [-]"                                               /%bonus_deprec_instance%/
         equity                  "Percent equity              [-]"                                               /%perc_equity_instance%/
         ror                     "Rate of return              [-]"                                               /%ror_instance%/
         roe                     "Rate of equity              [-]"                                               /%roe_instance%/
         debt_interest           "Debt interest rate          [-]"                                               /%debt_interest_instance%/
         inflation               "Rate of inflation           [-]"                                               /%inflation_inst%/

         CF_penalty              "Penalty value for violating fixed CF ($/% of CF)"                              /1000000/
         CF_incremental_change_value "Amount to adjust product_consumed if it causes infeasibilities"            /0.01/
         Storage_penalty         "Penalty value to force immediate charging (should be less than CF_penalty)"    /10000/
;

Sets
        next_int(interval)      Next interval           /%next_int_instance%/
        param_vals        Load device parameter names           /input_capacity_MW,  output_capacity_MW,
                                                                 storage_capacity_hours, storage_set_final, storage_init, storage_final,
                                                                 input_LSL_fraction, output_LSL_fraction,
                                                                 input_efficiency,   output_efficiency,
                                                                 input_heat_rate,    output_heat_rate,
                                                                 input_startup_cost, output_startup_cost,
                                                                 input_cap_cost,     output_cap_cost, ProdStor_cap_cost,      ProdComp_cap_cost,
                                                                 input_cap_alt_cost,
                                                                 input_FOM_cost,     output_FOM_cost,
                                                                 input_FOM_alt_cost,
                                                                 input_VOM_cost,     output_VOM_cost,
                                                                 product_use, product_price_adj, CF_adjust,
                                                                 energy_only, baseload_operation,
                                                                 active_devices/
         param_vals_ren    Load renewable device parameters     /renew_cap_cost, renew_FOM_cost, renew_VOM_cost, Renewable_MW/
;

Table Device_table(param_vals,devices_load)                   'Load all device parameters'
$ondelim
$include %indir%\%Device_parameters_inst%.csv
$offdelim
;
Table Device_ren_table(param_vals_ren,devices_ren_load)       'Load all renewable device parameters'
$ondelim
$include %indir%\%Device_ren_params_inst%.csv
$offdelim
;

* Adjust values either from batch file inputs or from loaded files
if (card(devices)>1 or card(devices_ren)>1,

* Input values from "Device_table" and "Device_ren_table"
         input_capacity_MW(devices)       = Device_table("input_capacity_MW",devices);
         output_capacity_MW(devices)      = Device_table("output_capacity_MW",devices);
         storage_capacity_hours(devices)  = Device_table("storage_capacity_hours",devices);
         storage_set_final(devices)       = Device_table("storage_set_final",devices);
         storage_init(devices)            = Device_table("storage_init",devices);
         storage_final(devices)           = Device_table("storage_final",devices);
         input_LSL_fraction(devices)      = Device_table("input_LSL_fraction",devices);
         output_LSL_fraction(devices)     = Device_table("output_LSL_fraction",devices);
         input_efficiency(devices)        = Device_table("input_efficiency",devices);
         output_efficiency(devices)       = Device_table("output_efficiency",devices);
         input_heat_rate(devices)         = Device_table("input_heat_rate",devices);
         output_heat_rate(devices)        = Device_table("output_heat_rate",devices);
         input_startup_cost(devices)      = Device_table("input_startup_cost",devices);
         output_startup_cost(devices)     = Device_table("output_startup_cost",devices);
         input_cap_cost(devices)          = Device_table("input_cap_cost",devices);
         input_cap_alt_cost(devices)      = Device_table("input_cap_alt_cost",devices);
         output_cap_cost(devices)         = Device_table("output_cap_cost",devices);
         ProdStor_cap_cost(devices)       = Device_table("ProdStor_cap_cost",devices);
         ProdComp_cap_cost(devices)       = Device_table("ProdComp_cap_cost",devices);
         input_FOM_cost(devices)          = Device_table("input_FOM_cost",devices);
         input_FOM_alt_cost(devices)      = Device_table("input_FOM_alt_cost",devices);
         output_FOM_cost(devices)         = Device_table("output_FOM_cost",devices);
         input_VOM_cost(devices)          = Device_table("input_VOM_cost",devices);
         output_VOM_cost(devices)         = Device_table("output_VOM_cost",devices);
         product_use(devices)             = Device_table("product_use",devices);
         product_price_adj(devices)       = Device_table("product_price_adj",devices);
         CF_adjust(devices)               = Device_table("CF_adjust",devices);
         energy_only(devices)             = Device_table("energy_only",devices);
         baseload_operation(devices)      = Device_table("baseload_operation",devices);
         active_devices(devices)          = Device_table("active_devices",devices);

         renew_cap_cost(devices_ren)      = Device_ren_table("renew_cap_cost",devices_ren);
         renew_FOM_cost(devices_ren)      = Device_ren_table("renew_FOM_cost",devices_ren);
         renew_VOM_cost(devices_ren)      = Device_ren_table("renew_VOM_cost",devices_ren);
         Renewable_MW(devices_ren)        = Device_ren_table("Renewable_MW",devices_ren);
);

if (%use_alt_devices%=1,
    active_devices(devices) = 0;
elseif %use_all_devices%=1,
    active_devices(devices) = 1;
);

* Load csv files for wholesale electricity price analysis (energy and AS)
$call CSV2GDX %indir%\%energy_purchase_price_inst%.csv Output=%indir%\%energy_purchase_price_inst%.gdx ID=elec_purchase_price_interim UseHeader=y Index=1 Values=2
parameter elec_purchase_price_interim(interval)   "electricity purchase price in each interval ($/MWh)"
$GDXIN %indir%\%energy_purchase_price_inst%.gdx
$LOAD elec_purchase_price_interim
$GDXIN
;
$call CSV2GDX %indir%\%energy_sale_price_inst%.csv Output=%indir%\%energy_sale_price_inst%.gdx ID=elec_sale_price_interim UseHeader=y Index=1 Values=2
parameter elec_sale_price_interim(interval)   "electricity sale price in each interval ($/MWh)"
$GDXIN %indir%\%energy_sale_price_inst%.gdx
$LOAD elec_sale_price_interim
$GDXIN
;
$call CSV2GDX %indir%\%product_price_prof_inst%.csv Output=%indir%\%product_price_prof_inst%.gdx ID=product_price2 UseHeader=y Index=1 Values=(2..LastCol)
parameter product_price2(interval,devices_load)   "Product sale price in each interval ($/units of product)"
$GDXIN %indir%\%product_price_prof_inst%.gdx
$LOAD product_price2
$GDXIN
;
$call CSV2GDX %indir%\Product_consumption\%product_consumed_inst%.csv Output=%indir%\Product_consumption\%product_consumed_inst%.gdx ID=product_consumed2 UseHeader=y Index=1 Values=(2..LastCol)
parameter product_consumed2(interval,devices_load)   "Profile of product consumption for each interval (units of product)"
$GDXIN %indir%\Product_consumption\%product_consumed_inst%.gdx
$LOAD product_consumed2
$GDXIN
;
$call CSV2GDX %indir%\%NG_price_instance%.csv Output=%indir%\%NG_price_instance%.gdx ID=NG_price UseHeader=y Index=1 Values=2
parameter NG_price(interval)   "Natural gas price in each interval ($/MMBtu)"
$GDXIN %indir%\%NG_price_instance%.gdx
$LOAD NG_price
$GDXIN
;
$call CSV2GDX %indir%\%load_prof_instance%.csv Output=%indir%\%load_prof_instance%.gdx ID=Load_profile UseHeader=y Index=1 Values=2
parameter Load_profile(interval)   "additional load profiles (MW)"
$GDXIN %indir%\%load_prof_instance%.gdx
$LOAD Load_profile
$GDXIN
;
$call CSV2GDX %indir%\%ren_prof_instance%.csv Output=%indir%\%ren_prof_instance%.gdx ID=renewable_signal2 UseHeader=y Index=1 Values=(2..LastCol)
parameter renewable_signal2(interval,devices_ren_load)   "normalized renewable production profiles (MW)"
$GDXIN %indir%\%ren_prof_instance%.gdx
$LOAD renewable_signal2
$GDXIN
;
$call CSV2GDX %indir%\%NSCR_instance%.csv Output=%indir%\%NSCR_instance%.gdx ID=NSCR UseHeader=y Index=1 Values=2
parameter NSCR(months)   "Net surplus compensation ($/MWh)"
$GDXIN %indir%\%NSCR_instance%.gdx
$LOAD NSCR
$GDXIN
;

$call CSV2GDX %indir%\Input_cap\%Max_input_prof_inst%.csv Output=%indir%\Input_cap\%Max_input_prof_inst%.gdx ID=Max_input_cap2 UseHeader=y Index=1 Values=(2..LastCol)
parameter Max_input_cap2(interval,devices_load)
$GDXIN %indir%\Input_cap\%Max_input_prof_inst%.gdx
$LOAD Max_input_cap2
$GDXIN
;
$call CSV2GDX %indir%\Output_cap\%Max_output_prof_inst%.csv Output=%indir%\Output_cap\%Max_output_prof_inst%.gdx ID=Max_output_cap2 UseHeader=y Index=1 Values=(2..LastCol)
parameter Max_output_cap2(interval,devices_load)
$GDXIN %indir%\Output_cap\%Max_output_prof_inst%.gdx
$LOAD Max_output_cap2
$GDXIN
;

$call CSV2GDX %indir%\%AS_price_inst%.csv Output=%indir%\%AS_price_inst%.gdx ID=regup_price_interim UseHeader=y Index=1 Values=2
parameter regup_price_interim(interval)
$GDXIN %indir%\%AS_price_inst%.gdx
$LOAD regup_price_interim
$GDXIN
;
$call CSV2GDX %indir%\%AS_price_inst%.csv Output=%indir%\%AS_price_inst%.gdx ID=regdn_price_interim UseHeader=y Index=1 Values=3
parameter regdn_price_interim(interval)
$GDXIN %indir%\%AS_price_inst%.gdx
$LOAD regdn_price_interim
$GDXIN
;
$call CSV2GDX %indir%\%AS_price_inst%.csv Output=%indir%\%AS_price_inst%.gdx ID=spinres_price_interim UseHeader=y Index=1 Values=4
parameter spinres_price_interim(interval)
$GDXIN %indir%\%AS_price_inst%.gdx
$LOAD spinres_price_interim
$GDXIN
;
$call CSV2GDX %indir%\%AS_price_inst%.csv Output=%indir%\%AS_price_inst%.gdx ID=nonspinres_price_interim UseHeader=y Index=1 Values=5
parameter nonspinres_price_interim(interval)
$GDXIN %indir%\%AS_price_inst%.gdx
$LOAD nonspinres_price_interim
$GDXIN
;
*===============================================================================
* COMPRESSOR'S COST
*===============================================================================
Set input_size_instances /s1*s22/;
$call CSV2GDX %indir%\Compressors_cost.csv Output=%indir%\Compressors_cost.gdx ID=ProdComp_cap_cost_s UseHeader=y Index=1 Values=3
Parameter ProdComp_cap_cost_s(*)
$GDXIN %indir%\Compressors_cost.gdx
$LOAD ProdComp_cap_cost_s
$GDXIN
;
$call CSV2GDX %indir%\Compressors_cost.csv Output=%indir%\Compressors_cost.gdx ID=input_sizes UseHeader=y Index=1 Values=2
Parameter  input_sizes(*)
$GDXIN %indir%\Compressors_cost.gdx
$LOAD input_sizes
$GDXIN
;
loop(devices,
         loop(input_size_instances,
                  if (input_capacity_MW(devices) = input_sizes(input_size_instances),
                     ProdComp_cap_cost(devices) = ProdComp_cap_cost_s(input_size_instances) ;
                  );
         );;
);;

*===============================================================================
* DEPRECIATION SCHEDULES
*===============================================================================
$call CSV2GDX %indir%\%MACRS_instance%.csv Output=%indir%\%MACRS_instance%.gdx ID=depreciation_schedule UseHeader=y Index=1 Values=2
parameter depreciation_schedule(years)
$GDXIN %indir%\%MACRS_instance%.gdx
$LOAD depreciation_schedule
$GDXIN
;
parameter  bonus_depreciation_schedule(years), NoYears;
* For accelerated depreciation, bonus depreciation can vary from 50% to up to 100%. In future, it will go to 0%
bonus_depreciation_schedule(years)$(ord(years)=1) = bonus_depreciation + (1-bonus_depreciation)*depreciation_schedule(years);
bonus_depreciation_schedule(years)$(ord(years)>1) = (1-bonus_depreciation)*depreciation_schedule(years);
* The basis for depreciation is directly calculated and is dependent of the Investment Tax Credit
deprec_base_reduction = 1 - 0.5*ITC   ;
* A scalar that takes the number of years considered in the optimization
NoYears = card(years);
inflation_vec(years) = (1 + inflation)**(ord(years)-1);
wacc =  (1 - equity)*(1 - debt_interest)*ror + equity*roe ;
to_NPV(years) = (wacc + 1)**(ord(years)) ;
*===============================================================================

product_price(interval,devices)         = product_price2(interval,devices);
product_consumed(interval,devices)      = product_consumed2(interval,devices);
renewable_signal(interval,devices_ren)  = renewable_signal2(interval,devices_ren);
Max_input_cap(interval,devices)         = Max_input_cap2(interval,devices);
Max_output_cap(interval,devices)        = Max_output_cap2(interval,devices);

Parameter   product_price_init(interval,devices) ;
product_price_init(interval,devices) =  product_price(interval,devices) ;

if (run_retail=0,
         elec_purchase_price(interval) = elec_purchase_price_interim(interval);
         elec_sale_price(interval)     = elec_sale_price_interim(interval);
         regup_price(interval)         = regup_price_interim(interval);
         regdn_price(interval)         = regdn_price_interim(interval);
         spinres_price(interval)       = spinres_price_interim(interval);
         nonspinres_price(interval)    = nonspinres_price_interim(interval);
         meter_mnth_chg(interval)      = meter_mnth_chg(interval) * 0;
         Fixed_dem(months)             = Fixed_dem(months) * 0;
         Timed_dem(timed_dem_period)   = Timed_dem(timed_dem_period) * 0;
         TOU_energy_prices(TOU_energy_period) = TOU_energy_prices(TOU_energy_period) * 0;
elseif run_retail=2,
         elec_sale_price(interval)     = elec_sale_price_interim(interval);
         regup_price(interval)         = regup_price_interim(interval);
         regdn_price(interval)         = regdn_price_interim(interval);
         spinres_price(interval)       = spinres_price_interim(interval);
         nonspinres_price(interval)    = nonspinres_price_interim(interval);
elseif (run_retail=1 and %NEM_nscr%=1),
         REC_price                     = 0;
         elec_sale_price(interval)     = elec_sale_price_interim(interval);
elseif run_retail=1,
         REC_price                     = 0;
         elec_sale_price(interval)     = elec_sale_price_interim(interval) * 0;
);

* Loads predictive controller values from csv file
$call CSV2GDX %indir%\controller_input_values.csv Output=%indir%\controller_input_values.gdx ID=current_interval2 UseHeader=y Values=1
scalar current_interval2
$GDXIN %indir%\controller_input_values.gdx
$LOAD current_interval2
$GDXIN
;
$call CSV2GDX %indir%\controller_input_values.csv Output=%indir%\controller_input_values.gdx ID=next_interval2 UseHeader=y Values=2
scalar next_interval2
$GDXIN %indir%\controller_input_values.gdx
$LOAD next_interval2
$GDXIN
;
$call CSV2GDX %indir%\controller_input_values.csv Output=%indir%\controller_input_values.gdx ID=current_storage_lvl2 UseHeader=y Values=3
scalar current_storage_lvl2
$GDXIN %indir%\controller_input_values.gdx
$LOAD current_storage_lvl2
$GDXIN
;
$call CSV2GDX %indir%\controller_input_values.csv Output=%indir%\controller_input_values.gdx ID=current_monthly_max2 UseHeader=y Values=4
scalar current_monthly_max2
$GDXIN %indir%\controller_input_values.gdx
$LOAD current_monthly_max2
$GDXIN
;
$call CSV2GDX %indir%\controller_input_values.csv Output=%indir%\controller_input_values.gdx ID=max_interval2 UseHeader=y Values=5
scalar max_interval2
$GDXIN %indir%\controller_input_values.gdx
$LOAD max_interval2
$GDXIN
;

if (read_MPC_file=1,
         current_interval    = current_interval2;
         next_interval       = next_interval2;
         current_storage_lvl = current_storage_lvl2;
         current_monthly_max = current_monthly_max2;
         max_interval        = max_interval2;
);

* Remove all GDX files after loading data
$call rm -rf %indir%\*.gdx
$call rm -rf %indir%\Product_consumption\*.gdx
$call rm -rf %indir%\Input_cap\*.gdx
$call rm -rf %indir%\Output_cap\*.gdx

*reseed the random number generator
execseed = 1 + gmillisec(jnow);
*generate an imperfect price forecast
*elec_price_forecast(interval) = elec_price(interval) * uniform(0.95, 1.05);

* Limit purchase and sale prices to the price_cap value and add nominal penalty if purchase price is set equal to sale price to avoid unrealistic behavior
elec_sale_price(interval) = (price_cap+elec_sale_price(interval)-ABS(elec_sale_price(interval)-price_cap))/2;
elec_purchase_price(interval) = (price_cap+elec_purchase_price(interval)-ABS(elec_purchase_price(interval)-price_cap))/2;
elec_sale_price_forecast(interval) = elec_sale_price(interval);
if (sum(interval,elec_purchase_price(interval))=sum(interval,elec_sale_price(interval)),
    elec_purchase_price_forecast(interval) = elec_purchase_price(interval)+nominal_penalty;
else
    elec_purchase_price_forecast(interval) = elec_purchase_price(interval);
);

* Scale renewable signal to desired installed capacity level
Renewable_power(interval,devices_ren) = renewable_signal(interval,devices_ren) * Renewable_MW(devices_ren);

* Adjust the properties appropriately if it is equal to zero and zero the cost components (i.e., raising to the power of 0 or dividing by zero throws an error)
loop(devices,
         if (output_capacity_MW(devices)=0,          output_efficiency(devices)=1);
);

*check to make sure operating period length is not longer than the number of intervals in the input file
if ( operating_period_length > card(interval), operating_period_length = card(interval) );

*set values for allowable AS capacities
loop(devices,
    if (energy_only(devices)=1,
         output_regup_limit_fraction(devices)      = 0;
         output_regdn_limit_fraction(devices)      = 0;
         output_spinres_limit_fraction(devices)    = 0;
         output_nonspinres_limit_fraction(devices) = 0;

         input_regup_limit_fraction(devices)       = 0;
         input_regdn_limit_fraction(devices)       = 0;
         input_spinres_limit_fraction(devices)     = 0;
         input_nonspinres_limit_fraction(devices)  = 0;
    elseif baseload_operation(devices)=1,
         output_regup_limit_fraction(devices)      = 1;
         output_regdn_limit_fraction(devices)      = 1;
         output_spinres_limit_fraction(devices)    = 1;
         output_nonspinres_limit_fraction(devices) = 1;

         input_regup_limit_fraction(devices)       = 0;
         input_regdn_limit_fraction(devices)       = 0;
         input_spinres_limit_fraction(devices)     = 0;
         input_nonspinres_limit_fraction(devices)  = 0;
    else
         output_regup_limit_fraction(devices)      = 1;
         output_regdn_limit_fraction(devices)      = 1;
         output_spinres_limit_fraction(devices)    = 1;
         output_nonspinres_limit_fraction(devices) = 1;

         input_regup_limit_fraction(devices)       = 1;
         input_regdn_limit_fraction(devices)       = 1;
         input_spinres_limit_fraction(devices)     = 1;
         input_nonspinres_limit_fraction(devices)  = 1;
    );
);

*scalars for rolling window implementation
*note that the rolling window is the current operating period plus a look-ahead
*period to give residual value to stored energy at the end of the current
*operating period
Scalars
         number_of_solves                number of times the model will be solved after moving the solve window
         solve_index                     index used to loop through all of the solves
         operating_period_min_index      value of first index in current operating period
         operating_period_max_index      value of last index in current operating period
         rolling_window_min_index        value of first index in current rolling window
         rolling_window_max_index        value of last index in current rolling window
         big_M                           big number for linearisation of net surplus electricity compensation constraints /5000/
         big_Mtaxes                      big number for taxes linearization                                              /30000000/
         small_M                         small number for linearization of net surplus electricity compensation constraints /0.05/
;

Positive Variables
         output_power_MW(interval,devices)       output capacity actually supplying power to the grid (MW)
         output_regup_MW(interval,devices)       output capacity committed for regulation up ancillary service (MW)
         output_regdn_MW(interval,devices)       output capacity committed for regulation down ancillary service (MW)
         output_spinres_MW(interval,devices)     output capacity committed for spinning reserve ancillary service (MW)
         output_nonspinres_MW(interval,devices)  output capacity committed for nonspinning reserve ancillary service (MW)
         renewable_power_MW_sold(interval,devices_ren) actual amount of renewable generation sold (MWh)
         output_power_MW_ren_sold(interval,devices) renewable output power sold to the grid (MW)
         output_power_MW_ren_load(interval,devices) renewable output power used on site (MW)
         output_power_MW_non_ren_sold(interval,devices) non-renewable output power sold to the grid (MW)
         output_power_MW_non_ren_load(interval,devices) non-renewable output power used on site (MW)

         input_power_MW(interval,devices)        input capacity actually buying power from the grid (MW)
         input_regup_MW(interval,devices)        input capacity committed for regulation up ancillary service (MW)
         input_regdn_MW(interval,devices)        input capacity committed for regulation down ancillary service (MW)
         input_spinres_MW(interval,devices)      input capacity committed for spinning reserve ancillary service (MW)
         input_nonspinres_MW(interval,devices)   input capacity committed for nonspinning reserve ancillary service (MW)
         input_power_MW_ren(interval,devices)    actual amount of renewable generation used (MWh)
         input_power_MW_non_ren(interval,devices)  actual amount of non renewable generation used (MWh)

         storage_level_MWh(interval,devices)     amount of non-renewable energy stored at the end of each interval (MWh)
         storage_level_MWh_ren(interval,devices) amount of renewable energy stored at the end of each interval (MWh)

         product_sold(interval,devices)          Determines how much product is sold
         product_sold_non_ren(interval,devices)  Determines how much non-renewable product is sold
         product_sold_ren(interval,devices)      Determines how much renewable product is sold
         product_sold_daily(days,devices)        Represents how much product is sold each day

         Fixed_cap(months)       Sets peak capacity for the fixed demand charges (MW)
         cap_1(months)           Sets max capacity for the month (MW)
         cap_2(months)           Sets max capacity for the month (MW)
         cap_3(months)           Sets max capacity for the month (MW)
         cap_4(months)           Sets max capacity for the month (MW)
         cap_5(months)           Sets max capacity for the month (MW)
         cap_6(months)           Sets max capacity for the month (MW)

         product_fraction        Sets the optimal capacity factor

         input_ramp_pos(interval,devices)  Positive ramp rate constraint (used to linearize absolute value)
         input_ramp_neg(interval,devices)  Negative ramp rate constraint (used to linearize absolute value)
         output_ramp_pos(interval,devices) Positive ramp rate constraint (used to linearize absolute value)
         output_ramp_neg(interval,devices) Negative ramp rate constraint (used to linearize absolute value)

         Import_elec_profile(interval)     "Imported electricity"
         Load_profile_non_ren(interval)    Track non-renewable electricity used to meet the load profile (MW)
         Load_profile_ren(interval)        Track renewable electricity used to meet the load profile (MW)

         electricity_surplus(months,TOU_energy_period) "net electricity surplus (MWh)"

         amount_depreciated(years)      the total yearly depreciated amount based on MACRS schedule ($)
         debt_service                   yearly loan which is paid as debt to the bank assuming equal installments ($)
         reserved_taxes(years)           offset liabilities amount due to depreciation ($)
;

Negative Variables
         yearly_taxes(years)             the yearly taxes ($);

Binary Variables
         output_active(interval,devices) binary variable indicating if the output system is active or available for services
         input_active(interval,devices)  binary variable indicating if the input system is active or available for services

         output_start(interval,devices)  binary variable indicating if the output system started up in this interval
         input_start(interval,devices)   binary variable indicating if the input system started up in this interval

         esurplus_active(months,TOU_energy_period) binary variable which is active when the produced electricity exceeds the purchased electricity
         taxes_active(years)             binary variable which is active when there are taxes
;

Integer Variables
         CF_incremental_change(devices)  Integer variable to make fixd CF a soft constraint to avoid infeasibilities
;

Variables

         yearly_operating_profit         operating profit not considering capital investments ($)
         operating_profit               "net profit or loss from operations, before paying for capital costs ($)"
;

Equations
         operating_profit_eqn equation that sums the operating profits for the storage facility

         depreciation(years)  equation that determines the amount of capital cost which is depreciated
         taxes_lin1           linearization equation for expressing taxes
         taxes_lin2           linearization equation for expressing taxes
         taxes_lin3           linearization equation for expressing taxes
         taxes_lin4           linearization equation for expressing taxes
         taxes_lin5           linearization equation for expressing taxes
         reserved_taxes_eqn(years)   equation which determines what amount of offsetting liabilities is rolled over to next year
         yearly_operating_profit_eqn equation which determines one year of operating profit assuming identical operating profiles among years
         debt_service_eqn            equation which determines the dept installment in a year assuming identical installements each year

         lin1 linearization equation for expressing net surplus
         lin2 linearization equation for expressing net surplus
         lin3 linearization equation for expressing net surplus
         lin4 linearization equation for expressing net surplus
         lin5 linearization equation for expressing net surplus

         output_pwr_eqn2(interval,devices)               equation that defines the relationship between renewable and non-renewable output power
         output_LSL_eqn(interval,devices)                equation that limits the lower sustainable limit for the output of the facility
         output_capacity_limit_eqn(interval,devices)     equation that limits the upper limit for the output of the facility
         output_regup_limit_eqn(interval,devices)        equation that limits the amount of regulation up the output side of the facilty can offer
         output_regdn_limit_eqn(interval,devices)        equation that limits the amount of regulation down the output side of the facilty can offer
         output_spinres_limit_eqn(interval,devices)      equation that limits the amount of spinning reserve the output side of the facilty can offer
         output_nonspinres_limit_eqn(interval,devices)   equation that limits the amount of nonspinning reserve the output side of the facility can offer

         input_pwr_eqn(interval,devices)                 equation that defines the input power for baseload operation
         input_pwr_eqn2(interval,devices)                equation that defines the relationship between renewable and non-renewable input power
         input_LSL_eqn(interval,devices)                 equation that limits the lower sustainable limit for the input of the facility
         input_capacity_limit_eqn(interval,devices)      equation that limits the upper limit for the input of the facility for which there is an output device
         input_capacity_limit_eqn2(interval)             equation that defines the relationship between load_profile and non-renewable input power
         input_capacity_limit_eqn4(interval,devices)     equation that limits the upper limit for the input of the facility for which there is not an output device
         input_ren_contribution(interval)                equation that sets the amount of renewable gen consumed
         input_regup_limit_eqn(interval,devices)         equation that limits the amount of regulation up the input side of the facilty can offer
         input_regdn_limit_eqn(interval,devices)         equation that limits the amount of regulation down the input side of the facilty can offer
         input_spinres_limit_eqn(interval,devices)       equation that limits the amount of spinning reserve the input side of the facilty can offer
         input_nonspinres_limit_eqn(interval,devices)    equation that limits the amount of nonspinning reserve the input side of the facility can offer

         storage_level_accounting_init_eqn(interval,devices)     equation that sets the initial storage level as full
         storage_level_accounting_final_eqn(interval,devices)    equation that sets the final storage level as the same as the initial
         storage_level_accounting_eqn(interval,devices)  equation that keeps track of how much energy is in storage on an output power basis for storage or pump technologies (MWh)
         storage_level_accounting_eqn2(interval,devices) equation that keeps track of how much energy is in storage on an output power basis for generation only technologies (MWh)
         storage_level_accounting_eqn3(interval,devices) equation that keeps track of the renewable content in the storage tank (MWh)
         storage_level_limit_eqn(interval,devices)       equation that limits the storage level to the maximum capacity of the storage facility including ancillary services (MWh)
         storage_level_limit_eqn2(interval,devices)      equation that limits the storage level to the maximum capacity of the storage facility including ancillary services (MWh)
         storage_level_limit_eqn3(interval,devices)      equation that limits the storage level to the maximum capacity of the storage facility including ancillary services (MWh)

         load_profile_eqn(interval)                      equation that keeps track of the split between renewable and non-renewable power that goes to meet the load demand

         output_startup_eqn(interval,devices)            equation that determines if the output side of the facility started up
         input_startup_eqn(interval,devices)             equation that determines if the input side of the facility started up

         product_output_limit_eqn(days,devices)          equation that calculates the daily product consumed from the hourly production vector
         product_output_limit_eqn2(days,devices)         equation that limits the maximum product production per day
         product_output_limit_eqn3(interval,devices)     equation that ensures the product_sold = product_consumed
         product_renewable_eqn(interval,devices)         equation to determine how much of the product sold is renewable

         output_min_on_eqn1(interval,devices) equation that requires that if the output unit turns off during the first few intervals of the year it must stay on for all of the previous intervals
         output_min_on_eqn2(interval,devices) equation that enforces minimum on-time for most of the intervals of the year
         output_min_on_eqn3(interval,devices) equation that enforces minimum on-time for the ending intervals of the year
         input_min_on_eqn1(interval,devices)  equation that requires that if the input unit turns off during the first few intervals of the year it must stay on for all of the previous intervals
         input_min_on_eqn2(interval,devices)  equation that enforces minimum on-time for most of the intervals of the year
         input_min_on_eqn3(interval,devices)  equation that enforces minimum on-time for the ending intervals of the year

         Fixed_dem_Jan(Month_Jan)     equation that enforces fixed demand charge in given month
         Fixed_dem_Feb(Month_Feb)     equation that enforces fixed demand charge in given month
         Fixed_dem_Mar(Month_Mar)     equation that enforces fixed demand charge in given month
         Fixed_dem_Apr(Month_Apr)     equation that enforces fixed demand charge in given month
         Fixed_dem_May(Month_May)     equation that enforces fixed demand charge in given month
         Fixed_dem_Jun(Month_Jun)     equation that enforces fixed demand charge in given month
         Fixed_dem_Jul(Month_Jul)     equation that enforces fixed demand charge in given month
         Fixed_dem_Aug(Month_Aug)     equation that enforces fixed demand charge in given month
         Fixed_dem_Sep(Month_Sep)     equation that enforces fixed demand charge in given month
         Fixed_dem_Oct(Month_Oct)     equation that enforces fixed demand charge in given month
         Fixed_dem_Nov(Month_Nov)     equation that enforces fixed demand charge in given month
         Fixed_dem_Dec(Month_Dec)     equation that enforces fixed demand charge in given month

         Jan_1_eqn(Jan_1)       equation that enforces timed demand charge in given month
         Feb_1_eqn(Feb_1)       equation that enforces timed demand charge in given month
         Mar_1_eqn(Mar_1)       equation that enforces timed demand charge in given month
         Apr_1_eqn(Apr_1)       equation that enforces timed demand charge in given month
         May_1_eqn(May_1)       equation that enforces timed demand charge in given month
         Jun_1_eqn(Jun_1)       equation that enforces timed demand charge in given month
         Jul_1_eqn(Jul_1)       equation that enforces timed demand charge in given month
         Aug_1_eqn(Aug_1)       equation that enforces timed demand charge in given month
         Sep_1_eqn(Sep_1)       equation that enforces timed demand charge in given month
         Oct_1_eqn(Oct_1)       equation that enforces timed demand charge in given month
         Nov_1_eqn(Nov_1)       equation that enforces timed demand charge in given month
         Dec_1_eqn(Dec_1)       equation that enforces timed demand charge in given month

         Jan_2_eqn(Jan_2)       equation that enforces timed demand charge in given month
         Feb_2_eqn(Feb_2)       equation that enforces timed demand charge in given month
         Mar_2_eqn(Mar_2)       equation that enforces timed demand charge in given month
         Apr_2_eqn(Apr_2)       equation that enforces timed demand charge in given month
         May_2_eqn(May_2)       equation that enforces timed demand charge in given month
         Jun_2_eqn(Jun_2)       equation that enforces timed demand charge in given month
         Jul_2_eqn(Jul_2)       equation that enforces timed demand charge in given month
         Aug_2_eqn(Aug_2)       equation that enforces timed demand charge in given month
         Sep_2_eqn(Sep_2)       equation that enforces timed demand charge in given month
         Oct_2_eqn(Oct_2)       equation that enforces timed demand charge in given month
         Nov_2_eqn(Nov_2)       equation that enforces timed demand charge in given month
         Dec_2_eqn(Dec_2)       equation that enforces timed demand charge in given month

         Jan_3_eqn(Jan_3)       equation that enforces timed demand charge in given month
         Feb_3_eqn(Feb_3)       equation that enforces timed demand charge in given month
         Mar_3_eqn(Mar_3)       equation that enforces timed demand charge in given month
         Apr_3_eqn(Apr_3)       equation that enforces timed demand charge in given month
         May_3_eqn(May_3)       equation that enforces timed demand charge in given month
         Jun_3_eqn(Jun_3)       equation that enforces timed demand charge in given month
         Jul_3_eqn(Jul_3)       equation that enforces timed demand charge in given month
         Aug_3_eqn(Aug_3)       equation that enforces timed demand charge in given month
         Sep_3_eqn(Sep_3)       equation that enforces timed demand charge in given month
         Oct_3_eqn(Oct_3)       equation that enforces timed demand charge in given month
         Nov_3_eqn(Nov_3)       equation that enforces timed demand charge in given month
         Dec_3_eqn(Dec_3)       equation that enforces timed demand charge in given month

         Jan_4_eqn(Jan_4)       equation that enforces timed demand charge in given month
         Feb_4_eqn(Feb_4)       equation that enforces timed demand charge in given month
         Mar_4_eqn(Mar_4)       equation that enforces timed demand charge in given month
         Apr_4_eqn(Apr_4)       equation that enforces timed demand charge in given month
         May_4_eqn(May_4)       equation that enforces timed demand charge in given month
         Jun_4_eqn(Jun_4)       equation that enforces timed demand charge in given month
         Jul_4_eqn(Jul_4)       equation that enforces timed demand charge in given month
         Aug_4_eqn(Aug_4)       equation that enforces timed demand charge in given month
         Sep_4_eqn(Sep_4)       equation that enforces timed demand charge in given month
         Oct_4_eqn(Oct_4)       equation that enforces timed demand charge in given month
         Nov_4_eqn(Nov_4)       equation that enforces timed demand charge in given month
         Dec_4_eqn(Dec_4)       equation that enforces timed demand charge in given month

         Jan_5_eqn(Jan_5)       equation that enforces timed demand charge in given month
         Feb_5_eqn(Feb_5)       equation that enforces timed demand charge in given month
         Mar_5_eqn(Mar_5)       equation that enforces timed demand charge in given month
         Apr_5_eqn(Apr_5)       equation that enforces timed demand charge in given month
         May_5_eqn(May_5)       equation that enforces timed demand charge in given month
         Jun_5_eqn(Jun_5)       equation that enforces timed demand charge in given month
         Jul_5_eqn(Jul_5)       equation that enforces timed demand charge in given month
         Aug_5_eqn(Aug_5)       equation that enforces timed demand charge in given month
         Sep_5_eqn(Sep_5)       equation that enforces timed demand charge in given month
         Oct_5_eqn(Oct_5)       equation that enforces timed demand charge in given month
         Nov_5_eqn(Nov_5)       equation that enforces timed demand charge in given month
         Dec_5_eqn(Dec_5)       equation that enforces timed demand charge in given month

         Jan_6_eqn(Jan_6)       equation that enforces timed demand charge in given month
         Feb_6_eqn(Feb_6)       equation that enforces timed demand charge in given month
         Mar_6_eqn(Mar_6)       equation that enforces timed demand charge in given month
         Apr_6_eqn(Apr_6)       equation that enforces timed demand charge in given month
         May_6_eqn(May_6)       equation that enforces timed demand charge in given month
         Jun_6_eqn(Jun_6)       equation that enforces timed demand charge in given month
         Jul_6_eqn(Jul_6)       equation that enforces timed demand charge in given month
         Aug_6_eqn(Aug_6)       equation that enforces timed demand charge in given month
         Sep_6_eqn(Sep_6)       equation that enforces timed demand charge in given month
         Oct_6_eqn(Oct_6)       equation that enforces timed demand charge in given month
         Nov_6_eqn(Nov_6)       equation that enforces timed demand charge in given month
         Dec_6_eqn(Dec_6)       equation that enforces timed demand charge in given month

         product_CF_eqn(interval,devices) equation to adjust the CF for equipment required to make product
         product_CF_eqn2                 limit product_fraction
         product_CF_eqn3                 limit product_fraction

         RT_eqn1(interval,devices)       equation to set current power values to enable running in real-time
         RT_eqn2(interval,devices)       equation to set current storage values to enable running in real-time
         RT_eqn3(interval,devices)       equation to set power values to shorten running in real-time
         RT_eqn4(interval,devices)       equation to set storage values to shorten running in real-time

         output_ramp_eqn(interval,devices)       equation to limit ramping with penalty price
         input_ramp_eqn(interval,devices)        equation to limit ramping with penalty price

         system_power_eqn(interval)              "sets the maximum system output power level (e.g., inverter size for solar+storage)"
         system_power_eqn2(interval)             "sets the maximum system non-renewable input power level"
         one_active_device_eqn(interval,devices) equation to ensure that both generator and pump cannot be simultaneously active
         device_num_eqn                          limit the number of devices to a specified number
;

* Adjusts the price of natural gas to the selected value "NG_price_adj"
NG_price(interval) = NG_price(interval) * NG_price_adj;

* Check to see if products will be exported for this analysis (i.e., product_use = 1 or 2)
loop(devices,
    if (product_use(devices) = 0,
         product_consumed(interval,devices) = product_consumed(interval,devices) * 0;
         product_price(interval,devices)    = product_price(interval,devices)*0;
    elseif product_use(devices)=1,
         product_price(interval,devices) = product_price(interval,devices) * product_price_adj(devices);
         if (CF_opt=0,
                 product_consumed(interval,devices) = product_consumed(interval,devices) * CF_adjust(devices) * input_capacity_MW(devices) * input_efficiency(devices) / product_conversion * interval_length;
         elseif CF_opt=1,
                 CF_adjust(devices) = input_capacity_MW(devices) * input_efficiency(devices) / product_conversion;
         );
    elseif product_use(devices)=2,
    );
);

product_CF_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and CF_opt=1)..
         product_sold(interval,devices) =e= product_consumed(interval,devices) * CF_adjust(devices) * product_fraction;

product_CF_eqn2$(CF_opt=1).. product_fraction =l= 1;
product_CF_eqn3$(CF_opt=0).. product_fraction =e= 1;

*** Cost function: Elec sale price, elec purchase price, regup, regdown, spin, nonspin, NGout/in, unused VOM cost, startup cost, H2 price, VOM cost, demand charge (fixed and timed), meter cost, cap and FOM cost, etc.

operating_profit_eqn..

              operating_profit =e=

                 - sum(devices_ren, equity * renew_cap_cost(devices_ren) * Renewable_MW(devices_ren))
                 - sum(devices, equity * input_cap_cost(devices)    * input_capacity_MW(devices)  * active_devices(devices))
                 - sum(devices, equity * output_cap_cost(devices)   * output_capacity_MW(devices) * active_devices(devices))
                 - sum(devices, equity * ProdStor_cap_cost(devices) * input_capacity_MW(devices)  * active_devices(devices) * ( input_efficiency(devices) / product_conversion )*storage_capacity_hours(devices))
                 - sum(devices, equity * ProdComp_cap_cost(devices) * input_capacity_MW(devices)  * active_devices(devices) * ( input_efficiency(devices) / product_conversion ))
                 - sum(devices, equity * input_cap_alt_cost(devices)* input_capacity_MW(devices)  * (1-active_devices(devices)))
                 + sum(years,[yearly_taxes(years)
                 - debt_service
                 + inflation_vec(years)*yearly_operating_profit]/to_NPV(years))
;

depreciation(years)..
amount_depreciated(years) =e= deprec_base_reduction*bonus_depreciation_schedule(years)*[sum(devices_ren, renew_cap_cost(devices_ren) * Renewable_MW(devices_ren))
                            + sum(devices, input_cap_cost(devices) * input_capacity_MW(devices) * active_devices(devices) + input_cap_alt_cost(devices) * input_capacity_MW(devices) * (1-active_devices(devices)) + output_cap_cost(devices) * output_capacity_MW(devices) * active_devices(devices))]
                            + depreciation_schedule(years)*[sum(devices, ProdStor_cap_cost(devices) * input_capacity_MW(devices) * active_devices(devices) *( input_efficiency(devices) / product_conversion )*storage_capacity_hours(devices))
                            + sum(devices, ProdComp_cap_cost(devices) * input_capacity_MW(devices) * active_devices(devices) *( input_efficiency(devices) / product_conversion ))];

yearly_operating_profit_eqn..
         yearly_operating_profit =e= sum( (interval)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ),
                   (elec_sale_price_forecast(interval) * (sum(devices,output_power_MW_ren_sold(interval,devices)+output_power_MW_non_ren_sold(interval,devices))+sum(devices_ren,renewable_power_MW_sold(interval,devices_ren))) * interval_length)*(1-%NEM_nscr%)
                 + REC_price * (sum(devices_ren,renewable_power_MW_sold(interval,devices_ren)) + sum(devices,output_power_MW_ren_sold(interval,devices))) * interval_length
                 - (elec_purchase_price_forecast(interval) * Import_elec_profile(interval) * interval_length)*(1-%NEM_nscr%)
                 + ( regup_price(interval) - reg_cost ) * ( sum(devices,output_regup_MW(interval,devices) + input_regup_MW(interval,devices)) ) * interval_length
                 + ( regdn_price(interval) - reg_cost ) * ( sum(devices,output_regdn_MW(interval,devices) + input_regdn_MW(interval,devices)) ) * interval_length
                 + spinres_price(interval) * ( sum(devices,output_spinres_MW(interval,devices) + input_spinres_MW(interval,devices)) ) * interval_length
                 + nonspinres_price(interval) * ( sum(devices,output_nonspinres_MW(interval,devices) + input_nonspinres_MW(interval,devices)) ) * interval_length
                 - sum(devices,output_heat_rate(devices) * NG_price(interval) * output_power_MW(interval,devices)) * interval_length
                 - sum(devices,input_heat_rate(devices) * NG_price(interval) * input_power_MW(interval,devices)) * interval_length
                 - VOM_cost * sum(devices,output_power_MW(interval,devices)) * interval_length
                 - sum(devices,output_startup_cost(devices) * output_capacity_MW(devices) * output_start(interval,devices))
                 - sum(devices,input_startup_cost(devices) * input_capacity_MW(devices) * input_start(interval,devices))
                 + sum(devices,product_price(interval,devices) * product_sold(interval,devices))
                 + sum(devices,(CI_base_line*EER - Grid_CarbInt/input_efficiency(devices))*LCFS_price*EneDens*(power(10,-6)) * product_sold(interval,devices))
                 + sum(devices,Grid_CarbInt*LCFS_price*EneDens*(power(10,-6)) * product_sold_ren(interval,devices))
                 - sum(devices_ren,renew_VOM_cost(devices_ren) * Renewable_power(interval,devices_ren))* interval_length
                 - sum(devices,input_VOM_cost(devices) * input_power_MW(interval,devices)) * interval_length
                 - sum(devices,output_VOM_cost(devices)* output_power_MW(interval,devices))* interval_length
                 - sum(devices,(input_ramp_pos(interval,devices)+input_ramp_neg(interval,devices))*ramp_penalty)
                 - sum(devices,(output_ramp_pos(interval,devices)+output_ramp_neg(interval,devices))*ramp_penalty))
                 - sum(months, Fixed_cap(months) * Fixed_dem(months))
                 - sum(months, cap_1(months) * Timed_dem("1"))
                 - sum(months, cap_2(months) * Timed_dem("2"))
                 - sum(months, cap_3(months) * Timed_dem("3"))
                 - sum(months, cap_4(months) * Timed_dem("4"))
                 - sum(months, cap_5(months) * Timed_dem("5"))
                 - sum(months, cap_6(months) * Timed_dem("6"))
                 - meter_mnth_chg("1") * 12
                 - sum(devices_ren,renew_FOM_cost(devices_ren) * Renewable_MW(devices_ren))
                 - sum(devices,input_FOM_cost(devices) * input_capacity_MW(devices) * active_devices(devices))
                 - sum(devices,input_FOM_alt_cost(devices) * input_capacity_MW(devices) * (1-active_devices(devices)))
                 - sum(devices,output_FOM_cost(devices)* output_capacity_MW(devices) * active_devices(devices))
                 + sum((months,TOU_energy_period),(NSCR(months)-TOU_energy_prices(TOU_energy_period)-NBC)*electricity_surplus(months,TOU_energy_period))*(%NEM_nscr%)
                 + sum((months,TOU_energy_period),(TOU_energy_prices(TOU_energy_period))*[sum(interval$(month_interval(months,interval) and elec_TOU_bins(TOU_energy_period,interval) and rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index),
                   interval_length*(sum(devices_ren,renewable_power_MW_sold(interval,devices_ren))+sum(devices,output_power_MW(interval,devices))-Import_elec_profile(interval)))])*(%NEM_nscr%)
                 - sum(devices, CF_incremental_change(devices))*CF_penalty
* Added the following item to penalize smart charging and force the system to perform immediate charging
                 + sum( (interval)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ),
                   sum(devices, storage_level_MWh(interval,devices)) ) * Storage_penalty * (1-%use_smart_charging%)
;

* Taxes include an ITC offset for renewables, input devices and output devices (change as necessary for specific technologies).
taxes_lin1(years)..
                  - cftr*(yearly_operating_profit*inflation_vec(years) - amount_depreciated(years))
                  + reserved_taxes(years-1)
                  + ITC*deprec_base_reduction*[sum(devices_ren, renew_cap_cost(devices_ren) * Renewable_MW(devices_ren))
                  + sum(devices, input_cap_cost(devices) * input_capacity_MW(devices) * active_devices(devices) + input_cap_alt_cost(devices) * input_capacity_MW(devices) * (1-active_devices(devices)) + output_cap_cost(devices) * output_capacity_MW(devices) * active_devices(devices))]$(ord(years)=1)
                  =l= big_Mtaxes*(1 - taxes_active(years)) ;

taxes_lin2(years)..
                  - cftr*(yearly_operating_profit*inflation_vec(years) - amount_depreciated(years))
                  + reserved_taxes(years-1)
                  + ITC*deprec_base_reduction*[sum(devices_ren, renew_cap_cost(devices_ren) * Renewable_MW(devices_ren))
                  + sum(devices, input_cap_cost(devices) * input_capacity_MW(devices) * active_devices(devices) + input_cap_alt_cost(devices) * input_capacity_MW(devices) * (1-active_devices(devices)) + output_cap_cost(devices) * output_capacity_MW(devices) * active_devices(devices))]$(ord(years)=1)
                  =g= -big_Mtaxes*taxes_active(years) ;

taxes_lin3(years)..
                 yearly_taxes(years) - [- cftr*(yearly_operating_profit*inflation_vec(years) - amount_depreciated(years))
                  + reserved_taxes(years-1)
                  + ITC*deprec_base_reduction*[sum(devices_ren, renew_cap_cost(devices_ren) * Renewable_MW(devices_ren))
                  + sum(devices, input_cap_cost(devices) * input_capacity_MW(devices) * active_devices(devices) + input_cap_alt_cost(devices) * input_capacity_MW(devices) * (1-active_devices(devices)) + output_cap_cost(devices) * output_capacity_MW(devices) * active_devices(devices))]$(ord(years)=1)]
                 =l= big_Mtaxes*(1 - taxes_active(years)) ;

taxes_lin4(years)..
                 yearly_taxes(years) - [- cftr*(yearly_operating_profit*inflation_vec(years) - amount_depreciated(years))
                  + reserved_taxes(years-1)
                  + ITC*deprec_base_reduction*[sum(devices_ren, renew_cap_cost(devices_ren) * Renewable_MW(devices_ren))
                  + sum(devices, input_cap_cost(devices) * input_capacity_MW(devices) * active_devices(devices) + input_cap_alt_cost(devices) * input_capacity_MW(devices) * (1-active_devices(devices)) + output_cap_cost(devices) * output_capacity_MW(devices) * active_devices(devices))]$(ord(years)=1)]
                 =g= -big_Mtaxes*(1 - taxes_active(years)) ;

taxes_lin5(years)..
                 yearly_taxes(years) =g= - big_Mtaxes*taxes_active(years) ;

reserved_taxes_eqn(years)..
reserved_taxes(years)  =e= reserved_taxes(years-1) - yearly_taxes(years) - cftr*(yearly_operating_profit*inflation_vec(years) - amount_depreciated(years))
                         + ITC*deprec_base_reduction*[sum(devices_ren, renew_cap_cost(devices_ren) * Renewable_MW(devices_ren))
                         + sum(devices, input_cap_cost(devices) * input_capacity_MW(devices) * active_devices(devices) + input_cap_alt_cost(devices) * input_capacity_MW(devices) * (1-active_devices(devices)) + output_cap_cost(devices) * output_capacity_MW(devices) * active_devices(devices))]$(ord(years)=1);

debt_service_eqn..
debt_service    =e= [debt_interest*(1-equity)*([sum(devices_ren, renew_cap_cost(devices_ren) * Renewable_MW(devices_ren))
                            + sum(devices, input_cap_cost(devices) * input_capacity_MW(devices) * active_devices(devices) + input_cap_alt_cost(devices) * input_capacity_MW(devices) * (1-active_devices(devices)) + output_cap_cost(devices) * output_capacity_MW(devices) * active_devices(devices))]
                            + [sum(devices, ProdStor_cap_cost(devices) * input_capacity_MW(devices) * active_devices(devices) *( input_efficiency(devices) / product_conversion )*storage_capacity_hours(devices))
                            + sum(devices, ProdComp_cap_cost(devices) * input_capacity_MW(devices) * active_devices(devices) *( input_efficiency(devices) / product_conversion ))])]
                      /[1 - (1 + debt_interest)**(-NoYears)]  ;

lin1(months,TOU_energy_period)$(%NEM_nscr%=1)..
                 electricity_surplus(months,TOU_energy_period) - sum(interval$(month_interval(months,interval) and elec_TOU_bins(TOU_energy_period,interval) and rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index),
                 interval_length*(sum(devices_ren,renewable_power_MW_sold(interval,devices_ren))+sum(devices,output_power_MW(interval,devices))-Import_elec_profile(interval)))
                 =g= -big_M*(1-esurplus_active(months,TOU_energy_period));
lin2(months,TOU_energy_period)$(%NEM_nscr%=1)..
                 electricity_surplus(months,TOU_energy_period) - sum(interval$(month_interval(months,interval) and elec_TOU_bins(TOU_energy_period,interval) and rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index),
                 interval_length*(sum(devices_ren,renewable_power_MW_sold(interval,devices_ren))+sum(devices,output_power_MW(interval,devices))-Import_elec_profile(interval)))
                 =l= big_M*(1-esurplus_active(months,TOU_energy_period));
lin3(months,TOU_energy_period)$(%NEM_nscr%=1)..
                 electricity_surplus(months,TOU_energy_period)  =l= big_M*esurplus_active(months,TOU_energy_period);
lin4(months,TOU_energy_period)$(%NEM_nscr%=1)..
                 sum(interval$(month_interval(months,interval) and elec_TOU_bins(TOU_energy_period,interval) and rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index),interval_length*(sum(devices_ren,renewable_power_MW_sold(interval,devices_ren))+sum(devices,output_power_MW(interval,devices))-Import_elec_profile(interval)))
                 =g= -big_M*(1-esurplus_active(months,TOU_energy_period)) + small_M*esurplus_active(months,TOU_energy_period);
lin5(months,TOU_energy_period)$(%NEM_nscr%=1)..
                 sum(interval$(month_interval(months,interval) and elec_TOU_bins(TOU_energy_period,interval) and rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index),interval_length*(sum(devices_ren,renewable_power_MW_sold(interval,devices_ren))+sum(devices,output_power_MW(interval,devices))-Import_elec_profile(interval)))
                 =l= big_M*esurplus_active(months,TOU_energy_period);

* Max system power only includes electricity sold.
system_power_eqn(interval)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         sum(devices, output_power_MW_non_ren_sold(interval,devices) +
                      output_power_MW_ren_sold(interval,devices))
       + sum(devices_ren, renewable_power_MW_sold(interval,devices_ren)) =l= max_sys_output_cap;

system_power_eqn2(interval)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         Import_elec_profile(interval) =l= max_sys_input_cap;

output_pwr_eqn2(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         output_power_MW(interval,devices) =e= output_power_MW_non_ren_sold(interval,devices) + output_power_MW_non_ren_load(interval,devices) + output_power_MW_ren_sold(interval,devices) + output_power_MW_ren_load(interval,devices);

output_LSL_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         output_power_MW(interval,devices) - output_regdn_MW(interval,devices) =g= output_LSL_fraction(devices) * output_capacity_MW(devices) * output_active(interval,devices);

output_capacity_limit_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index)..
         output_power_MW(interval,devices) + output_regup_MW(interval,devices) + output_spinres_MW(interval,devices) =l= Max_output_cap(interval,devices) * output_capacity_MW(devices) * output_active(interval,devices);

output_regup_limit_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         output_regup_MW(interval,devices) =l= Max_output_cap(interval,devices) * output_capacity_MW(devices) * output_regup_limit_fraction(devices);

output_regdn_limit_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         output_regdn_MW(interval,devices) =l= Max_output_cap(interval,devices) * output_capacity_MW(devices) * output_regdn_limit_fraction(devices);

output_spinres_limit_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         output_spinres_MW(interval,devices) =l= Max_output_cap(interval,devices) * output_capacity_MW(devices) * output_spinres_limit_fraction(devices);

output_nonspinres_limit_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         output_nonspinres_MW(interval,devices) =l= Max_output_cap(interval,devices) * output_capacity_MW(devices) * output_nonspinres_limit_fraction(devices) * ( 1 - output_active(interval,devices) );

output_ramp_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         output_power_MW(interval,devices)-output_power_MW(interval-1,devices) =e= output_ramp_pos(interval,devices)-output_ramp_neg(interval,devices);

input_ramp_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         input_power_MW(interval,devices)-input_power_MW(interval-1,devices) =e= input_ramp_pos(interval,devices)-input_ramp_neg(interval,devices);

input_pwr_eqn(interval,devices)$(baseload_operation(devices) = 1 )..
         input_power_MW(interval,devices) =e= Max_input_cap(interval,devices) * input_capacity_MW(devices) * CF_adjust(devices);

input_pwr_eqn2(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         input_power_MW(interval,devices) =e= input_power_MW_non_ren(interval,devices) + input_power_MW_ren(interval,devices);

input_LSL_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         input_power_MW(interval,devices) - input_regup_MW(interval,devices) - input_spinres_MW(interval,devices) - input_nonspinres_MW(interval,devices) =g= input_LSL_fraction(devices) * input_capacity_MW(devices) * input_active(interval,devices);

input_capacity_limit_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         input_power_MW(interval,devices) + input_regdn_MW(interval,devices) =l= Max_input_cap(interval,devices) * input_capacity_MW(devices) * input_active(interval,devices);
*** I don't think this is needed. Active_devices is set when product_sold = product_consumed
input_capacity_limit_eqn4(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         input_power_MW(interval,devices) + input_regdn_MW(interval,devices) =l= input_capacity_MW(devices) * active_devices(devices);

*** Fixed Demand Charge ***
Fixed_dem_Jan(Month_Jan)$( rolling_window_min_index <= ord(Month_Jan) and ord(Month_Jan) <= rolling_window_max_index ).. Import_elec_profile(Month_Jan) =l= Fixed_cap("1");
Fixed_dem_Feb(Month_Feb)$( rolling_window_min_index <= ord(Month_Feb) and ord(Month_Feb) <= rolling_window_max_index ).. Import_elec_profile(Month_Feb) =l= Fixed_cap("2");
Fixed_dem_Mar(Month_Mar)$( rolling_window_min_index <= ord(Month_Mar) and ord(Month_Mar) <= rolling_window_max_index ).. Import_elec_profile(Month_Mar) =l= Fixed_cap("3");
Fixed_dem_Apr(Month_Apr)$( rolling_window_min_index <= ord(Month_Apr) and ord(Month_Apr) <= rolling_window_max_index ).. Import_elec_profile(Month_Apr) =l= Fixed_cap("4");
Fixed_dem_May(Month_May)$( rolling_window_min_index <= ord(Month_May) and ord(Month_May) <= rolling_window_max_index ).. Import_elec_profile(Month_May) =l= Fixed_cap("5");
Fixed_dem_Jun(Month_Jun)$( rolling_window_min_index <= ord(Month_Jun) and ord(Month_Jun) <= rolling_window_max_index ).. Import_elec_profile(Month_Jun) =l= Fixed_cap("6");
Fixed_dem_Jul(Month_Jul)$( rolling_window_min_index <= ord(Month_Jul) and ord(Month_Jul) <= rolling_window_max_index ).. Import_elec_profile(Month_Jul) =l= Fixed_cap("7");
Fixed_dem_Aug(Month_Aug)$( rolling_window_min_index <= ord(Month_Aug) and ord(Month_Aug) <= rolling_window_max_index ).. Import_elec_profile(Month_Aug) =l= Fixed_cap("8");
Fixed_dem_Sep(Month_Sep)$( rolling_window_min_index <= ord(Month_Sep) and ord(Month_Sep) <= rolling_window_max_index ).. Import_elec_profile(Month_Sep) =l= Fixed_cap("9");
Fixed_dem_Oct(Month_Oct)$( rolling_window_min_index <= ord(Month_Oct) and ord(Month_Oct) <= rolling_window_max_index ).. Import_elec_profile(Month_Oct) =l= Fixed_cap("10");
Fixed_dem_Nov(Month_Nov)$( rolling_window_min_index <= ord(Month_Nov) and ord(Month_Nov) <= rolling_window_max_index ).. Import_elec_profile(Month_Nov) =l= Fixed_cap("11");
Fixed_dem_Dec(Month_Dec)$( rolling_window_min_index <= ord(Month_Dec) and ord(Month_Dec) <= rolling_window_max_index ).. Import_elec_profile(Month_Dec) =l= Fixed_cap("12");
*************************
**** Demand Charge 1 ****
Jan_1_eqn(Jan_1)$( rolling_window_min_index <= ord(Jan_1) and ord(Jan_1) <= rolling_window_max_index ).. Import_elec_profile(Jan_1) =l= Cap_1("1");
Feb_1_eqn(Feb_1)$( rolling_window_min_index <= ord(Feb_1) and ord(Feb_1) <= rolling_window_max_index ).. Import_elec_profile(Feb_1) =l= Cap_1("2");
Mar_1_eqn(Mar_1)$( rolling_window_min_index <= ord(Mar_1) and ord(Mar_1) <= rolling_window_max_index ).. Import_elec_profile(Mar_1) =l= Cap_1("3");
Apr_1_eqn(Apr_1)$( rolling_window_min_index <= ord(Apr_1) and ord(Apr_1) <= rolling_window_max_index ).. Import_elec_profile(Apr_1) =l= Cap_1("4");
May_1_eqn(May_1)$( rolling_window_min_index <= ord(May_1) and ord(May_1) <= rolling_window_max_index ).. Import_elec_profile(May_1) =l= Cap_1("5");
Jun_1_eqn(Jun_1)$( rolling_window_min_index <= ord(Jun_1) and ord(Jun_1) <= rolling_window_max_index ).. Import_elec_profile(Jun_1) =l= Cap_1("6");
Jul_1_eqn(Jul_1)$( rolling_window_min_index <= ord(Jul_1) and ord(Jul_1) <= rolling_window_max_index ).. Import_elec_profile(Jul_1) =l= Cap_1("7");
Aug_1_eqn(Aug_1)$( rolling_window_min_index <= ord(Aug_1) and ord(Aug_1) <= rolling_window_max_index ).. Import_elec_profile(Aug_1) =l= Cap_1("8");
Sep_1_eqn(Sep_1)$( rolling_window_min_index <= ord(Sep_1) and ord(Sep_1) <= rolling_window_max_index ).. Import_elec_profile(Sep_1) =l= Cap_1("9");
Oct_1_eqn(Oct_1)$( rolling_window_min_index <= ord(Oct_1) and ord(Oct_1) <= rolling_window_max_index ).. Import_elec_profile(Oct_1) =l= Cap_1("10");
Nov_1_eqn(Nov_1)$( rolling_window_min_index <= ord(Nov_1) and ord(Nov_1) <= rolling_window_max_index ).. Import_elec_profile(Nov_1) =l= Cap_1("11");
Dec_1_eqn(Dec_1)$( rolling_window_min_index <= ord(Dec_1) and ord(Dec_1) <= rolling_window_max_index ).. Import_elec_profile(Dec_1) =l= Cap_1("12");
*************************
**** Demand Charge 2 ****
Jan_2_eqn(Jan_2)$( rolling_window_min_index <= ord(Jan_2) and ord(Jan_2) <= rolling_window_max_index ).. Import_elec_profile(Jan_2) =l= Cap_2("1");
Feb_2_eqn(Feb_2)$( rolling_window_min_index <= ord(Feb_2) and ord(Feb_2) <= rolling_window_max_index ).. Import_elec_profile(Feb_2) =l= Cap_2("2");
Mar_2_eqn(Mar_2)$( rolling_window_min_index <= ord(Mar_2) and ord(Mar_2) <= rolling_window_max_index ).. Import_elec_profile(Mar_2) =l= Cap_2("3");
Apr_2_eqn(Apr_2)$( rolling_window_min_index <= ord(Apr_2) and ord(Apr_2) <= rolling_window_max_index ).. Import_elec_profile(Apr_2) =l= Cap_2("4");
May_2_eqn(May_2)$( rolling_window_min_index <= ord(May_2) and ord(May_2) <= rolling_window_max_index ).. Import_elec_profile(May_2) =l= Cap_2("5");
Jun_2_eqn(Jun_2)$( rolling_window_min_index <= ord(Jun_2) and ord(Jun_2) <= rolling_window_max_index ).. Import_elec_profile(Jun_2) =l= Cap_2("6");
Jul_2_eqn(Jul_2)$( rolling_window_min_index <= ord(Jul_2) and ord(Jul_2) <= rolling_window_max_index ).. Import_elec_profile(Jul_2) =l= Cap_2("7");
Aug_2_eqn(Aug_2)$( rolling_window_min_index <= ord(Aug_2) and ord(Aug_2) <= rolling_window_max_index ).. Import_elec_profile(Aug_2) =l= Cap_2("8");
Sep_2_eqn(Sep_2)$( rolling_window_min_index <= ord(Sep_2) and ord(Sep_2) <= rolling_window_max_index ).. Import_elec_profile(Sep_2) =l= Cap_2("9");
Oct_2_eqn(Oct_2)$( rolling_window_min_index <= ord(Oct_2) and ord(Oct_2) <= rolling_window_max_index ).. Import_elec_profile(Oct_2) =l= Cap_2("10");
Nov_2_eqn(Nov_2)$( rolling_window_min_index <= ord(Nov_2) and ord(Nov_2) <= rolling_window_max_index ).. Import_elec_profile(Nov_2) =l= Cap_2("11");
Dec_2_eqn(Dec_2)$( rolling_window_min_index <= ord(Dec_2) and ord(Dec_2) <= rolling_window_max_index ).. Import_elec_profile(Dec_2) =l= Cap_2("12");
*************************
**** Demand Charge 3 ****
Jan_3_eqn(Jan_3)$( rolling_window_min_index <= ord(Jan_3) and ord(Jan_3) <= rolling_window_max_index ).. Import_elec_profile(Jan_3) =l= Cap_3("1");
Feb_3_eqn(Feb_3)$( rolling_window_min_index <= ord(Feb_3) and ord(Feb_3) <= rolling_window_max_index ).. Import_elec_profile(Feb_3) =l= Cap_3("2");
Mar_3_eqn(Mar_3)$( rolling_window_min_index <= ord(Mar_3) and ord(Mar_3) <= rolling_window_max_index ).. Import_elec_profile(Mar_3) =l= Cap_3("3");
Apr_3_eqn(Apr_3)$( rolling_window_min_index <= ord(Apr_3) and ord(Apr_3) <= rolling_window_max_index ).. Import_elec_profile(Apr_3) =l= Cap_3("4");
May_3_eqn(May_3)$( rolling_window_min_index <= ord(May_3) and ord(May_3) <= rolling_window_max_index ).. Import_elec_profile(May_3) =l= Cap_3("5");
Jun_3_eqn(Jun_3)$( rolling_window_min_index <= ord(Jun_3) and ord(Jun_3) <= rolling_window_max_index ).. Import_elec_profile(Jun_3) =l= Cap_3("6");
Jul_3_eqn(Jul_3)$( rolling_window_min_index <= ord(Jul_3) and ord(Jul_3) <= rolling_window_max_index ).. Import_elec_profile(Jul_3) =l= Cap_3("7");
Aug_3_eqn(Aug_3)$( rolling_window_min_index <= ord(Aug_3) and ord(Aug_3) <= rolling_window_max_index ).. Import_elec_profile(Aug_3) =l= Cap_3("8");
Sep_3_eqn(Sep_3)$( rolling_window_min_index <= ord(Sep_3) and ord(Sep_3) <= rolling_window_max_index ).. Import_elec_profile(Sep_3) =l= Cap_3("9");
Oct_3_eqn(Oct_3)$( rolling_window_min_index <= ord(Oct_3) and ord(Oct_3) <= rolling_window_max_index ).. Import_elec_profile(Oct_3) =l= Cap_3("10");
Nov_3_eqn(Nov_3)$( rolling_window_min_index <= ord(Nov_3) and ord(Nov_3) <= rolling_window_max_index ).. Import_elec_profile(Nov_3) =l= Cap_3("11");
Dec_3_eqn(Dec_3)$( rolling_window_min_index <= ord(Dec_3) and ord(Dec_3) <= rolling_window_max_index ).. Import_elec_profile(Dec_3) =l= Cap_3("12");
*************************
**** Demand Charge 4 ****
Jan_4_eqn(Jan_4)$( rolling_window_min_index <= ord(Jan_4) and ord(Jan_4) <= rolling_window_max_index ).. Import_elec_profile(Jan_4) =l= Cap_4("1");
Feb_4_eqn(Feb_4)$( rolling_window_min_index <= ord(Feb_4) and ord(Feb_4) <= rolling_window_max_index ).. Import_elec_profile(Feb_4) =l= Cap_4("2");
Mar_4_eqn(Mar_4)$( rolling_window_min_index <= ord(Mar_4) and ord(Mar_4) <= rolling_window_max_index ).. Import_elec_profile(Mar_4) =l= Cap_4("3");
Apr_4_eqn(Apr_4)$( rolling_window_min_index <= ord(Apr_4) and ord(Apr_4) <= rolling_window_max_index ).. Import_elec_profile(Apr_4) =l= Cap_4("4");
May_4_eqn(May_4)$( rolling_window_min_index <= ord(May_4) and ord(May_4) <= rolling_window_max_index ).. Import_elec_profile(May_4) =l= Cap_4("5");
Jun_4_eqn(Jun_4)$( rolling_window_min_index <= ord(Jun_4) and ord(Jun_4) <= rolling_window_max_index ).. Import_elec_profile(Jun_4) =l= Cap_4("6");
Jul_4_eqn(Jul_4)$( rolling_window_min_index <= ord(Jul_4) and ord(Jul_4) <= rolling_window_max_index ).. Import_elec_profile(Jul_4) =l= Cap_4("7");
Aug_4_eqn(Aug_4)$( rolling_window_min_index <= ord(Aug_4) and ord(Aug_4) <= rolling_window_max_index ).. Import_elec_profile(Aug_4) =l= Cap_4("8");
Sep_4_eqn(Sep_4)$( rolling_window_min_index <= ord(Sep_4) and ord(Sep_4) <= rolling_window_max_index ).. Import_elec_profile(Sep_4) =l= Cap_4("9");
Oct_4_eqn(Oct_4)$( rolling_window_min_index <= ord(Oct_4) and ord(Oct_4) <= rolling_window_max_index ).. Import_elec_profile(Oct_4) =l= Cap_4("10");
Nov_4_eqn(Nov_4)$( rolling_window_min_index <= ord(Nov_4) and ord(Nov_4) <= rolling_window_max_index ).. Import_elec_profile(Nov_4) =l= Cap_4("11");
Dec_4_eqn(Dec_4)$( rolling_window_min_index <= ord(Dec_4) and ord(Dec_4) <= rolling_window_max_index ).. Import_elec_profile(Dec_4) =l= Cap_4("12");
*************************
**** Demand Charge 5 ****
Jan_5_eqn(Jan_5)$( rolling_window_min_index <= ord(Jan_5) and ord(Jan_5) <= rolling_window_max_index ).. Import_elec_profile(Jan_5) =l= Cap_5("1");
Feb_5_eqn(Feb_5)$( rolling_window_min_index <= ord(Feb_5) and ord(Feb_5) <= rolling_window_max_index ).. Import_elec_profile(Feb_5) =l= Cap_5("2");
Mar_5_eqn(Mar_5)$( rolling_window_min_index <= ord(Mar_5) and ord(Mar_5) <= rolling_window_max_index ).. Import_elec_profile(Mar_5) =l= Cap_5("3");
Apr_5_eqn(Apr_5)$( rolling_window_min_index <= ord(Apr_5) and ord(Apr_5) <= rolling_window_max_index ).. Import_elec_profile(Apr_5) =l= Cap_5("4");
May_5_eqn(May_5)$( rolling_window_min_index <= ord(May_5) and ord(May_5) <= rolling_window_max_index ).. Import_elec_profile(May_5) =l= Cap_5("5");
Jun_5_eqn(Jun_5)$( rolling_window_min_index <= ord(Jun_5) and ord(Jun_5) <= rolling_window_max_index ).. Import_elec_profile(Jun_5) =l= Cap_5("6");
Jul_5_eqn(Jul_5)$( rolling_window_min_index <= ord(Jul_5) and ord(Jul_5) <= rolling_window_max_index ).. Import_elec_profile(Jul_5) =l= Cap_5("7");
Aug_5_eqn(Aug_5)$( rolling_window_min_index <= ord(Aug_5) and ord(Aug_5) <= rolling_window_max_index ).. Import_elec_profile(Aug_5) =l= Cap_5("8");
Sep_5_eqn(Sep_5)$( rolling_window_min_index <= ord(Sep_5) and ord(Sep_5) <= rolling_window_max_index ).. Import_elec_profile(Sep_5) =l= Cap_5("9");
Oct_5_eqn(Oct_5)$( rolling_window_min_index <= ord(Oct_5) and ord(Oct_5) <= rolling_window_max_index ).. Import_elec_profile(Oct_5) =l= Cap_5("10");
Nov_5_eqn(Nov_5)$( rolling_window_min_index <= ord(Nov_5) and ord(Nov_5) <= rolling_window_max_index ).. Import_elec_profile(Nov_5) =l= Cap_5("11");
Dec_5_eqn(Dec_5)$( rolling_window_min_index <= ord(Dec_5) and ord(Dec_5) <= rolling_window_max_index ).. Import_elec_profile(Dec_5) =l= Cap_5("12");
*************************
**** Demand Charge 6 ****
Jan_6_eqn(Jan_6)$( rolling_window_min_index <= ord(Jan_6) and ord(Jan_6) <= rolling_window_max_index ).. Import_elec_profile(Jan_6) =l= Cap_6("1");
Feb_6_eqn(Feb_6)$( rolling_window_min_index <= ord(Feb_6) and ord(Feb_6) <= rolling_window_max_index ).. Import_elec_profile(Feb_6) =l= Cap_6("2");
Mar_6_eqn(Mar_6)$( rolling_window_min_index <= ord(Mar_6) and ord(Mar_6) <= rolling_window_max_index ).. Import_elec_profile(Mar_6) =l= Cap_6("3");
Apr_6_eqn(Apr_6)$( rolling_window_min_index <= ord(Apr_6) and ord(Apr_6) <= rolling_window_max_index ).. Import_elec_profile(Apr_6) =l= Cap_6("4");
May_6_eqn(May_6)$( rolling_window_min_index <= ord(May_6) and ord(May_6) <= rolling_window_max_index ).. Import_elec_profile(May_6) =l= Cap_6("5");
Jun_6_eqn(Jun_6)$( rolling_window_min_index <= ord(Jun_6) and ord(Jun_6) <= rolling_window_max_index ).. Import_elec_profile(Jun_6) =l= Cap_6("6");
Jul_6_eqn(Jul_6)$( rolling_window_min_index <= ord(Jul_6) and ord(Jul_6) <= rolling_window_max_index ).. Import_elec_profile(Jul_6) =l= Cap_6("7");
Aug_6_eqn(Aug_6)$( rolling_window_min_index <= ord(Aug_6) and ord(Aug_6) <= rolling_window_max_index ).. Import_elec_profile(Aug_6) =l= Cap_6("8");
Sep_6_eqn(Sep_6)$( rolling_window_min_index <= ord(Sep_6) and ord(Sep_6) <= rolling_window_max_index ).. Import_elec_profile(Sep_6) =l= Cap_6("9");
Oct_6_eqn(Oct_6)$( rolling_window_min_index <= ord(Oct_6) and ord(Oct_6) <= rolling_window_max_index ).. Import_elec_profile(Oct_6) =l= Cap_6("10");
Nov_6_eqn(Nov_6)$( rolling_window_min_index <= ord(Nov_6) and ord(Nov_6) <= rolling_window_max_index ).. Import_elec_profile(Nov_6) =l= Cap_6("11");
Dec_6_eqn(Dec_6)$( rolling_window_min_index <= ord(Dec_6) and ord(Dec_6) <= rolling_window_max_index ).. Import_elec_profile(Dec_6) =l= Cap_6("12");
*************************

input_capacity_limit_eqn2(interval)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         Import_elec_profile(interval) =e= sum(devices,input_power_MW_non_ren(interval,devices) - output_power_MW_non_ren_load(interval,devices)) + Load_profile_non_ren(interval);

input_ren_contribution(interval)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         sum(devices,input_power_MW_ren(interval,devices)) + sum(devices_ren,renewable_power_MW_sold(interval,devices_ren)) + Load_profile_ren(interval) - sum(devices,output_power_MW_ren_load(interval,devices)) =l= sum(devices_ren,Renewable_power(interval,devices_ren));

input_regup_limit_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         input_regup_MW(interval,devices) =l= Max_input_cap(interval,devices) * input_capacity_MW(devices) * input_regup_limit_fraction(devices);

input_regdn_limit_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         input_regdn_MW(interval,devices) =l= Max_input_cap(interval,devices) * input_capacity_MW(devices) * input_regdn_limit_fraction(devices);

input_spinres_limit_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         input_spinres_MW(interval,devices) =l= Max_input_cap(interval,devices) * input_capacity_MW(devices) * input_spinres_limit_fraction(devices);

input_nonspinres_limit_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         input_nonspinres_MW(interval,devices) =l= Max_input_cap(interval,devices) * input_capacity_MW(devices) * input_nonspinres_limit_fraction(devices);

load_profile_eqn(interval)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         Load_profile(interval) =e= Load_profile_non_ren(interval) + Load_profile_ren(interval);

storage_level_accounting_init_eqn(interval,devices)$(rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and input_capacity_MW(devices) > 0 and baseload_operation(devices)=0 and ord(interval)=1)..
         storage_level_MWh(interval,devices)+storage_level_MWh_ren(interval,devices) =e= storage_init(devices)*storage_capacity_hours(devices)*input_capacity_MW(devices)*input_efficiency(devices)
         + (input_power_MW(interval,devices)+input_power_MW_ren(interval,devices)) * interval_length * input_efficiency(devices)
         - (output_power_MW(interval,devices)+output_power_MW_ren_sold(interval,devices)+output_power_MW_ren_load(interval,devices)) * interval_length / output_efficiency(devices)
         - (product_sold(interval,devices)+product_sold_ren(interval,devices)) * product_conversion;

storage_level_accounting_final_eqn(interval,devices)$(rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and input_capacity_MW(devices) > 0 and baseload_operation(devices)=0 and ord(interval)=operating_period_length and storage_set_final(devices)=1)..
         storage_level_MWh(interval,devices)+storage_level_MWh_ren(interval,devices) =e= storage_final(devices)*storage_capacity_hours(devices)*input_capacity_MW(devices)*input_efficiency(devices);

storage_level_accounting_eqn(interval,devices)$(rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and input_capacity_MW(devices) > 0 and baseload_operation(devices)=0 and ord(interval)>current_interval and ord(interval)<max_interval and ord(interval)>1)..
         storage_level_MWh(interval,devices) =e= storage_level_MWh(interval-1,devices)*(1-storage_dissipation(devices))
         + input_power_MW_non_ren(interval,devices) * interval_length * input_efficiency(devices)
         - (output_power_MW_non_ren_sold(interval,devices) + output_power_MW_non_ren_load(interval,devices)) * interval_length / output_efficiency(devices)
         - product_sold_non_ren(interval,devices) * product_conversion;

storage_level_accounting_eqn2(interval,devices)$(rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and input_capacity_MW(devices) = 0 and baseload_operation(devices)=0 and ord(interval)>current_interval and ord(interval)<max_interval )..
         storage_level_MWh(interval,devices)+storage_level_MWh_ren(interval,devices) =e= (storage_level_MWh(interval-1,devices)+storage_level_MWh_ren(interval-1,devices))*(1-storage_dissipation(devices));
* If input capacity is equal to zero then output device cannot interact with storage system so storage_level_MWh is held constant

storage_level_accounting_eqn3(interval,devices)$(rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and input_capacity_MW(devices) > 0 and ord(interval)>current_interval and ord(interval)<max_interval )..
         storage_level_MWh_ren(interval,devices) =e= storage_level_MWh_ren(interval-1,devices)*(1-storage_dissipation(devices))
         + input_power_MW_ren(interval,devices) * interval_length * input_efficiency(devices)
         - (output_power_MW_ren_sold(interval,devices) + output_power_MW_ren_load(interval,devices)) * interval_length / output_efficiency(devices)
         - product_sold_ren(interval,devices) * product_conversion;
* For product_consumed, setting the last interval to output product can cause an infeasibiltiy when setting the init/final storage level (either 1. don't consume product in the last interval, 2. turn off storage setpoints or 3. sometimes I had to reduce the CF)

product_output_limit_eqn(days,devices)$(product_use(devices) = 2)..
         product_sold_daily(days,devices) =e= sum( interval$(floor(div(ord(interval)-1,24))+1 = ord(days) ), product_sold(interval,devices) );

product_output_limit_eqn2(days,devices)$(product_use(devices) = 2)..
         product_sold_daily(days,devices) =e= sum( interval$(floor(div(ord(interval)-1,24))+1 = ord(days) ), product_consumed(interval,devices) );
* Reduce product_sold for inactive devices
product_output_limit_eqn3(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and product_use(devices) <= 1 and CF_opt=0)..
         product_sold(interval,devices) =e= product_consumed(interval,devices) * active_devices(devices) * (1 - CF_incremental_change(devices)*CF_incremental_change_value);

product_renewable_eqn(interval,devices)$(rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and ord(interval)>current_interval and ord(interval)<max_interval )..
         product_sold(interval,devices) =e= product_sold_non_ren(interval,devices) + product_sold_ren(interval,devices);

storage_level_limit_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and input_capacity_MW(devices)>0 and ord(interval)>current_interval and ord(interval)<max_interval )..
         storage_level_MWh(interval,devices) + storage_level_MWh_ren(interval,devices) =l= input_capacity_MW(devices) * input_efficiency(devices) * storage_capacity_hours(devices)
         - input_regdn_MW(interval,devices) * interval_length * 0.5;

storage_level_limit_eqn2(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and input_capacity_MW(devices)<=0 and ord(interval)>current_interval and ord(interval)<max_interval )..
         storage_level_MWh(interval,devices) + storage_level_MWh_ren(interval,devices) =l= output_capacity_MW(devices) / output_efficiency(devices) * storage_capacity_hours(devices)
         - input_regdn_MW(interval,devices) * interval_length * 0.5;

storage_level_limit_eqn3(interval,devices)$(rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and ord(interval)>current_interval and ord(interval)<max_interval )..
         storage_level_MWh(interval,devices) + storage_level_MWh_ren(interval,devices) =g= (output_regup_MW(interval,devices) + output_spinres_MW(interval,devices) + output_nonspinres_MW(interval,devices)) / input_efficiency(devices) * interval_length * 0.5;
* Ensures that reserves can be provided for at least 1/2 hour.

output_startup_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         output_start(interval,devices) =g= output_active(interval,devices) - output_active(interval-1,devices);

input_startup_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         input_start(interval,devices) =g= input_active(interval,devices) - input_active(interval-1,devices);

RT_eqn1(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and ord(interval)<=current_interval and current_monthly_max>=0)..
         input_power_MW(interval,devices) =e= current_monthly_max * input_capacity_MW(devices);

RT_eqn2(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and ord(interval)<=current_interval and current_storage_lvl>=0)..
         storage_level_MWh(interval,devices) + storage_level_MWh_ren(interval,devices) =e= current_storage_lvl * input_capacity_MW(devices) * input_efficiency(devices) * storage_capacity_hours(devices);

RT_eqn3(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and ord(interval)>=max_interval and current_monthly_max>=0)..
         input_power_MW(interval,devices) =e= current_monthly_max * input_capacity_MW(devices);

RT_eqn4(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and ord(interval)>=max_interval and current_storage_lvl>=0)..
         storage_level_MWh(interval,devices) + storage_level_MWh_ren(interval,devices) =e= current_storage_lvl * input_capacity_MW(devices) * input_efficiency(devices) * storage_capacity_hours(devices);

one_active_device_eqn(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index and one_active_device=1)..
         input_active(interval,devices) + output_active(interval,devices) =l= 1;

**** Added binary limiting equation.
device_num_eqn$(%devices_instance%>1)..
        sum(devices,active_devices(devices)) =l= card(devices);

alias (interval, interval_alias);
*note that min runtime constraints are not generated if min runtimes would not be binding--this reduces the execution time significantly
output_min_on_eqn1(interval,devices)$( min_output_on_intervals > 1 and 1 < ord(interval) and ord(interval) <= min_output_on_intervals and rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         sum(interval_alias$( ord(interval_alias) <= ord(interval) ), output_active(interval_alias,devices) ) =g= ord(interval) * ( output_active(interval,devices) - output_active(interval + 1,devices) );

output_min_on_eqn2(interval,devices)$( min_output_on_intervals > 1 and 1 < ord(interval) and ord(interval) <= card(interval) - min_output_on_intervals + 1 and rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         sum(interval_alias$( ord(interval) <= ord(interval_alias) and ord(interval_alias) <= ord(interval) + min_output_on_intervals - 1 ),
             output_active(interval_alias,devices) ) =g= min_output_on_intervals * ( output_active(interval,devices) - output_active(interval - 1,devices) );

output_min_on_eqn3(interval,devices)$( min_output_on_intervals > 1 and ord(interval) > card(interval) - min_output_on_intervals + 1 and ord(interval) < card(interval) and rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         sum(interval_alias$( ord(interval) <= ord(interval_alias) ), output_active(interval_alias,devices) ) =g= (card(interval) - ord(interval) + 1) * ( output_active(interval,devices) - output_active(interval - 1,devices) );

input_min_on_eqn1(interval,devices)$( min_input_on_intervals > 1 and 1 < ord(interval) and ord(interval) <= min_input_on_intervals and rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         sum(interval_alias$( ord(interval_alias) <= ord(interval) ), input_active(interval_alias,devices) ) =g= ord(interval) * ( input_active(interval,devices) - input_active(interval + 1,devices) );

input_min_on_eqn2(interval,devices)$( min_input_on_intervals > 1 and 1 < ord(interval) and ord(interval) <= card(interval) - min_input_on_intervals + 1 and rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         sum(interval_alias$( ord(interval) <= ord(interval_alias) and ord(interval_alias) <= ord(interval) + min_input_on_intervals - 1 ),
             input_active(interval_alias,devices) ) =g= min_input_on_intervals * ( input_active(interval,devices) - input_active(interval - 1,devices) );

input_min_on_eqn3(interval,devices)$( min_input_on_intervals > 1 and ord(interval) > card(interval) - min_input_on_intervals + 1 and ord(interval) < card(interval) and rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )..
         sum(interval_alias$( ord(interval) <= ord(interval_alias) ), input_active(interval_alias,devices) ) =g= (card(interval) - ord(interval) + 1) * ( input_active(interval,devices) - input_active(interval - 1,devices) );


Model arbitrage_and_AS /all/
*set number of iterations before solver is terminated
option iterlim = 1000000;
*set number of seconds before the solver is terminated
option reslim = 86400;
*suppress listing of the equations in the listing file
option limrow = 3;
option limcol = 3;
*suppress listing of the solution in the listing file
option solprint = on;
option sysout = on;

$ontext
$inlinecom /* */
* Turn off the listing of the input file
$offlisting
* Turn off the listing and cross-reference of the symbols used
$offsymxref offsymlist
option solprint = off;
option sysout = off;
option limrow = 0;
option limcol = 0;
$offtext

$onecho > cplex.opt
scaind 1
lpmethod 4
*CPXPARAM_Barrier_Limits_Iteration 100000000
baritlim 100000000
$offecho
arbitrage_and_AS.OptFile = 1;

*prepare for rolling window solution

*determine the number of times the model will be solved
number_of_solves = ceil( card(interval) / operating_period_length );

*set optcr so that (best feasible - best possible) / (best feasible + 1e-10) < optcr
* default is 0.1 = 10%, which seems too big
* 0.01 = 1%
option optcr=0.0001;

*give initial values to all of the variables
output_power_MW.l(interval,devices)      = 0;
output_power_MW_non_ren_sold.l(interval,devices) = 0;
output_power_MW_non_ren_load.l(interval,devices) = 0;
output_power_MW_ren_sold.l(interval,devices) = 0;
output_power_MW_ren_load.l(interval,devices) = 0;
output_regup_MW.l(interval,devices)      = 0;
output_regdn_MW.l(interval,devices)      = 0;
output_spinres_MW.l(interval,devices)    = 0;
output_nonspinres_MW.l(interval,devices) = 0;
input_power_MW.l(interval,devices)       = 1;
input_power_MW_non_ren.l(interval,devices) = 1;
input_power_MW_ren.l(interval,devices)   = 1;
input_regup_MW.l(interval,devices)       = 0;
input_regdn_MW.l(interval,devices)       = 0;
input_spinres_MW.l(interval,devices)     = 0;
input_nonspinres_MW.l(interval,devices)  = 0;
storage_level_MWh.l(interval,devices)    = 1;
storage_level_MWh_ren.l(interval,devices)= 1;
output_active.l(interval,devices)        = 0;
input_active.l(interval,devices)         = 0;
output_start.l(interval,devices)         = 0;
input_start.l(interval,devices)          = 0;
product_sold.l(interval,devices)         = 0;
product_sold_non_ren.l(interval,devices) = 0;
product_sold_ren.l(interval,devices)     = 0;
product_sold_daily.l(days,devices)       = 0;
renewable_power_MW_sold.l(interval,devices_ren)= 0;
Import_elec_profile.l(interval)          = 0;
Load_profile_non_ren.l(interval)         = 1;
Load_profile_ren.l(interval)             = 1;
CF_incremental_change.l(devices)         = 0;

loop(devices,
    if(product_use(devices) = 2,
         product_sold_daily.l(days,devices) = 24;
* need value above 0 for initialization
    );
);
scalars
         no_error indicator of whether the model encountered an error
         optimal_solution_reached indicator of whether the model found an optimal solution before the time limit expired
         solve_index index for solve loop
;

no_error = 1;
optimal_solution_reached = 1;
solve_index = 1;

while ( solve_index <= number_of_solves and no_error = 1 ,

*        fix all variables' values
*        (will relax the values within the rolling window later)
         output_power_MW.fx(interval,devices)      = output_power_MW.l(interval,devices)  ;
         output_power_MW_non_ren_sold.fx(interval,devices) = output_power_MW_non_ren_sold.l(interval,devices);
         output_power_MW_non_ren_load.fx(interval,devices) = output_power_MW_non_ren_load.l(interval,devices);
         output_power_MW_ren_sold.fx(interval,devices) = output_power_MW_ren_sold.l(interval,devices);
         output_power_MW_ren_load.fx(interval,devices) = output_power_MW_ren_load.l(interval,devices);
         output_regup_MW.fx(interval,devices)      = output_regup_MW.l(interval,devices)  ;
         output_regdn_MW.fx(interval,devices)      = output_regdn_MW.l(interval,devices)  ;
         output_spinres_MW.fx(interval,devices)    = output_spinres_MW.l(interval,devices);
         output_nonspinres_MW.fx(interval,devices) = output_nonspinres_MW.l(interval,devices);
         input_power_MW.fx(interval,devices)       = input_power_MW.l(interval,devices)   ;
         input_power_MW_non_ren.fx(interval,devices) = input_power_MW_non_ren.l(interval,devices);
         input_power_MW_ren.fx(interval,devices)   = input_power_MW_ren.l(interval,devices);
         input_regup_MW.fx(interval,devices)       = input_regup_MW.l(interval,devices)   ;
         input_regdn_MW.fx(interval,devices)       = input_regdn_MW.l(interval,devices)   ;
         input_spinres_MW.fx(interval,devices)     = input_spinres_MW.l(interval,devices) ;
         input_nonspinres_MW.fx(interval,devices)  = input_nonspinres_MW.l(interval,devices);
         storage_level_MWh.fx(interval,devices)    = storage_level_MWh.l(interval,devices);
         storage_level_MWh_ren.fx(interval,devices)= storage_level_MWh_ren.l(interval,devices);
         output_active.fx(interval,devices)        = output_active.l(interval,devices)    ;
         input_active.fx(interval,devices)         = input_active.l(interval,devices)     ;
         output_start.fx(interval,devices)         = output_start.l(interval,devices)     ;
         input_start.fx(interval,devices)          = input_start.l(interval,devices)      ;
         product_sold.fx(interval,devices)         = product_sold.l(interval,devices)          ;
         product_sold_non_ren.fx(interval,devices) = product_sold_non_ren.l(interval,devices)  ;
         product_sold_ren.fx(interval,devices)     = product_sold_ren.l(interval,devices)      ;
         product_sold_daily.fx(days,devices)       = product_sold_daily.l(days,devices)        ;
         renewable_power_MW_sold.fx(interval,devices_ren)= renewable_power_MW_sold.l(interval,devices_ren);
         Import_elec_profile.fx(interval)          = Import_elec_profile.l(interval);
         Load_profile_non_ren.fx(interval)         = Load_profile_non_ren.l(interval);
         Load_profile_ren.fx(interval)             = Load_profile_ren.l(interval);

*        calculate the min and max indices for the rolling window
         operating_period_min_index = ( solve_index-1 ) * operating_period_length + 1;
         operating_period_max_index = ( solve_index ) * operating_period_length;
         rolling_window_min_index   = operating_period_min_index;
         rolling_window_max_index   = operating_period_max_index + look_ahead_length;

*        set bounds on integer variable to speed up run time
         CF_incremental_change.lo(devices) = 0;
         CF_incremental_change.up(devices) = 100;

*        relax variables in current rolling window
         output_power_MW.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )      = 0;
         output_power_MW_non_ren_sold.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ) = 0;
         output_power_MW_non_ren_load.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ) = 0;
         output_power_MW_ren_sold.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ) = 0;
         output_power_MW_ren_load.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ) = 0;
         output_regup_MW.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )      = 0;
         output_regdn_MW.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )      = 0;
         output_spinres_MW.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )    = 0;
         output_nonspinres_MW.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ) = 0;
         input_power_MW.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )       = 0;
         input_power_MW_non_ren.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ) = 0;
         input_power_MW_ren.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )   = 0;
         input_regup_MW.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )       = 0;
         input_regdn_MW.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )       = 0;
         input_spinres_MW.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )     = 0;
         input_nonspinres_MW.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )  = 0;
         storage_level_MWh.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )    = 0;
         storage_level_MWh_ren.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )= 0;
         output_active.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )        = 0;
         input_active.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )         = 0;
         output_start.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )         = 0;
         input_start.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )          = 0;
         product_sold.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )         = 0;
         product_sold_non_ren.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ) = 0;
         product_sold_ren.lo(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )     = 0;
         product_sold_daily.lo(days,devices)$(product_use(devices)=2)                                                                          = 0;
         renewable_power_MW_sold.lo(interval,devices_ren)$(rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index)= 0;
         Import_elec_profile.lo(interval)$(rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index)            = 0;
         Load_profile_non_ren.lo(interval)$(rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index)           = 0;
         Load_profile_ren.lo(interval)$(rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index)               = 0;

         output_power_MW.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )      =  inf;
         output_power_MW_non_ren_sold.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ) =  inf;
         output_power_MW_non_ren_load.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ) =  inf;
         output_power_MW_ren_sold.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ) =  inf;
         output_power_MW_ren_load.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ) =  inf;
         output_regup_MW.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )      =  inf;
         output_regdn_MW.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )      =  inf;
         output_spinres_MW.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )    =  inf;
         output_nonspinres_MW.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ) =  inf;
         input_power_MW.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )       =  inf;
         input_power_MW_non_ren.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ) =  inf;
         input_power_MW_ren.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )   =  inf;
         input_regup_MW.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )       =  inf;
         input_regdn_MW.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )       =  inf;
         input_spinres_MW.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )     =  inf;
         input_nonspinres_MW.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )  =  inf;
         storage_level_MWh.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )    =  inf;
         storage_level_MWh_ren.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )=  inf;
         output_active.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )        =  1;
         input_active.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )         =  1;
         output_start.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )         =  1;
         input_start.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )          =  1;
         product_sold.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )         = inf;
         product_sold_non_ren.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ) = inf;
         product_sold_ren.up(interval,devices)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index )     = inf;
         product_sold_daily.up(days,devices)$(product_use(devices)=2)                                                                          = inf;
         renewable_power_MW_sold.up(interval,devices_ren)$(rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index)= inf;
         Import_elec_profile.up(interval)$(rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index)            = inf;
         Load_profile_non_ren.up(interval)$(rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index)           = inf;
         Load_profile_ren.up(interval)$(rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index)               = inf;

*===============================================================================
* If sales are not allowed, the respective variable should be fixed to 0
*===============================================================================
         If (allow_sales = 0,
                  renewable_power_MW_sold.fx(interval,devices_ren) = 0 ;
         elseif allow_sales= 1,
                  renewable_power_MW_sold.l(interval,devices_ren) = 0 ;
         );;
         If (allow_import = 0,
                  Import_elec_profile.fx(interval) = 0;
         );
         Loop(devices,
            IF (product_use(devices) = 0 or %soft_cons_device_inst% = 0,
                  CF_incremental_change.fx(devices) = 0;
            );
         );

         If(
*=====================================================================================================================
* run a RODeO run with updating the product cost
*=====================================================================================================================
         %run_opt_breakeven% = 1,

                 while(
                       (abs(epsilon) gt 0.001),

                       display product_price_adj, product_price ;

                       Solve arbitrage_and_AS using MIP maximizing operating_profit;

                       display product_price_adj, product_price ;

                       Total_product_sold              = sum(years,sum((interval,devices),product_sold.l(interval,devices))/to_NPV(years));

                       LCFS_revenue_vec(devices)      = sum(years,sum((interval),(CI_base_line*EER - Grid_CarbInt/input_efficiency(devices))*LCFS_price*EneDens*(power(10,-6)) * product_sold.l(interval,devices)
                        + Grid_CarbInt*LCFS_price*EneDens*(power(10,-6)) * product_sold_ren.l(interval,devices) )*inflation_vec(years)/to_NPV(years));
                       LCFS_revenuePERprod  =  sum(devices,LCFS_revenue_vec(devices))/Total_product_sold;

                       arbitrage_revenue_vec(devices) = sum(years,sum(interval$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ),
                                                        ((elec_sale_price(interval) * (output_power_MW_non_ren_sold.l(interval,devices) + output_power_MW_ren_sold.l(interval,devices)) - (elec_purchase_price(interval) * input_power_MW_non_ren.l(interval,devices))) * interval_length)*(1 - %NEM_nscr%)
                                                      + sum[(months,TOU_energy_period)$(month_interval(months,interval) and elec_TOU_bins(TOU_energy_period,interval)),
                                                       (elec_sale_price(interval)   * (output_power_MW_non_ren_sold.l(interval,devices) + output_power_MW_ren_sold.l(interval,devices)) * (1-esurplus_active.l(months,TOU_energy_period))
                                                      - elec_purchase_price(interval) * input_power_MW_non_ren.l(interval,devices) * (1-esurplus_active.l(months,TOU_energy_period))) * interval_length]*(%NEM_nscr%)
                                                      - output_heat_rate(devices) * NG_price(interval) * output_power_MW.l(interval,devices) * interval_length
                                                      - input_heat_rate(devices) * NG_price(interval) * input_power_MW.l(interval,devices) * interval_length
                                                      - VOM_cost * output_power_MW.l(interval,devices) * interval_length
                                                      + elec_purchase_price(interval) * Load_profile_non_ren.l(interval) * interval_length
                                                      )*inflation_vec(years)/to_NPV(years));
                       Energy_chargePERprod                = sum(devices,arbitrage_revenue_vec(devices))/Total_product_sold;

                       Fixed_demand_chargePERprod          = sum(years,-sum(months, Fixed_cap.l(months) * Fixed_dem(months))*inflation_vec(years)/to_NPV(years))/Total_product_sold;

                       Timed_demand_chargePERprod          = sum(years,(-sum(months, cap_1.l(months) * Timed_dem("1"))-sum(months, cap_2.l(months) * Timed_dem("2"))-sum(months, cap_3.l(months) * Timed_dem("3"))
                                                           -sum(months, cap_4.l(months) * Timed_dem("4"))-sum(months, cap_5.l(months) * Timed_dem("5"))-sum(months, cap_6.l(months) * Timed_dem("6")))*inflation_vec(years)/to_NPV(years))
                                                           /Total_product_sold;
                       Meters_costPERprod                  = sum(years,-(meter_mnth_chg("1") * 12*allow_import)*inflation_vec(years)/to_NPV(years))/Total_product_sold;

                       ProdStor_cap_cost2_vec(devices)  = - equity * ProdStor_cap_cost(devices) * input_capacity_MW(devices) * (input_efficiency(devices) / product_conversion ) * storage_capacity_hours(devices);
                       Storage_costPERprod                 = sum(devices,ProdStor_cap_cost2_vec(devices))/Total_product_sold;

                       ProdComp_cap_cost2_vec(devices)  = - equity*ProdComp_cap_cost(devices) * input_capacity_MW(devices) *( input_efficiency(devices) / product_conversion ) ;
                       Compressor_costPERprod              = sum(devices,ProdComp_cap_cost2_vec(devices))/Total_product_sold;

                       input_cap_cost2_vec(devices)     = -equity*input_cap_cost(devices)     * input_capacity_MW(devices) ;
                       input_cap_costPERprod                 = sum(devices,input_cap_cost2_vec(devices))/Total_product_sold;

                       input_FOM_cost2_vec(devices)     = sum(years,-input_FOM_cost(devices) * input_capacity_MW(devices) *inflation_vec(years)/to_NPV(years));
                       input_FOM_costPERprod                 = sum(devices,input_FOM_cost2_vec(devices))/Total_product_sold;

                       renew_cap_cost2_vec(devices_ren) = -equity * renew_cap_cost(devices_ren) * Renewable_MW(devices_ren)  ;

                       renew_FOM_cost2_vec(devices_ren) = sum(years,-renew_FOM_cost(devices_ren) * Renewable_MW(devices_ren) *inflation_vec(years)/to_NPV(years));

                       TaxesPERprod                          = sum(years,yearly_taxes.l(years)/to_NPV(years))/Total_product_sold;

                       DebtsPERprod                          = sum(years,- debt_service.l/to_NPV(years))/Total_product_sold;

                       elec_cost_ren_vec(devices_ren)   = sum(years,sum(interval, elec_sale_price(interval) * renewable_power_MW_sold.l(interval,devices_ren) )*inflation_vec(years)/to_NPV(years));

                       renewable_sales                  = sum(devices_ren, elec_cost_ren_vec(devices_ren))*(1-%NEM_nscr%)
                                                        + sum(years,[sum((months,TOU_energy_period),(NSCR(months)-NBC)*electricity_surplus.l(months,TOU_energy_period))*(%NEM_nscr%)
                                                        + sum((months,TOU_energy_period),(TOU_energy_prices(TOU_energy_period)*[sum(interval$(month_interval(months,interval) and elec_TOU_bins(TOU_energy_period,interval) and rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index),
                                                         (sum(devices_ren,renewable_power_MW_sold.l(interval,devices_ren)*(1-esurplus_active.l(months,TOU_energy_period))*interval_length)))]))*(%NEM_nscr%)]*inflation_vec(years)/to_NPV(years));

                       Renewable_cap_costPERprod             = sum(devices_ren,renew_cap_cost2_vec(devices_ren))/Total_product_sold;
                       Renewable_FOM_costPERprod             = sum(devices_ren,renew_FOM_cost2_vec(devices_ren))/Total_product_sold;
                       Renewable_revenuePERprod              = (sum(years,(sum((interval,devices_ren), REC_price * renewable_power_MW_sold.l(interval,devices_ren)) * interval_length
                                                         + sum((interval,devices),output_power_MW_ren_sold.l(interval,devices)) * interval_length)*inflation_vec(years)/to_NPV(years)) + renewable_sales)
                                                        /Total_product_sold;
                       Renewable_cost                   = Renewable_cap_costPERprod + Renewable_FOM_costPERprod + Renewable_revenuePERprod;

                       product_revenue_vec(devices)          = sum(years,sum(interval$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ), product_price_adj(devices) * product_sold.l(interval,devices))*inflation_vec(years)/to_NPV(years));

                       product_break_even_cost               = LCFS_revenuePERprod + Energy_chargePERprod + Fixed_demand_chargePERprod + Timed_demand_chargePERprod + Meters_costPERprod + Storage_costPERprod
                                                        + Compressor_costPERprod +  input_cap_costPERprod + input_FOM_costPERprod + Renewable_cost + TaxesPERprod + DebtsPERprod;

                       epsilon = (sum(devices,product_price_adj(devices)) + product_break_even_cost)/sum(devices$(ord(devices) <= %devices_instance%),1) ;

                       product_price_adj(devices) = -product_break_even_cost ;
                       display product_price_adj, product_price ;
                           loop(devices,
                               if (product_use(devices) = 0,
                                    product_consumed(interval,devices) = product_consumed(interval,devices) * 0;
                                    product_price(interval,devices)    = product_price(interval,devices)*0;
                               elseif product_use(devices)=1,
                                    product_price(interval,devices) = product_price_init(interval,devices) ;
                                    product_price(interval,devices) = product_price(interval,devices) * product_price_adj(devices);
                                    if (CF_opt=0,
                                            product_consumed(interval,devices) = product_consumed(interval,devices) * CF_adjust(devices) * input_capacity_MW(devices) * input_efficiency(devices) / product_conversion * 24 * interval_length;
                                    elseif CF_opt=1,
                                            CF_adjust(devices) = input_capacity_MW(devices) * input_efficiency(devices) / product_conversion *24;
                                    );
                               elseif product_use(devices)=2,
                               );
                           );

* closing the while loop
                 );;
         elseif %run_opt_breakeven% = 0,

                 Solve arbitrage_and_AS using MIP maximizing operating_profit;
* closing the 'if sensitivity' condition for updating hydrogen break even cost
         );;

*        modelstat = 1 means optimal LP solution
*        modelstat = 6 means model ran out of time, feasible integer solution found but not yet optimal
*        modelstat = 8 means optimal integer solution found
         if( ( arbitrage_and_AS.modelstat=1 or arbitrage_and_AS.modelstat=8 ),
                 solve_index = solve_index + 1;

                 if ( arbitrage_and_AS.solvestat = 2 or arbitrage_and_AS.solvestat = 3,
                         optimal_solution_reached = 0;
                 );

         elseif ( arbitrage_and_AS.modelstat = 6 ),
                 solve_index = solve_index + 1;
                 optimal_solution_reached = 0;

         else
                 no_error = 0;
         );

);
*end of for loop
*===============================================================================
* Calculate Report Outputs
*===============================================================================
Scalars
         elec_in_MWh              MWh of electricity bought over the simulated time period
         elec_output_MWh          MWh of electricity sold over the simulated time period
         output_input_ratio       ratio of elec output to elec output
         input_capacity_factor    capacity factor for buying side of the facility
         output_capacity_factor   capacity factor for the selling side of the facility
         avg_regup_MW             average capacity sold to regup (MW per interval)
         avg_regdn_MW             average capacity sold to regdn (MW per interval)
         avg_spinres_MW           average capacity sold to spinning reserve (MW per interval)
         avg_nonspinres_MW        average capacity sold to nonspinning reserve (MW per interval)

         num_input_starts         number of compressor or input power system starts
         num_output_starts        number of turbine or output power system starts

         fuel_cost                cost of fuel (dollars)
         elec_cost                cost of electricity (dollars)
         elec_cost_ren            market value of renewable electricity sold to the grid (dollars)
         VOM_cost_val             cost of VOM (dollars)
         arbitrage_revenue        operating profits due to electricity purchases and sales (dollars)
         regup_revenue            operating profits due to regulation up AS market (dollars)
         regdn_revenue            operating profits due to regulation down AS market (dollars)
         spinres_revenue          operating profits due to spinning reserve AS market (dollars)
         nonspinres_revenue       operating profits due to nonspinning reserve AS market (dollars)
         product_revenue               operating profits due to selling hydrogen (dollars)
         REC_revenue              REC revenue ($)
         LCFS_revenue             LCSF revenue ($)
         startup_costs            cost due to startups
         Renewable_pen_input      renewable penetration of input device (%)
         Renewable_pen_input_net  renewable penetration of input device for net metering (%)

         Fixed_dem_charge_cost    Yearly Fixed demand charge cost
         Timed_dem_1_cost         Yearly Timed demand charge cost
         Timed_dem_2_cost         Yearly Timed demand charge cost
         Timed_dem_3_cost         Yearly Timed demand charge cost
         Timed_dem_4_cost         Yearly Timed demand charge cost
         Timed_dem_5_cost         Yearly Timed demand charge cost
         Timed_dem_6_cost         Yearly Timed demand charge cost
         Meter_cost               Yearly cost for operating meter

         renew_cap_cost2          capital cost
         input_cap_cost2          capital cost
         output_cap_cost2         capital cost
         renew_FOM_cost2          FOM cost
         input_FOM_cost2          FOM cost
         output_FOM_cost2         FOM cost
         renew_VOM_cost2          VOM cost
         input_VOM_cost2          VOM cost
         output_VOM_cost2         VOM cost
         ProdStor_cap_cost2       Product storage cost
         ProdComp_cap_cost2       Product additional equipment cost (compressor)
         product_fraction_val     Optimized Capacity Factor (%)
         curtailment_sum          Sum of curtailment over the region

         Fixed_dem_charge_cost_NPV NPV Fixed demand charge cost
         Timed_dem_1_cost_NPV      NPV Timed demand charge cost
         Timed_dem_2_cost_NPV      NPV Timed demand charge cost
         Timed_dem_3_cost_NPV      NPV Timed demand charge cost
         Timed_dem_4_cost_NPV      NPV Timed demand charge cost
         Timed_dem_5_cost_NPV      NPV Timed demand charge cost
         Timed_dem_6_cost_NPV      NPV Timed demand charge cost
         Meter_cost_NPV            NPV cost for operating meter
         fuel_cost_NPV             NPV cost of fuel (dollars)
         elec_cost_NPV             NPV cost of electricity (dollars)
         elec_cost_ren_NPV         NPV market value of renewable electricity sold to the grid (dollars)
         VOM_cost_val_NPV          NPV cost of VOM (dollars)
         arbitrage_revenue_NPV     NPV operating profits due to electricity purchases and sales (dollars)
         regup_revenue_NPV         NPV operating profits due to regulation up AS market (dollars)
         regdn_revenue_NPV         NPV operating profits due to regulation down AS market (dollars)
         spinres_revenue_NPV       NPV operating profits due to spinning reserve AS market (dollars)
         nonspinres_revenue_NPV    NPV operating profits due to nonspinning reserve AS market (dollars)
         product_revenue_NPV       NPV operating profits due to selling products (dollars)
         REC_revenue_NPV           NPV REC revenue ($)
         LCFS_revenue_NPV          NPV LCSF revenue ($)
         startup_costs_NPV         NPV cost due to startups
         renew_FOM_cost2_NPV       NPV FOM cost
         input_FOM_cost2_NPV       NPV FOM cost
         output_FOM_cost2_NPV      NPV FOM cost
         renew_VOM_cost2_NPV       NPV VOM cost
         input_VOM_cost2_NPV       NPV VOM cost
         output_VOM_cost2_NPV      NPV VOM cost
         renewable_sales_NPV       NPV renewable sales
         Taxes_NPV                 NPV taxes
         Debts_NPV                 NPV debts

         Storage_revenue          Track the storage revenue from the storage only (no renewable charging) ($)
         Renewable_only_revenue   Track the revenue portion from renewables ($)
         Renewable_max_revenue    Calculate the maximum revenue from renewables without any storage installed ($)
         Renewable_electricity_in Calculate the amount of renewable electricity coming in for sale and storage (MWh)
         Electricity_import       Calculate the amount of imported electricity (MWh)
         Total_elec_consumed      Calculate the total amount of electricity consumed (MWh)

         Debts_Renewable          Annualized debts related to the renewables source ($)
         Debts_Input              Annualized debts related to the input ($)
         Debts_StoNComp           Annualized debts related to the storage and compressor ($)
         Debts_RenewablePERprod   Annualized debts related to the renewables source per unit of product
         Debts_InputPERprod       Annualized debts related to the input per unit of product
         Debts_StoNCompPERprod    Annualized debts related to the storage and compressor per unit of product
         Debts_denominator        Interim step to check if denominator is zero
         Taxes_debt_int           Taxes which are calculated based on the debt interest ($)
         Taxes_debt_intPERprod    Taxes which are calculated based on the debt interest per unit of product
         actual_operating_profit_NPV

         num_elec_devices         Number of devices that consume electricity (e-buses)
         num_non_elec_devices     Number of devices that come from alternative cost and FOM (hybrid buses)
         elapsedtime              Total program run time (minutes)
;

Parameters
         Fixed_dem_charge_cost_yearly(years) NPV Fixed demand charge cost
         Timed_dem_1_cost_yearly(years)      NPV Timed demand charge cost
         Timed_dem_2_cost_yearly(years)      NPV Timed demand charge cost
         Timed_dem_3_cost_yearly(years)      NPV Timed demand charge cost
         Timed_dem_4_cost_yearly(years)      NPV Timed demand charge cost
         Timed_dem_5_cost_yearly(years)      NPV Timed demand charge cost
         Timed_dem_6_cost_yearly(years)      NPV Timed demand charge cost
         Meter_cost_yearly(years)            NPV cost for operating meter
         fuel_cost_yearly(years)             NPV cost of fuel (dollars)
         elec_cost_yearly(years)             NPV cost of electricity (dollars)
         elec_cost_ren_yearly(years)         NPV market value of renewable electricity sold to the grid (dollars)
         VOM_cost_val_yearly(years)          NPV cost of VOM (dollars)
         arbitrage_revenue_yearly(years)     NPV operating profits due to electricity purchases and sales (dollars)
         regup_revenue_yearly(years)         NPV operating profits due to regulation up AS market (dollars)
         regdn_revenue_yearly(years)         NPV operating profits due to regulation down AS market (dollars)
         spinres_revenue_yearly(years)       NPV operating profits due to spinning reserve AS market (dollars)
         nonspinres_revenue_yearly(years)    NPV operating profits due to nonspinning reserve AS market (dollars)
         product_revenue_yearly(years)            NPV operating profits due to selling hydrogen (dollars)
         REC_revenue_yearly(years)           NPV REC revenue ($)
         LCFS_revenue_yearly(years)          NPV LCSF revenue ($)
         startup_costs_yearly(years)         NPV cost due to startups
         renew_FOM_cost2_yearly(years)       NPV FOM cost
         input_FOM_cost2_yearly(years)       NPV FOM cost
         output_FOM_cost2_yearly(years)      NPV FOM cost
         renew_VOM_cost2_yearly(years)       NPV VOM cost
         input_VOM_cost2_yearly(years)       NPV VOM cost
         output_VOM_cost2_yearly(years)      NPV VOM cost
         renewable_sales_yearly(years)       NPV renewable sales
         Taxes_yearly(years)                 NPV taxes
         Debts_yearly(years)                 NPV debts
         actual_operating_profit_yearly(years)
;
*===============================================================================
* Curtailment, electricity and capacity sold/bought
*===============================================================================
curtailment(interval) = sum(devices_ren, Renewable_power(interval,devices_ren) - renewable_power_MW_sold.l(interval,devices_ren)) - sum(devices,input_power_MW_ren.l(interval,devices) - output_power_MW_ren_load.l(interval,devices)) - Load_profile_ren.l(interval);
curtailment_sum       = sum(interval, curtailment(interval) * interval_length );
elec_in_MWh           = sum((interval,devices), input_power_MW.l(interval,devices)  * interval_length );
elec_output_MWh       = sum((interval,devices), output_power_MW.l(interval,devices) * interval_length );

if( elec_in_MWh=0,
         output_input_ratio = inf;
else
         output_input_ratio = elec_output_MWh / elec_in_MWh;
);
if ( sum(devices, input_capacity_MW(devices) ) = 0,
         input_capacity_factor = 0;
else
         input_capacity_factor =  elec_in_MWh / sum(devices, input_capacity_MW(devices) * card(interval) * interval_length );
);
if ( sum(devices, output_capacity_MW(devices) ) = 0,
         output_capacity_factor = 0;
else
         output_capacity_factor = elec_output_MWh / sum(devices, output_capacity_MW(devices) * card(interval) * interval_length );
);

avg_regup_MW_vec(devices)      = sum(interval, output_regup_MW.l(interval,devices)      + input_regup_MW.l(interval,devices) )      / card(interval);
avg_regdn_MW_vec(devices)      = sum(interval, output_regdn_MW.l(interval,devices)      + input_regdn_MW.l(interval,devices) )      / card(interval);
avg_spinres_MW_vec(devices)    = sum(interval, output_spinres_MW.l(interval,devices)    + input_spinres_MW.l(interval,devices) )    / card(interval);
avg_nonspinres_MW_vec(devices) = sum(interval, output_nonspinres_MW.l(interval,devices) + input_nonspinres_MW.l(interval,devices) ) / card(interval);
avg_regup_MW      = sum(devices, avg_regup_MW_vec(devices));
avg_regdn_MW      = sum(devices, avg_regdn_MW_vec(devices));
avg_spinres_MW    = sum(devices, avg_spinres_MW_vec(devices));
avg_nonspinres_MW = sum(devices, avg_nonspinres_MW_vec(devices));

num_input_starts_vec(devices)  = sum(interval, input_start.l(interval,devices) );
num_output_starts_vec(devices) = sum(interval, output_start.l(interval,devices) );
num_input_starts  = sum(devices, num_input_starts_vec(devices));
num_output_starts = sum(devices, num_output_starts_vec(devices));

*===============================================================================
* Device - dependent revenues and charges
*===============================================================================
fuel_cost_vec(devices) = sum(interval,- output_heat_rate(devices) * NG_price(interval) * output_power_MW.l(interval,devices) * interval_length
                                      - input_heat_rate(devices)  * NG_price(interval) * input_power_MW.l(interval,devices)  * interval_length);

elec_cost_vec(devices) =   sum[interval,((elec_sale_price(interval)     * output_power_MW.l(interval,devices))
                                       - (elec_purchase_price(interval) * input_power_MW_non_ren.l(interval,devices))) * interval_length]*(1 - %NEM_nscr%)
* Elec cost when NEM is on:
                         + sum[(interval,months,TOU_energy_period)$(month_interval(months,interval) and elec_TOU_bins(TOU_energy_period,interval)),
                               (elec_sale_price(interval)   * (output_power_MW_non_ren_sold.l(interval,devices) + output_power_MW_ren_sold.l(interval,devices)) * (1-esurplus_active.l(months,TOU_energy_period)))
                              - elec_purchase_price(interval) * input_power_MW_non_ren.l(interval,devices) * (1-esurplus_active.l(months,TOU_energy_period)) * interval_length]*(%NEM_nscr%);

* Also repeat with renewables_sales_vec and simlar repeat with elec_cost_ren and renewables sales
elec_cost_ren_vec(devices_ren) = sum(interval, elec_sale_price(interval) * renewable_power_MW_sold.l(interval,devices_ren) * interval_length);
arbitrage_revenue_vec(devices) = elec_cost_vec(devices) + fuel_cost_vec(devices) + sum(interval,- VOM_cost * output_power_MW.l(interval,devices) * interval_length);
renewable_sales_vec(devices_ren) = sum(interval, elec_sale_price(interval) * renewable_power_MW_sold.l(interval,devices_ren) * interval_length );

renew_VOM_cost2_vec(devices_ren) = renew_VOM_cost(devices_ren)  * sum(interval, (renewable_signal(interval,devices_ren) * interval_length * Renewable_MW(devices_ren)));
regup_revenue_vec(devices)      = sum(interval, ( regup_price(interval) - reg_cost ) * ( output_regup_MW.l(interval,devices) + input_regup_MW.l(interval,devices) ) * interval_length );
regdn_revenue_vec(devices)      = sum(interval, ( regdn_price(interval) - reg_cost ) * ( output_regdn_MW.l(interval,devices) + input_regdn_MW.l(interval,devices) ) * interval_length );
spinres_revenue_vec(devices)    = sum(interval, spinres_price(interval) * ( output_spinres_MW.l(interval,devices) + input_spinres_MW.l(interval,devices) ) * interval_length );
nonspinres_revenue_vec(devices) = sum(interval, nonspinres_price(interval) * ( output_nonspinres_MW.l(interval,devices) + input_nonspinres_MW.l(interval,devices) ) * interval_length );
startup_costs_vec(devices)      = sum(interval, -(output_startup_cost(devices) * output_capacity_MW(devices) * output_start.l(interval,devices) + input_startup_cost(devices) * input_capacity_MW(devices) * input_start.l(interval,devices)) );
product_revenue_vec(devices)         = sum(interval, product_price(interval,devices) * product_sold.l(interval,devices));

renew_cap_cost2_vec(devices_ren) = -equity*renew_cap_cost(devices_ren) * Renewable_MW(devices_ren) ;
input_cap_cost2_vec(devices)     = -equity*(input_cap_cost(devices) * active_devices(devices) + input_cap_alt_cost(devices) * (1-active_devices(devices))) * input_capacity_MW(devices);
output_cap_cost2_vec(devices)    = -equity*output_cap_cost(devices)    * output_capacity_MW(devices);
ProdStor_cap_cost2_vec(devices)    = -equity*ProdStor_cap_cost(devices)    * input_capacity_MW(devices)  *  (input_efficiency(devices) / product_conversion ) * storage_capacity_hours(devices);
ProdComp_cap_cost2_vec(devices)    = -equity*ProdComp_cap_cost(devices)    * input_capacity_MW(devices)  *  (input_efficiency(devices) / product_conversion ) ;
renew_FOM_cost2_vec(devices_ren) = -renew_FOM_cost(devices_ren) * Renewable_MW(devices_ren)  ;
input_FOM_cost2_vec(devices)     = -(input_FOM_cost(devices) * active_devices(devices) + input_FOM_alt_cost(devices) * (1-active_devices(devices))) * input_capacity_MW(devices) ;
output_FOM_cost2_vec(devices)    = -output_FOM_cost(devices) * output_capacity_MW(devices);

*===============================================================================
* Annual revenues and charges
*===============================================================================
Fixed_dem_charge_cost    = -sum(months, Fixed_cap.l(months) * Fixed_dem(months));
Timed_dem_1_cost         = -sum(months, cap_1.l(months) * Timed_dem("1"));
Timed_dem_2_cost         = -sum(months, cap_2.l(months) * Timed_dem("2"));
Timed_dem_3_cost         = -sum(months, cap_3.l(months) * Timed_dem("3"));
Timed_dem_4_cost         = -sum(months, cap_4.l(months) * Timed_dem("4"));
Timed_dem_5_cost         = -sum(months, cap_5.l(months) * Timed_dem("5"));
Timed_dem_6_cost         = -sum(months, cap_6.l(months) * Timed_dem("6"));
Meter_cost               = -(meter_mnth_chg("1") * 12)*allow_import;

fuel_cost       = sum(devices, fuel_cost_vec(devices));
elec_cost       = sum(devices, elec_cost_vec(devices));
elec_cost_ren   = sum(devices_ren, elec_cost_ren_vec(devices_ren))*(1-%NEM_nscr%)
                + sum((months,TOU_energy_period),(NSCR(months)-NBC)*electricity_surplus.l(months,TOU_energy_period))*(%NEM_nscr%)
                + sum((months,TOU_energy_period),(TOU_energy_prices(TOU_energy_period)*[sum(interval$(month_interval(months,interval) and elec_TOU_bins(TOU_energy_period,interval) and rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index),
                 (sum(devices_ren,renewable_power_MW_sold.l(interval,devices_ren)*(1-esurplus_active.l(months,TOU_energy_period))*interval_length)))]))*(%NEM_nscr%)
                ;
arbitrage_revenue = sum(devices, arbitrage_revenue_vec(devices))
                  - sum(interval,elec_purchase_price(interval) * Load_profile_non_ren.l(interval))* interval_length*(1-%NEM_nscr%)
                  - sum((interval,months,TOU_energy_period)$(month_interval(months,interval) and elec_TOU_bins(TOU_energy_period,interval)),elec_purchase_price(interval) * Load_profile_non_ren.l(interval)*(1-esurplus_active.l(months,TOU_energy_period)))* interval_length*(%NEM_nscr%);
renewable_sales   = elec_cost_ren;

***** Have to add renewables that were sent through input devices
REC_revenue  = sum(interval, REC_price * (sum(devices_ren,renewable_power_MW_sold.l(interval,devices_ren)) * interval_length + sum(devices,output_power_MW_ren_sold.l(interval,devices))) * interval_length );
LCFS_revenue = sum((interval,devices),(CI_base_line*EER - Grid_CarbInt/input_efficiency(devices))*LCFS_price*EneDens*(power(10,-6)) * product_sold.l(interval,devices)
             + Grid_CarbInt*LCFS_price*EneDens*(power(10,-6)) * product_sold_ren.l(interval,devices) );
renew_cap_cost2  = sum(devices_ren, renew_cap_cost2_vec(devices_ren));
input_cap_cost2  = sum(devices, input_cap_cost2_vec(devices));
output_cap_cost2 = sum(devices, output_cap_cost2_vec(devices));
ProdStor_cap_cost2 = sum(devices, ProdStor_cap_cost2_vec(devices));
ProdComp_cap_cost2 = sum(devices, ProdComp_cap_cost2_vec(devices));

renew_FOM_cost2  = sum(devices_ren, renew_FOM_cost2_vec(devices_ren));
input_FOM_cost2  = sum(devices, input_FOM_cost2_vec(devices));
output_FOM_cost2 = sum(devices, output_FOM_cost2_vec(devices));

renew_VOM_cost2  = sum(devices_ren, renew_VOM_cost2_vec(devices_ren));
input_VOM_cost2  = -elec_in_MWh     * sum(devices, input_VOM_cost(devices));
output_VOM_cost2 = -elec_output_MWh * sum(devices, output_VOM_cost(devices));

regup_revenue      = sum(devices, regup_revenue_vec(devices));
regdn_revenue      = sum(devices, regdn_revenue_vec(devices));
spinres_revenue    = sum(devices, spinres_revenue_vec(devices));
nonspinres_revenue = sum(devices, nonspinres_revenue_vec(devices));
startup_costs      = sum(devices, startup_costs_vec(devices));
product_revenue    = sum(devices, product_revenue_vec(devices));
Taxes              = sum(years,yearly_taxes.l(years))/NoYears ;
Debts              = - debt_service.l ;

* Fraction of debt associated with each component
Debts_denominator =  (sum(devices_ren, renew_cap_cost(devices_ren) * Renewable_MW(devices_ren)) + sum(devices, (input_cap_cost(devices) * active_devices(devices) + input_cap_alt_cost(devices) * (1-active_devices(devices))) * input_capacity_MW(devices)) +
                     [sum(devices, ProdStor_cap_cost(devices) * input_capacity_MW(devices) *( input_efficiency(devices) / product_conversion )*storage_capacity_hours(devices))
                    + sum(devices, ProdComp_cap_cost(devices) * input_capacity_MW(devices) *( input_efficiency(devices) / product_conversion ))]) ;

if ( Debts_denominator = 0,
        Debts_Renewable = 0;
        Debts_Input = 0;
        Debts_StoNComp = 0;
else
        Debts_Renewable    =  sum(devices_ren, renew_cap_cost(devices_ren) * Renewable_MW(devices_ren))
                            /Debts_denominator;
        Debts_Input        =  sum(devices, (input_cap_cost(devices) * active_devices(devices) + input_cap_alt_cost(devices) * (1-active_devices(devices))) * input_capacity_MW(devices))
                            /Debts_denominator;
        Debts_StoNComp     = [sum(devices, ProdStor_cap_cost(devices) * input_capacity_MW(devices) *( input_efficiency(devices) / product_conversion )*storage_capacity_hours(devices))
                            + sum(devices, ProdComp_cap_cost(devices) * input_capacity_MW(devices) *( input_efficiency(devices) / product_conversion ))]
                            /Debts_denominator;
);

*** Converting active_devices to parameter
$ontext
Debts_Renewable    =  sum(devices_ren, renew_cap_cost(devices_ren) * Renewable_MW(devices_ren))
                    /(sum(devices_ren, renew_cap_cost(devices_ren) * Renewable_MW(devices_ren)) + sum(devices, (input_cap_cost(devices) * active_devices.l(devices) + input_cap_alt_cost(devices) * (1-active_devices(devices))) * input_capacity_MW(devices)) +
                     [sum(devices, ProdStor_cap_cost(devices) * input_capacity_MW(devices) *( input_efficiency(devices) / product_conversion )*storage_capacity_hours(devices))
                    + sum(devices, ProdComp_cap_cost(devices) * input_capacity_MW(devices) *( input_efficiency(devices) / product_conversion ))]) ;
Debts_Input        =  sum(devices, (input_cap_cost(devices) * active_devices.l(devices) + input_cap_alt_cost(devices) * (1-active_devices(devices))) * input_capacity_MW(devices))
                    /(sum(devices_ren, renew_cap_cost(devices_ren) * Renewable_MW(devices_ren)) + sum(devices, (input_cap_cost(devices) * active_devices.l(devices) + input_cap_alt_cost(devices) * (1-active_devices(devices))) * input_capacity_MW(devices)) +
                     [sum(devices, ProdStor_cap_cost(devices) * input_capacity_MW(devices) *( input_efficiency(devices) / product_conversion )*storage_capacity_hours(devices))
                    + sum(devices, ProdComp_cap_cost(devices) * input_capacity_MW(devices) *( input_efficiency(devices) / product_conversion ))]) ;
Debts_StoNComp     = [sum(devices, ProdStor_cap_cost(devices) * input_capacity_MW(devices) *( input_efficiency(devices) / product_conversion )*storage_capacity_hours(devices))
                    + sum(devices, ProdComp_cap_cost(devices) * input_capacity_MW(devices) *( input_efficiency(devices) / product_conversion ))]
                    /(sum(devices_ren, renew_cap_cost(devices_ren) * Renewable_MW(devices_ren)) + sum(devices, (input_cap_cost(devices) * active_devices.l(devices) + input_cap_alt_cost(devices) * (1-active_devices(devices))) * input_capacity_MW(devices)) +
                     [sum(devices, ProdStor_cap_cost(devices) * input_capacity_MW(devices) *( input_efficiency(devices) / product_conversion )*storage_capacity_hours(devices))
                    + sum(devices, ProdComp_cap_cost(devices) * input_capacity_MW(devices) *( input_efficiency(devices) / product_conversion ))]) ;
$offtext
*===============================================================================
* NPV revenues and charges
*===============================================================================

Fixed_dem_charge_cost_NPV= sum(years,Fixed_dem_charge_cost*inflation_vec(years)/to_NPV(years));
Timed_dem_1_cost_NPV     = sum(years,Timed_dem_1_cost*inflation_vec(years)/to_NPV(years));
Timed_dem_2_cost_NPV     = sum(years,Timed_dem_2_cost*inflation_vec(years)/to_NPV(years));
Timed_dem_3_cost_NPV     = sum(years,Timed_dem_3_cost*inflation_vec(years)/to_NPV(years));
Timed_dem_4_cost_NPV     = sum(years,Timed_dem_4_cost*inflation_vec(years)/to_NPV(years));
Timed_dem_5_cost_NPV     = sum(years,Timed_dem_5_cost*inflation_vec(years)/to_NPV(years));
Timed_dem_6_cost_NPV     = sum(years,Timed_dem_6_cost*inflation_vec(years)/to_NPV(years));
Meter_cost_NPV           = sum(years,Meter_cost*inflation_vec(years)/to_NPV(years));

fuel_cost_NPV       = sum(years,fuel_cost*inflation_vec(years)/to_NPV(years));
elec_cost_NPV       = sum(years,elec_cost*inflation_vec(years)/to_NPV(years));
elec_cost_ren_NPV   = sum(years,elec_cost_ren*inflation_vec(years)/to_NPV(years));

arbitrage_revenue_NPV = sum(years,arbitrage_revenue*inflation_vec(years)/to_NPV(years));
renewable_sales_NPV   = sum(years,elec_cost_ren*inflation_vec(years)/to_NPV(years));

***** Have to add renewables that were sent through input devices
REC_revenue_NPV  = sum(years,REC_revenue*inflation_vec(years)/to_NPV(years));
LCFS_revenue_NPV = sum(years,LCFS_revenue*inflation_vec(years)/to_NPV(years));

renew_FOM_cost2_NPV  = sum(years,renew_FOM_cost2*inflation_vec(years)/to_NPV(years));
input_FOM_cost2_NPV  = sum(years,input_FOM_cost2*inflation_vec(years)/to_NPV(years));
output_FOM_cost2_NPV = sum(years,output_FOM_cost2*inflation_vec(years)/to_NPV(years));

renew_VOM_cost2_NPV  = sum(years,renew_VOM_cost2*inflation_vec(years)/to_NPV(years));
input_VOM_cost2_NPV  = sum(years,input_VOM_cost2*inflation_vec(years)/to_NPV(years));
output_VOM_cost2_NPV = sum(years,output_VOM_cost2*inflation_vec(years)/to_NPV(years));

regup_revenue_NPV      = sum(years,regup_revenue*inflation_vec(years)/to_NPV(years));
regdn_revenue_NPV      = sum(years,regdn_revenue*inflation_vec(years)/to_NPV(years));
spinres_revenue_NPV    = sum(years,spinres_revenue*inflation_vec(years)/to_NPV(years));
nonspinres_revenue_NPV = sum(years,nonspinres_revenue*inflation_vec(years)/to_NPV(years));
startup_costs_NPV      = sum(years,startup_costs*inflation_vec(years)/to_NPV(years));
product_revenue_NPV    = sum(years,product_revenue*inflation_vec(years)/to_NPV(years));
*product_revenue_NPV = sum(devices,sum(years,sum(interval, product_price_adj(devices) * product_sold.l(interval,devices))*inflation_vec(years)/to_NPV(years)));
Parameter product_sold_years(years), product_price_NPV;
product_sold_years(years)    = sum((devices,interval)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ), (product_sold.l(interval,devices)))/to_NPV(years);
product_revenue_years(years) = sum((devices,interval)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ), product_price(interval,devices) * product_sold.l(interval,devices))*inflation_vec(years)/to_NPV(years);

* Added to prevent divide by zero 8/6/2019
if (sum(years,product_sold_years(years))=0,
    product_price_NPV = 0;
else
    product_price_NPV =  sum(years, product_revenue_years(years))/sum(years,product_sold_years(years));
);

display product_revenue_years, product_sold_years, product_price_NPV ;
* taxes shpuld not be inflated!
Taxes_NPV              = sum(years,yearly_taxes.l(years)/to_NPV(years)) ;
Debts_NPV              = sum(years,Debts/to_NPV(years)) ;

actual_operating_profit_NPV = arbitrage_revenue_NPV + regup_revenue_NPV + regdn_revenue_NPV + spinres_revenue_NPV + nonspinres_revenue_NPV + product_revenue_NPV - startup_costs_NPV
                        + Fixed_dem_charge_cost_NPV + Timed_dem_1_cost_NPV + Timed_dem_2_cost_NPV + Timed_dem_3_cost_NPV + Timed_dem_4_cost_NPV + Timed_dem_5_cost_NPV + Timed_dem_6_cost_NPV + Meter_cost_NPV
                        + input_cap_cost2 + output_cap_cost2 + input_FOM_cost2_NPV + output_FOM_cost2_NPV + input_VOM_cost2_NPV + output_VOM_cost2_NPV + renewable_sales_NPV
                        + renew_cap_cost2 + renew_FOM_cost2_NPV + renew_VOM_cost2_NPV + ProdStor_cap_cost2 + ProdComp_cap_cost2 + REC_revenue_NPV + LCFS_revenue_NPV + Taxes_NPV + Debts_NPV;
*===============================================================================
* Yearly revenues and charges
*===============================================================================
Fixed_dem_charge_cost_yearly(years)= Fixed_dem_charge_cost*inflation_vec(years);
Timed_dem_1_cost_yearly(years)     = Timed_dem_1_cost*inflation_vec(years);
Timed_dem_2_cost_yearly(years)     = Timed_dem_2_cost*inflation_vec(years);
Timed_dem_3_cost_yearly(years)     = Timed_dem_3_cost*inflation_vec(years);
Timed_dem_4_cost_yearly(years)     = Timed_dem_4_cost*inflation_vec(years);
Timed_dem_5_cost_yearly(years)     = Timed_dem_5_cost*inflation_vec(years);
Timed_dem_6_cost_yearly(years)     = Timed_dem_6_cost*inflation_vec(years);
Meter_cost_yearly(years)           = Meter_cost*inflation_vec(years);

fuel_cost_yearly(years)       = fuel_cost*inflation_vec(years);
elec_cost_yearly(years)       = elec_cost*inflation_vec(years);
elec_cost_ren_yearly(years)   = elec_cost_ren*inflation_vec(years);

arbitrage_revenue_yearly(years) = arbitrage_revenue*inflation_vec(years);
renewable_sales_yearly(years)   = elec_cost_ren*inflation_vec(years);

REC_revenue_yearly(years)  = REC_revenue*inflation_vec(years);
LCFS_revenue_yearly(years) = LCFS_revenue*inflation_vec(years);

renew_FOM_cost2_yearly(years)  = renew_FOM_cost2*inflation_vec(years);
input_FOM_cost2_yearly(years)  = input_FOM_cost2*inflation_vec(years);
output_FOM_cost2_yearly(years) = output_FOM_cost2*inflation_vec(years);

renew_VOM_cost2_yearly(years)  = renew_VOM_cost2*inflation_vec(years);
input_VOM_cost2_yearly(years)  = input_VOM_cost2*inflation_vec(years);
output_VOM_cost2_yearly(years) = output_VOM_cost2*inflation_vec(years);

regup_revenue_yearly(years)      = regup_revenue*inflation_vec(years);
regdn_revenue_yearly(years)      = regdn_revenue*inflation_vec(years);
spinres_revenue_yearly(years)    = spinres_revenue*inflation_vec(years);
nonspinres_revenue_yearly(years) = nonspinres_revenue*inflation_vec(years);
startup_costs_yearly(years)      = startup_costs*inflation_vec(years);
product_revenue_yearly(years)         = product_revenue*inflation_vec(years);

Parameter product_sold_yearly(years), product_price_yearly(years);
product_sold_yearly(years)    = sum((devices,interval)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ), (product_sold.l(interval,devices)));
product_revenue_yearly2(years) = sum((devices,interval)$( rolling_window_min_index <= ord(interval) and ord(interval) <= rolling_window_max_index ), product_price(interval,devices) * product_sold.l(interval,devices))*inflation_vec(years);

* Added to prevent divide by zero 8/6/2019
if (sum(years,product_sold_yearly(years))=0,
    product_price_yearly(years) = 0;
else
    product_price_yearly(years) = product_revenue_yearly2(years)/product_sold_yearly(years);
);
display product_revenue_yearly2, product_sold_yearly, product_price_yearly ;
* taxes should not be inflated!
Taxes_yearly(years)  = yearly_taxes.l(years);
Debts_yearly(years)  = Debts;


* Capital cost itmes in "actual_operating_profit_yearly" should be in year 0 but for debugging they are currently in year 1
Parameters year_one_multiplier(years)  Use to charge for capital cost in year 1 /1 1/;

actual_operating_profit_yearly(years) = arbitrage_revenue_yearly(years) + regup_revenue_yearly(years) + regdn_revenue_yearly(years) + spinres_revenue_yearly(years) + nonspinres_revenue_yearly(years) + product_revenue_yearly(years) - startup_costs_yearly(years)
                        + Fixed_dem_charge_cost_yearly(years) + Timed_dem_1_cost_yearly(years) + Timed_dem_2_cost_yearly(years) + Timed_dem_3_cost_yearly(years) + Timed_dem_4_cost_yearly(years) + Timed_dem_5_cost_yearly(years) + Timed_dem_6_cost_yearly(years) + Meter_cost_yearly(years)
                        + [input_cap_cost2 + output_cap_cost2 + renew_cap_cost2 + ProdStor_cap_cost2 + ProdComp_cap_cost2]*year_one_multiplier(years) + input_FOM_cost2_yearly(years) + output_FOM_cost2_yearly(years) + input_VOM_cost2_yearly(years) + output_VOM_cost2_yearly(years) + renewable_sales_yearly(years)
                        + renew_FOM_cost2_yearly(years) + renew_VOM_cost2_yearly(years) + REC_revenue_yearly(years) + LCFS_revenue_yearly(years) + Taxes_yearly(years) + Debts_yearly(years);

*===============================================================================
* Hydrogen break-even cost breakdown
*===============================================================================
product_fraction_val = product_fraction.l*100;

if ( sum((interval,devices),input_power_MW.l(interval,devices))=0,
         Renewable_pen_input = 0;
         Renewable_pen_input = 0;
else
         Renewable_pen_input = sum((interval,devices),input_power_MW_ren.l(interval,devices)) / sum((interval,devices),input_power_MW.l(interval,devices));
         Renewable_pen_input_net = sum((interval,devices_ren),Renewable_power(interval,devices_ren) )/sum((interval,devices),input_power_MW.l(interval,devices));
);
if (Renewable_pen_input_net>1,
         Renewable_pen_input_net=1;
);

Total_product_sold = sum(years,sum((interval,devices),product_sold.l(interval,devices))/to_NPV(years));
***display product_sold.l;
display Total_product_sold;
Storage_revenue_vec(devices) = sum(interval,(output_power_MW.l(interval,devices) - input_power_MW.l(interval,devices)) * interval_length * elec_sale_price(interval));
Storage_revenue = sum((years,devices), Storage_revenue_vec(devices)*inflation_vec(years)/to_NPV(years));
Renewable_only_revenue = sum(years,[sum(interval, (sum(devices,input_power_MW.l(interval,devices) - input_power_MW_non_ren.l(interval,devices))+sum(devices_ren, renewable_power_MW_sold.l(interval,devices_ren))) * interval_length  * elec_sale_price(interval))]*inflation_vec(years)/to_NPV(years));
Renewable_max_revenue    = sum(years,sum(interval,( sum(devices_ren,renewable_signal(interval,devices_ren)*Renewable_MW(devices_ren)) - (abs(sum(devices_ren,renewable_signal(interval,devices_ren)*Renewable_MW(devices_ren))-max_sys_output_cap)-max_sys_output_cap) )/2 * interval_length  * elec_sale_price(interval))/to_NPV(years));
Renewable_electricity_in = sum(interval, sum(devices,input_power_MW_ren.l(interval,devices)) + sum(devices_ren,renewable_power_MW_sold.l(interval,devices_ren)) ) * interval_length;
Input_elec_import_vec(devices) = sum(interval,input_power_MW_non_ren.l(interval,devices)) * interval_length;
Electricity_import = sum(interval, Import_elec_profile.l(interval)) * interval_length;
Total_elec_consumed = sum(interval, sum(devices,input_power_MW.l(interval,devices)) + Load_profile(interval)) * interval_length;
storage_level_MWh_tot(interval,devices) = storage_level_MWh.l(interval,devices)+storage_level_MWh_ren.l(interval,devices);

if (Total_product_sold=0,
         LCFS_revenuePERprod          = 0;
         Energy_chargePERprod         = 0;
         Fixed_demand_chargePERprod   = 0;
         Timed_demand_chargePERprod   = 0;
         Meters_costPERprod           = 0;
         Storage_costPERprod          = 0;
         Compressor_costPERprod       = 0;
         input_cap_costPERprod        = 0;
         input_FOM_costPERprod        = 0;
         Renewable_cap_costPERprod    = 0;
         Renewable_FOM_costPERprod    = 0;
         Renewable_revenuePERprod     = 0;
         Renewable_cost          = 0;
         TaxesPERprod                 = 0;
         DebtsPERprod                 = 0;
         product_break_even_cost      = 0;
else
         LCFS_revenuePERprod          = LCFS_revenue_NPV/Total_product_sold;
         Energy_chargePERprod         = arbitrage_revenue_NPV/Total_product_sold;
         Fixed_demand_chargePERprod   = Fixed_dem_charge_cost_NPV/Total_product_sold;
         Timed_demand_chargePERprod   = (Timed_dem_1_cost_NPV + Timed_dem_2_cost_NPV + Timed_dem_3_cost_NPV + Timed_dem_4_cost_NPV + Timed_dem_5_cost_NPV + Timed_dem_6_cost_NPV)/Total_product_sold;
         Meters_costPERprod           = Meter_cost_NPV /Total_product_sold;
         Storage_costPERprod          = ProdStor_cap_cost2/Total_product_sold;
         Compressor_costPERprod       = ProdComp_cap_cost2/Total_product_sold;
         input_cap_costPERprod        = input_cap_cost2/Total_product_sold;
         input_FOM_costPERprod        = input_FOM_cost2_NPV/Total_product_sold;
         Renewable_cap_costPERprod    = renew_cap_cost2/Total_product_sold;
         Renewable_FOM_costPERprod    = renew_FOM_cost2_NPV/Total_product_sold;
         Renewable_revenuePERprod     = sum(years, renewable_sales + (sum(interval, REC_price * sum(devices_ren,renewable_power_MW_sold.l(interval,devices_ren)) * interval_length + sum(devices,output_power_MW_ren_sold.l(interval,devices)) * interval_length ))*inflation_vec(years)/to_NPV(years))
                                   /Total_product_sold;
*        Appears this doesn't take into account non-ren revenue for other output devices (see previous).
         Renewable_cost          = Renewable_cap_costPERprod + Renewable_FOM_costPERprod + Renewable_revenuePERprod;
         TaxesPERprod                 = Taxes_NPV/Total_product_sold;
         DebtsPERprod                 = Debts_NPV/Total_product_sold;
         product_break_even_cost      = LCFS_revenuePERprod + Energy_chargePERprod + Fixed_demand_chargePERprod + Timed_demand_chargePERprod + Meters_costPERprod + Storage_costPERprod
                                 + Compressor_costPERprod + input_cap_costPERprod + input_FOM_costPERprod + Renewable_cost + TaxesPERprod + DebtsPERprod;
);

num_elec_devices = sum(devices,active_devices(devices));
num_non_elec_devices = card(devices) - sum(devices,active_devices(devices));

elapsedtime = (jnow - starttime)*24*60;

if (1=0,
option decimals=8;
display fuel_cost_vec;
display elec_cost_vec;
display product_revenue_vec;
display regup_revenue_vec;
display regdn_revenue_vec;
display spinres_revenue_vec;
display nonspinres_revenue_vec;
display arbitrage_revenue_vec;
display product_fraction_val;
display current_interval;
display next_interval;
display current_storage_lvl;
display current_monthly_max;
display max_interval;
);
if (1=0,
option decimals=8;
display CF_incremental_change.l;
display num_elec_devices;
display num_non_elec_devices;
display active_devices;
display renewable_power_MW_sold.l;
display Load_profile_ren.l;
display Load_profile_non_ren.l;
);

if (1=0,
option decimals=8;
display CF_incremental_change.l;
display product_sold_ren.l
display product_sold_non_ren.l
display product_consumed);


if (1=0,
option decimals=8;
display output_power_MW.l
display output_power_MW_non_ren_sold.l
display output_power_MW_non_ren_load.l
display output_power_MW_ren_sold.l
display output_power_MW_ren_load.l
);


*===============================================================================
* - - - - write output to files - - - -
*===============================================================================
scalar max_max_cap; max_max_cap = max(smax(devices,input_capacity_MW(devices)),smax(devices,output_capacity_MW(devices)));
* Create Dynamic set     (1. Create a large set, 2. Find the max dimension, 3. Create a new set as a subset, 4. Limit the subset to the max dimension
set most_devices_limit /1*10000/;
scalar most_devices; most_devices = max(card(devices),card(devices_ren))
set most_devices_set(most_devices_limit);
most_devices_set(most_devices_limit)$(ord(most_devices_limit) <= most_devices) = yes;
Parameter
    Output_power_sold(interval,devices)
    Output_power_load(interval,devices)
;
Output_power_sold(interval,devices) = output_power_MW_non_ren_sold.l(interval,devices)+output_power_MW_ren_sold.l(interval,devices);
Output_power_load(interval,devices) = output_power_MW_non_ren_load.l(interval,devices)+output_power_MW_ren_load.l(interval,devices);


if( (arbitrage_and_AS.modelstat=1 or arbitrage_and_AS.modelstat=2 or arbitrage_and_AS.modelstat=8),

         if ( max_max_cap>100, input_echo_file.nd = 2; else input_echo_file.nd = 4; );
         input_echo_file.pw = 10000;
         put input_echo_file;
                 PUT 'Run on a %system.filesys% machine on %system.date% %system.time%.' /;
                 put 'Optimal solution found within time limit:,',
                 if ( optimal_solution_reached = 1,
                         put 'Yes' /;
                 else
                         put 'No' /;
                 );
                 put /;
                 put 'interval length (hours), ',        interval_length /;
                 put 'operating period length (hours), ' operating_period_length /;
                 put 'additional look-ahead (hours), '   look_ahead_length /;
                 put 'output capacity (MW), ',           sum(devices, output_capacity_MW(devices)) /;
                 put 'input capacity (MW), ',            sum(devices, input_capacity_MW(devices))   /;
                 put 'storage capacity (hours), ',       sum(devices, storage_capacity_hours(devices)) /;
                 put 'input efficiency (%), ',           sum(devices, input_efficiency(devices)) /;
                 put 'output efficiency (%), ',          sum(devices, output_efficiency(devices)) /;
                 put 'input heat rate (MMBtu/MWh), ',    sum(devices, input_heat_rate(devices)) /;
                 put 'ouptut heat rate (MMBtu/MWh), ',   sum(devices, output_heat_rate(devices)) /;
                 put 'variable O&M cost, ',              VOM_cost /;
                 put 'regulation cost, ',                reg_cost /;
                 put 'hydrogen use, ',                   sum(devices, product_use(devices)) /;
                 put /;
                 put 'input' /;
                 put 'LSL limit fraction, ',             sum(devices, input_LSL_fraction(devices)) /;
                 put 'reg up limit fraction, ',          sum(devices, input_regup_limit_fraction(devices)) /;
                 put 'reg down limit fraction, ',        sum(devices, input_regdn_limit_fraction(devices)) /;
                 put 'spining reserve limit fraction, ', sum(devices, input_spinres_limit_fraction(devices)) /;
                 put 'startup cost ($/MW-start), ',      sum(devices, input_startup_cost(devices)):0:10 /;
                 put 'minimum run intervals, '           min_input_on_intervals /;
                 put /;
                 put 'output' /;
                 put 'LSL limit fraction, ',             sum(devices, output_LSL_fraction(devices)) /;
                 put 'reg up limit fraction, ',          sum(devices, output_regup_limit_fraction(devices)) /;
                 put 'reg down limit fraction, ',        sum(devices, output_regdn_limit_fraction(devices)) /;
                 put 'spining reserve limit fraction, ', sum(devices, output_spinres_limit_fraction(devices)) /;
                 put 'startup cost ($/MW-start), ',      sum(devices, output_startup_cost(devices)):0:10 /;
                 put 'minimum run intervals, ',          min_output_on_intervals /;
                 put /;
                 put 'Int,Elec Purchase ($/MWh),Elec Sale ($/MWh),Reg Up ($/MW),Reg Dn ($/MW),Spin Res ($/MW),Nonspin Res ($/MW),Nat Gas ($/MMBTU),Product ($/product unit),Renewable In (MW),Load Profile (MW),Input Cap, Output Cap,Meter ($/mth)' /;
                 loop(interval, put      ord(interval),',',
                                         elec_purchase_price(interval),',',
                                         elec_sale_price(interval),',',
                                         regup_price(interval),',',
                                         regdn_price(interval),',',
                                         spinres_price(interval),',',
                                         nonspinres_price(interval),',',
                                         NG_price(interval),',',
                                         sum(devices, product_price(interval,devices)),',',
                                         sum(devices_ren, Renewable_power(interval,devices_ren)),',',
                                         Load_profile(interval),',',
                                         sum(devices, Max_input_cap(interval,devices)),',',
                                         sum(devices, Max_output_cap(interval,devices)),',',
                                         meter_mnth_chg(interval) /;
                 );

         if ( max_max_cap>100, results_file.nd = 2; elseif max_max_cap>10, results_file.nd = 4; elseif max_max_cap>0.1, results_file.nd = 6; else results_file.nd = 8;);
         results_file.pw = 10000;
         put results_file;
                 PUT 'Run on a %system.filesys% machine on %system.date% %system.time%.' /;
                 put 'Optimal solution found within time limit:,',
                 if ( optimal_solution_reached = 1,
                         put 'Yes' /;
                 else
                         put 'No' /;
                 );
                 put /;
                 put 'Renewable Capacity (MW), ',                sum(devices_ren, Renewable_MW(devices_ren)) /;
                 put 'Renewable Penetration for Input (%), ',    Renewable_pen_input /;
                 put 'hydrogen use, ',                           sum(devices, product_use(devices)) /;
                 put /;
                 put 'NPV of actual operating profit, ',         actual_operating_profit_NPV /;
                 put 'total electricity input (MWh), ',          elec_in_MWh /;
                 put 'total electricity output (MWh), ',         elec_output_MWh /;
                 put 'output to input ratio, ',                  output_input_ratio /;
                 put 'input capacity factor, ',                  input_capacity_factor /;
                 put 'output capacity factor, ',                 output_capacity_factor /;
                 put 'average regup (MW), ',                     avg_regup_MW /;
                 put 'average regdn (MW), ',                     avg_regdn_MW /;
                 put 'average spinres (MW), ',                   avg_spinres_MW /;
                 put 'average nonspinres (MW), ',                avg_nonspinres_MW /;
                 put 'number of input power system starts, ',    num_input_starts /;
                 put 'number of output power system starts, ',   num_output_starts /;
                 put 'arbitrage revenue ($),',                   arbitrage_revenue /;
                 put 'regup revenue ($), ',                      regup_revenue /;
                 put 'regdn revenue ($), ',                      regdn_revenue /;
                 put 'spinres revenue ($), ',                    spinres_revenue /;
                 put 'nonspinres revenue ($), ',                 nonspinres_revenue /;
                 put 'hydrogen revenue ($), ',                   product_revenue /;
                 put 'REC revenue ($), ',                        REC_revenue /;
                 put 'LCFS revenue ($), ',                       LCFS_revenue /;
                 put 'startup costs ($), ',                      startup_costs /;
                 put /;
                 put 'Interval,Input Power (MW),Output Power (MW),Storage Level (MW-h),Input Reg Up (MW),Output Reg Up (MW),Input Reg Dn (MW),Output Reg Dn (MW),Input Spin (MW),Output Spin (MW),Input Nonspin (MW),Output Nonspin (MW),'
                 put 'Product Sold (units of product),Non-Ren Import (MW),Load Profile (MW),Renewable Input (MW),Renewables Sold (MW),Curtailment (MW)'/;
                 loop(interval, put      ord(interval),',',
                                         sum(devices, input_power_MW.l(interval,devices)),',',
                                         sum(devices, output_power_MW.l(interval,devices)),',',
                                         sum(devices, storage_level_MWh_tot(interval,devices)),',',
                                         sum(devices, input_regup_MW.l(interval,devices)),',',
                                         sum(devices, output_regup_MW.l(interval,devices)),',',
                                         sum(devices, input_regdn_MW.l(interval,devices)),',',
                                         sum(devices, output_regdn_MW.l(interval,devices)),',',
                                         sum(devices, input_spinres_MW.l(interval,devices)),',',
                                         sum(devices, output_spinres_MW.l(interval,devices)),',',
                                         sum(devices, input_nonspinres_MW.l(interval,devices)),',',
                                         sum(devices, output_nonspinres_MW.l(interval,devices)),',',
                                         sum(devices, product_sold.l(interval,devices)),',',
                                         Import_elec_profile.l(interval),',',
                                         Load_profile(interval),',',
                                         sum(devices_ren, Renewable_power(interval,devices_ren)),',',
                                         sum(devices_ren, renewable_power_MW_sold.l(interval,devices_ren)),',',
                                         curtailment(interval) /;
                 );

         summary_file.nd = 8;
         put summary_file;
                 PUT 'Run on a %system.filesys% machine on %system.date% %system.time%.' /;
                 put 'Elapsed Time (minutes):,',                 elapsedtime /;
                 put /;
                 put 'Renewable Capacity (MW), ',                sum(devices_ren, Renewable_MW(devices_ren)) /;
                 put 'Renewable Penetration for Input (%), ',    Renewable_pen_input /;
                 put 'interval length (hours), ',                interval_length /;
                 put 'operating period length (hours), '         operating_period_length /;
                 put 'additional look-ahead (hours), '           look_ahead_length /;
                 put 'output capacity (MW), ',                   sum(devices, output_capacity_MW(devices)) /;
                 put 'input capacity (MW), ',                    sum(devices, input_capacity_MW(devices))   /;
                 put 'storage capacity (hours), ',               sum(devices, storage_capacity_hours(devices)) /;
                 put 'input efficiency (%), ',                   sum(devices, input_efficiency(devices)) /;
                 put 'output efficiency (%), ',                  sum(devices, output_efficiency(devices)) /;
                 put 'input heat rate (MMBtu/MWh), ',            sum(devices, input_heat_rate(devices)) /;
                 put 'ouptut heat rate (MMBtu/MWh), ',           sum(devices, output_heat_rate(devices)) /;
                 put 'variable O&M cost, ',                      VOM_cost /;
                 put 'regulation cost, ',                        reg_cost /;
                 put 'hydrogen use, ',                           sum(devices, product_use(devices)) /;
                 put /;
                 put 'input' /;
                 put 'LSL limit fraction, ',                     sum(devices, input_LSL_fraction(devices)) /;
                 put 'reg up limit fraction, ',                  sum(devices, input_regup_limit_fraction(devices)) /;
                 put 'reg down limit fraction, ',                sum(devices, input_regdn_limit_fraction(devices)) /;
                 put 'spining reserve limit fraction, ',         sum(devices, input_spinres_limit_fraction(devices)) /;
                 put 'startup cost ($/MW-start), ',              sum(devices, input_startup_cost(devices)):0:10 /;
                 put 'minimum run intervals, '                   min_input_on_intervals /;
                 put /;
                 put 'output' /;
                 put 'LSL limit fraction, ',                     sum(devices, output_LSL_fraction(devices)) /;
                 put 'reg up limit fraction, ',                  sum(devices, output_regup_limit_fraction(devices)) /;
                 put 'reg down limit fraction, ',                sum(devices, output_regdn_limit_fraction(devices)) /;
                 put 'spining reserve limit fraction, ',         sum(devices, output_spinres_limit_fraction(devices)) /;
                 put 'startup cost ($/MW-start), ',              sum(devices, output_startup_cost(devices)):0:10 /;
                 put 'minimum run intervals, ',                  min_output_on_intervals /;
                 put /;
                 put 'total electricity input (MWh), ',          elec_in_MWh /;
                 put 'total electricity output (MWh), ',         elec_output_MWh /;
                 put 'output to input ratio, ',                  output_input_ratio /;
                 put 'input capacity factor, ',                  input_capacity_factor /;
                 put 'output capacity factor, ',                 output_capacity_factor /;
                 put 'average regup (MW), ',                     avg_regup_MW /;
                 put 'average regdn (MW), ',                     avg_regdn_MW /;
                 put 'average spinres (MW), ',                   avg_spinres_MW /;
                 put 'average nonspinres (MW), '                 avg_nonspinres_MW /;
                 put 'number of input power system starts, ',    num_input_starts /;
                 put 'number of output power system starts, ',   num_output_starts /;
                 put 'arbitrage revenue ($),',                   arbitrage_revenue /;
                 put 'regup revenue ($), ',                      regup_revenue /;
                 put 'regdn revenue ($), ',                      regdn_revenue /;
                 put 'spinres revenue ($), ',                    spinres_revenue /;
                 put 'nonspinres revenue ($), ',                 nonspinres_revenue /;
                 put 'hydrogen revenue ($), ',                   product_revenue /;
                 put 'REC revenue ($), ',                        REC_revenue /;
                 put 'LCFS revenue ($), ',                       LCFS_revenue /;
                 put 'startup costs ($), ',                      startup_costs /;
                 put 'Fixed demand charge ($), ',                Fixed_dem_charge_cost/;
                 put 'Timed demand charge 1 ($), ',              Timed_dem_1_cost/;
                 put 'Timed demand charge 2 ($), ',              Timed_dem_2_cost/;
                 put 'Timed demand charge 3 ($), ',              Timed_dem_3_cost/;
                 put 'Timed demand charge 4 ($), ',              Timed_dem_4_cost/;
                 put 'Timed demand charge 5 ($), ',              Timed_dem_5_cost/;
                 put 'Timed demand charge 6 ($), ',              Timed_dem_6_cost/;
                 put 'Meter cost ($), ',                         Meter_cost/;
                 put 'Renewable sales ($), ',                    renewable_sales /;
                 put 'Renewable FOM cost ($), ',                 renew_FOM_cost2 /;
                 put 'Input FOM cost ($), ',                     input_FOM_cost2 /;
                 put 'Output FOM cost ($), ',                    output_FOM_cost2 /;
                 put 'Renewable VOM cost ($), ',                 renew_VOM_cost2 /;
                 put 'Input VOM cost ($), ',                     input_VOM_cost2 /;
                 put 'Output VOM cost ($), ',                    output_VOM_cost2 /;
                 put 'Debts ($),',                               Debts / ;
                 put 'Taxes ($),',                               Taxes /;
                 put 'Renewable capital cost ($), ',             renew_cap_cost2 /;
                 put 'Input capital cost ($), ',                 input_cap_cost2 /;
                 put 'Output capital cost ($), ',                output_cap_cost2 /;
                 put 'Hydrogen storage cost ($), ',              ProdStor_cap_cost2 /;
                 put 'Hydrogen compressor cost ($), '            ProdComp_cap_cost2 /;
                 put 'NPV arbitrage revenue ($),',               arbitrage_revenue_NPV /;
                 put 'NPV regup revenue ($), ',                  regup_revenue_NPV /;
                 put 'NPV regdn revenue ($), ',                  regdn_revenue_NPV /;
                 put 'NPV spinres revenue ($), ',                spinres_revenue_NPV /;
                 put 'NPV nonspinres revenue ($), ',             nonspinres_revenue_NPV /;
                 put 'NPV of hydrogen revenue ($), ',            product_revenue_NPV /;
                 put 'NPV of REC revenue ($), ',                 REC_revenue_NPV /;
                 put 'NPV of LCFS revenue ($), ',                LCFS_revenue_NPV /;
                 put 'NPV of startup costs ($), ',               startup_costs_NPV /;
                 put 'NPV of Fixed demand charge ($), ',         Fixed_dem_charge_cost_NPV/;
                 put 'NPV of Timed demand charge 1 ($), ',       Timed_dem_1_cost_NPV/;
                 put 'NPV of Timed demand charge 2 ($), ',       Timed_dem_2_cost_NPV/;
                 put 'NPV of Timed demand charge 3 ($), ',       Timed_dem_3_cost_NPV/;
                 put 'NPV of Timed demand charge 4 ($), ',       Timed_dem_4_cost_NPV/;
                 put 'NPV of Timed demand charge 5 ($), ',       Timed_dem_5_cost_NPV/;
                 put 'NPV of Timed demand charge 6 ($), ',       Timed_dem_6_cost_NPV/;
                 put 'NPV of Meter cost ($), ',                  Meter_cost_NPV/;
                 put 'NPV Renewable sales ($), ',                renewable_sales_NPV /;
                 put 'NPV Renewable FOM cost ($), ',             renew_FOM_cost2_NPV /;
                 put 'NPV Input FOM cost ($), ',                 input_FOM_cost2_NPV /;
                 put 'NPV Output FOM cost ($), ',                output_FOM_cost2_NPV /;
                 put 'NPV Renewable VOM cost ($), ',             renew_VOM_cost2_NPV /;
                 put 'NPV Input VOM cost ($), ',                 input_VOM_cost2_NPV /;
                 put 'NPV Output VOM cost ($), ',                output_VOM_cost2_NPV /;
                 put 'NPV of Debts ($),',                        Debts_NPV / ;
                 put 'NPV of Taxes ($),',                        Taxes_NPV /;
                 put 'NPV of actual operating profit ($), ',     actual_operating_profit_NPV /;
                 put 'Renewable Penetration net meter (%), ',    Renewable_pen_input_net /;
                 put 'Curtailment (MWh), ',                      curtailment_sum /;
                 put 'Storage revenue ($), ',                    Storage_revenue /;
                 put 'Renewable only revenue ($), ',             Renewable_only_revenue /;
                 put 'Renewable max revenue ($), ',              Renewable_max_revenue /;
                 put 'Renewable Electricity Input (MWh), ',      Renewable_electricity_in /;
                 put 'Electricity Import (MWh), ',               Electricity_import /;
                 put 'Total Electricity Consumed (MWh), ',       Total_elec_consumed /;
                 put 'Yearly Debt service ($), ',                (debt_service.l) /;
                 put 'WACC, ',                                   (wacc) /;
                 put 'Num of e-devices, ',                       (num_elec_devices) /;
                 put 'Num of non-e-devices, ',                   (num_non_elec_devices) /;
                 put /
                 put 'Product cost breakdown (US$/kg)' /;
                 put 'LCFS_FCEV (US$/kg),',                      (- LCFS_revenuePERprod) /;
                 put 'Renewable revenue(US$/kg),',               (- Renewable_revenuePERprod) /;
                 put 'Energy charge (US$/kg),',                  (- Energy_chargePERprod) /;
                 put 'Fixed demand charge (US$/kg),',            (- Fixed_demand_chargePERprod) /;
                 put 'Timed demand charge (US$/kg),',            (- Timed_demand_chargePERprod) /;
                 put 'Meters cost (US$/kg),',                    (- Meters_costPERprod) /;
                 put 'Storage & compression cost (US$/kg),',     (- Storage_costPERprod - Compressor_costPERprod - Debts_StoNComp*DebtsPERprod) /;
                 put 'Input CAPEX (US$/kg),',                    (-input_cap_costPERprod - Debts_Input*DebtsPERprod) /;
                 put 'Input FOM (US$/kg),',                      (-input_FOM_costPERprod) /;
                 put 'Renewable capital cost (US$/kg),',         (-Renewable_cap_costPERprod - Debts_Renewable*DebtsPERprod) /;
                 put 'Renewable FOM (US$/kg),',                  (-Renewable_FOM_costPERprod) /;
                 put 'Taxes (US$/kg),',                          (-TaxesPERprod) /;
                 put 'Product NPV cost (US$/kg),',               (-product_break_even_cost) / ;
                 put /;

         summary_file_yearly.nd = 8;
         summary_file_yearly.pw = 10000;
         if (1=0,
            put summary_file_yearly;
                    put 'Year, Fixed demand charge, Timed demand charge 1, Timed demand charge 2, Timed demand charge 3, Timed demand charge 4, Timed demand charge 5,  Timed demand charge 6, Meter cost,'
                    put 'Fuel cost, Electricity cost, Electricity cost (renewable), Arbitrage, Renewable sales, REC revenue, LCFS revenue,'
                    put 'Renewable FOM, Input FOM, Output FOM, Renewable VOM, Input VOM, Output VOM,'
                    put 'Regulation up, Regulation down, Spinning reserve, Nonspinning reserve, Startup costs, Product revenue,'
                    put 'Product sold (product units), Product revenue adj, Product price ($/unit of products), Taxes, Debts, Actual operating profit, Depreciated value, Inflation, Tax carryover, Divide by this to convert to NPV' /;
                    loop(years, put         ord(years),',',
                                            Fixed_dem_charge_cost_yearly(years),',',
                                            Timed_dem_1_cost_yearly(years),',',
                                            Timed_dem_2_cost_yearly(years),',',
                                            Timed_dem_3_cost_yearly(years),',',
                                            Timed_dem_4_cost_yearly(years),',',
                                            Timed_dem_5_cost_yearly(years),',',
                                            Timed_dem_6_cost_yearly(years),',',
                                            Meter_cost_yearly(years),',',
                                            fuel_cost_yearly(years),',',
                                            elec_cost_yearly(years),',',
                                            elec_cost_ren_yearly(years),',',
                                            arbitrage_revenue_yearly(years),',',
                                            renewable_sales_yearly(years),',',
                                            REC_revenue_yearly(years),',',
                                            LCFS_revenue_yearly(years),',',
                                            renew_FOM_cost2_yearly(years),',',
                                            input_FOM_cost2_yearly(years),',',
                                            output_FOM_cost2_yearly(years),',',
                                            renew_VOM_cost2_yearly(years),',',
                                            input_VOM_cost2_yearly(years),',',
                                            output_VOM_cost2_yearly(years),',',
                                            regup_revenue_yearly(years),',',
                                            regdn_revenue_yearly(years),',',
                                            spinres_revenue_yearly(years),',',
                                            nonspinres_revenue_yearly(years),',',
                                            startup_costs_yearly(years),',',
                                            product_revenue_yearly(years),',',
                                            product_sold_yearly(years),',',
                                            product_revenue_yearly2(years),',',
                                            product_price_yearly(years),',',
                                            Taxes_yearly(years),',',
                                            Debts_yearly(years),',',
                                            actual_operating_profit_yearly(years),',',
                                            amount_depreciated.l(years),',',
                                            inflation_vec(years),',',
                                            reserved_taxes.l(years),',',
                                            to_NPV(years) /;
                    );
                    put /;
        );

*$ontext

         if (1=0,
             if ( max_max_cap>100, results_file_devices.nd = 2; elseif max_max_cap>10, results_file_devices.nd = 4; elseif max_max_cap>0.1, results_file_devices.nd = 6; else results_file_devices.nd = 8;);
             results_file_devices.pw = 20000;
             put results_file_devices;
                     put 'Interval,';
                     loop(devices, put 'In Pwr ',ord(devices):0:0,' (MW),Out Pwr Sold',ord(devices):0:0,' (MW),Out Pwr Load',ord(devices):0:0,' (MW),Storage Lvl ',ord(devices):0:0,' (MW-h),Product Out ',ord(devices):0:0,' (kg),Non-Ren In ',ord(devices):0:0,' (MW),');
                     loop(devices_ren, put 'Ren In ',ord(devices_ren):0:0,' (MW),Ren Sold ',ord(devices_ren):0:0,' (MW),');
                     put 'Curtailment (MW)' /;
                     loop(interval, put      ord(interval),',';
                                    loop(devices,     put input_power_MW.l(interval,devices),',',
                                                          Output_power_sold(interval,devices),',',
                                                          Output_power_load(interval,devices),',',
                                                          storage_level_MWh_tot(interval,devices),',',
                                                          product_sold.l(interval,devices),',',
                                                          input_power_MW_non_ren.l(interval,devices),',',);
                                    loop(devices_ren, put Renewable_power(interval,devices_ren),',',
                                                          renewable_power_MW_sold.l(interval,devices_ren),',');
                                    put curtailment(interval);
                                    put /;
                     );

             if ( max_max_cap>100, summary_file_devices.nd = 2; else summary_file_devices.nd = 4; );
             summary_file_devices.pw = 20000;
             put summary_file_devices;
                     PUT 'Run on a %system.filesys% machine on %system.date% %system.time%.' /;
                     put 'Optimal solution found within time limit:,',
                     if ( optimal_solution_reached = 1,
                             put 'Yes' /;
                     else
                             put 'No' /;
                     );
                     put /;
                     put 'Device Number,';                           loop(most_devices_set, put most_devices_set.tl,',');            put /;
                     put 'Renewable Capacity (MW),';                 loop(devices_ren, put Renewable_MW(devices_ren),',');           put /;
                     put 'Renewable Penetration for Input (%), ',    Renewable_pen_input /;
                     put 'interval length (hours), ',                interval_length /;
                     put 'operating period length (hours), '         operating_period_length /;
                     put 'additional look-ahead (hours), '           look_ahead_length /;
                     put 'output capacity (MW), ',                   loop(devices, put output_capacity_MW(devices),',');             put /;
                     put 'input capacity (MW), ',                    loop(devices, put input_capacity_MW(devices),',');              put /;
                     put 'storage capacity (hours), ',               loop(devices, put storage_capacity_hours(devices),',');         put /;
                     put 'input efficiency (%), ',                   loop(devices, put input_efficiency(devices),',');               put /;
                     put 'output efficiency (%), ',                  loop(devices, put output_efficiency(devices),',');              put /;
                     put 'input heat rate (MMBtu/MWh), ',            loop(devices, put input_heat_rate(devices),',');                put /;
                     put 'ouptut heat rate (MMBtu/MWh), ',           loop(devices, put output_heat_rate(devices),',');               put /;
                     put 'variable O&M cost, ',                      VOM_cost /;
                     put 'regulation cost, ',                        reg_cost /;
                     put 'hydrogen use, ',                           loop(devices, put product_use(devices),',');                    put /;
                     put /;
                     put 'input' /;
                     put 'LSL limit fraction, ',                     loop(devices, put input_LSL_fraction(devices),',');             put /;
                     put 'reg up limit fraction, ',                  loop(devices, put input_regup_limit_fraction(devices),',');     put /;
                     put 'reg down limit fraction, ',                loop(devices, put input_regdn_limit_fraction(devices),',');     put /;
                     put 'spining reserve limit fraction, ',         loop(devices, put input_spinres_limit_fraction(devices),',');   put /;
                     put 'startup cost ($/MW-start), ',              loop(devices, put input_startup_cost(devices),',');             put /;
                     put 'minimum run intervals, '                   min_input_on_intervals /;
                     put /;
                     put 'output' /;
                     put 'LSL limit fraction, ',                     loop(devices, put output_LSL_fraction(devices),',');            put /;
                     put 'reg up limit fraction, ',                  loop(devices, put output_regup_limit_fraction(devices),',');    put /;
                     put 'reg down limit fraction, ',                loop(devices, put output_regdn_limit_fraction(devices),',');    put /;
                     put 'spining reserve limit fraction, ',         loop(devices, put output_spinres_limit_fraction(devices),',');  put /;
                     put 'startup cost ($/MW-start), ',              loop(devices, put output_startup_cost(devices),',');            put /;
                     put 'minimum run intervals, ',                  min_output_on_intervals /;
                     put /;
                     put 'actual operating profit ($), ',            sum(years,actual_operating_profit_yearly(years)) /;
                     put 'total electricity input (MWh), ',          elec_in_MWh /;
                     put 'total electricity output (MWh), ',         elec_output_MWh /;
                     put 'output to input ratio, ',                  output_input_ratio /;
                     put 'input capacity factor, ',                  input_capacity_factor /;
                     put 'output capacity factor, ',                 output_capacity_factor /;
                     put 'average regup (MW), ',                     loop(devices, put avg_regup_MW_vec(devices),',');               put /;
                     put 'average regdn (MW), ',                     loop(devices, put avg_regdn_MW_vec(devices),',');               put /;
                     put 'average spinres (MW), ',                   loop(devices, put avg_spinres_MW_vec(devices),',');             put /;
                     put 'average nonspinres (MW), '                 loop(devices, put avg_nonspinres_MW_vec(devices),',');          put /;
                     put 'number of input power system starts, ',    loop(devices, put num_input_starts_vec(devices),',');           put /;
                     put 'number of output power system starts, ',   loop(devices, put num_output_starts_vec(devices),',');          put /;
                     put 'arbitrage revenue ($),',                   loop(devices, put arbitrage_revenue_vec(devices),',');          put /;
                     put 'regup revenue ($), ',                      loop(devices, put regup_revenue_vec(devices),',');              put /;
                     put 'regdn revenue ($), ',                      loop(devices, put regdn_revenue_vec(devices),',');              put /;
                     put 'spinres revenue ($), ',                    loop(devices, put spinres_revenue_vec(devices),',');            put /;
                     put 'nonspinres revenue ($), ',                 loop(devices, put nonspinres_revenue_vec(devices),',');         put /;
                     put 'hydrogen revenue ($), ',                   loop(devices, put product_revenue_vec(devices),',');            put /;
                     put 'REC revenue ($), ',                        REC_revenue /;
                     put 'LCFS revenue ($), ',                       LCFS_revenue /;
                     put 'startup costs ($), ',                      loop(devices, put startup_costs_vec(devices),',');              put /;
                     put 'Fixed demand charge ($), ',                Fixed_dem_charge_cost/;
                     put 'Timed demand charge 1 ($), ',              Timed_dem_1_cost/;
                     put 'Timed demand charge 2 ($), ',              Timed_dem_2_cost/;
                     put 'Timed demand charge 3 ($), ',              Timed_dem_3_cost/;
                     put 'Timed demand charge 4 ($), ',              Timed_dem_4_cost/;
                     put 'Timed demand charge 5 ($), ',              Timed_dem_5_cost/;
                     put 'Timed demand charge 6 ($), ',              Timed_dem_6_cost/;
                     put 'Meter cost ($), ',                         Meter_cost/;
                     put 'Renewable capital cost ($), ',             loop(devices_ren, put renew_cap_cost2_vec(devices_ren),',');    put /;
                     put 'Input capital cost ($), ',                 loop(devices, put input_cap_cost2_vec(devices),',');            put /;
                     put 'Output capital cost ($), ',                loop(devices, put output_cap_cost2_vec(devices),',');           put /;
                     put 'Hydrogen storage cost ($), ',              loop(devices, put ProdStor_cap_cost2_vec(devices),',');         put /;
                     put 'Renewable FOM cost ($), ',                 loop(devices_ren, put renew_FOM_cost2_vec(devices_ren),',');    put /;
                     put 'Input FOM cost ($), ',                     loop(devices, put input_FOM_cost2_vec(devices),',');            put /;
                     put 'Output FOM cost ($), ',                    loop(devices, put output_FOM_cost2_vec(devices),',');           put /;
                     put 'Renewable VOM cost ($), ',                 loop(devices_ren, put renew_VOM_cost2_vec(devices_ren),',');    put /;
                     put 'Input VOM cost ($), ',                     input_VOM_cost2/;
                     put 'Output VOM cost ($), ',                    output_VOM_cost2/;
                     put 'Renewable sales ($), ',                    loop(devices_ren, put renewable_sales_vec(devices_ren),',');    put /;
                     put 'Renewable Penetration net meter (%), ',    Renewable_pen_input_net /;
                     put 'Curtailment (MWh), ',                      curtailment_sum /;
                     put 'Storage revenue ($), ',                    loop(devices, put Storage_revenue_vec(devices),',');            put /;
                     put 'Renewable only revenue ($), ',             Renewable_only_revenue /;
                     put 'Renewable max revenue ($), ',              Renewable_max_revenue /;
                     put 'Renewable Electricity Input (MWh), ',      Renewable_electricity_in /;
                     put 'Input Electricity Import (MWh), ',         loop(devices, put Input_elec_import_vec(devices),',');          put /;
                     put 'Integer device adjustment, ',              loop(devices, put CF_incremental_change.l(devices),',');        put /;
                     put /;
        );
*$offtext

         if (next_interval>1,
                 RT_out_file.nd = 4;
                 put RT_out_file;
                       put 'Interval, Electrolyzer Setpoint (MW)' /;
                       loop(next_int, put  next_interval,',',
                                           sum(devices, input_power_MW.l(next_int,devices)) /;
                       );
         );

else
*         put input_echo_file;
*                 put 'Error--solution not found.';
*         put results_file;
*                 put 'Error--solution not found.';
         put summary_file;
                 put 'Error--solution not found.';
*         put RT_out_file;
*                 put 'Error--soultion not found.';
);
