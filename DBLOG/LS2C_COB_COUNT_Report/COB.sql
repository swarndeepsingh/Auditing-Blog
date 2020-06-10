

DECLARE @PullDate  DATETIME = GETDATE()-1; 
 
declare @COBList table
(LongCode varchar(100),
JVCode varchar(100),
Description varchar(100),
PPL_REPORTING_CLASS varchar(100))

Insert into  @COBList
(LongCode,JVCode,Description,PPL_REPORTING_CLASS)
Values
('casualty','529','Casualty','CASUALTY'),
('general_casualty_or_liability',	'550'	,'Casualty / Liability - Liability','CASUALTY'),
('product_contamination_liability','551','Casualty / Liability - Product Contamination','CASUALTY'),
('commercial_liability','105'	,'Commercial liability','CASUALTY'),
('commercial_multiple_peril_casualty','020','Commercial multiple peril (casualty)','CASUALTY'),
('employers_liability','	112',	'Employer''s liability','CASUALTY'),
('excess_liability'	,'528'	,'Excess liability'	,'CASUALTY'),
('extended_warranty',	'036'	,'Extended warranty',	'CASUALTY'),
('film_producers_indemnity_all_risks_cast',	'122',	'Film producers indemnity - all risks cast','CASUALTY'),
('liquidated_damages'	,'554',	'Financial - Liquidated Damages',	'CASUALTY'),
('general_liability',	'126',	'General liability',	'CASUALTY'),
('legal_expenses',	'127'	,'Legal expenses',	'CASUALTY'),
('liability_unspecified',	'129',	'Liability unspecified',	'CASUALTY'),
('nonmarine_general_and_miscellaneous_liability',	'146',	'Non-marine general and miscellaneous liability',	'CASUALTY'),
('other_liability_umbrella_all_others',	'163',	'Other liability, umbrella all others'	,'CASUALTY'),
('product_guarantee_recall',	'174'	,'Product guarantee - recall',	'CASUALTY'),
('workers_compensation_specific',	'197',	'Workers'' compensation - specific',	'CASUALTY'),
 ('workers_compensation_and_employers_liability',	'198',	'Workers'' compensation and employers'' liability'	,'CASUALTY'),
('workers_compensation_unspecified',	'201',	'Workers'' compensation unspecified',	'CASUALTY'),
('agricultural_crop_and_forestry',	'001',	'Agricultural crop and forestry',	'PROPERTY'),
('all_risk_physical_or_loss_damage',	'573',	'All Risk Loss or Physical Damage','PROPERTY'),
('all_risks_of_physical_loss_or_damage_other_than_direct_prop_reins'	,'002',	'All risks of physical loss or damage other than direct prop. reins.',	'PROPERTY'),
('commercial_multiple_peril',	'019',	'Commercial multiple peril',	'PROPERTY'),
('commercial_multiple_peril_property',	'021',	'Commercial multiple peril (property)',	'PROPERTY'),
('commercial_multiple_peril_unspecified',	'024',	'Commercial multiple peril unspecified',	'PROPERTY'),
('commercial_or_industrial_all_risks_loss_of_profits'	,'027',	'Commercial/industrial all risks - loss of profits',	'PROPERTY'),
('combined_property_damage_and_bodily_injury',	'615',	'Defines a standard combined property and liability class of business.',	'PROPERTY'),
('difference_in_conditions',	'029',	'Difference in conditions',	'PROPERTY'),
('earthquake',	'030',	'Earthquake',	'PROPERTY'),
('farmowners_multiple_peril',	'116',	'Farmowners multiple peril',	'PROPERTY'),
('fire'	,'203',	'Fire',	'PROPERTY'),
('fire_combined_unspecified'	,'207'	,'Fire - combined - unspecified',	'PROPERTY'),
('fire_unspecified','237','Fire - unspecified',	'PROPERTY'),
('fire_and_perils',	'230',	'Fire and perils',	'PROPERTY'),
('flood_unspecified',	'041',	'Flood unspecified',	'PROPERTY'),
('homeowners_multiple_peril_unspecified',	'054',	'Homeowners multiple peril unspecified',	'PROPERTY'),
('household_or_homeowner_multiple_peril',	'055',	'Household / Homeowner multiple peril','PROPERTY'),
('low_voltage_computers_electronics',	'491',	'Low voltage - computers - electronics','PROPERTY'),
('natural_catastrophes',	'062',	'Natural catastrophes',	'PROPERTY'),
('property_household',	'558',	'Property - Householders Comprehensive'	,'PROPERTY'),
('property_unspecified',	'069',	'Property - unspecified',	'PROPERTY'),
('property_unspecified_full_value',	'581',	'Property full value',	'PROPERTY'),
('property_multinational',	'070',	'Property multinational','PROPERTY'),
--,('property_terrorism',	'546',	'Property terrorism',	'PROPERTY') removing as per Alfie mail
('marine_hull',	'298',	'Marine hull','MARINE'),
('marine_increased_value',	'620',	'Marine Increased Value','MARINE'),
('marine_liability_unspecified',	'556',	'Marine - Liability','MARINE'),
('marine_mortgagees_interest_and_additional_perils',	'621',	'Marine Mortgagees Interest And Additional Perils','MARINE'),
('marine_unspecified',	'515',	'Marine unspecified','MARINE'),
('marine_war',	'293',	'Marine - war','MARINE'),
('specie_and_valuables_commercial',	'074',	'Specie and valuables - commercial','MARINE')

,('armoured_carriers_and_cash_in_transit',	'009',	'Armoured carriers and cash in transit','MARINE'),
('cargo_unspecified',	'549',	'Cargo','MARINE'),
('fine_art',	'037',	'Fine Art','MARINE'),
('general_specie_including_vault_risks',	'044',	'General specie including vault risks','MARINE'),
('jewellers_block',	'057',	'Jeweller''s block','MARINE')

----Newly added COB for mail dated 05/mar/2018
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('energy_onshore','032','Energy, onshore','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('energy_or_oil_and_gas_on_shore_including_rigs','033','Energy/oil and gas - on shore - including rigs','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('energy_or_oil_and_gas_unspecified','034','Energy/oil and gas - unspecified','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('nuclear_property','063','Nuclear - property','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('energy_liability_onshore','113','Energy liability, onshore','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('nuclear_liability','147','Nuclear - liability','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('energy_operators_extra_expenses_and_control_of_well','275','Energy operators extra expenses and control of well','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('energy_liability_offshore','276','Energy liability, offshore','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('energy_offshore_property','277','Energy, offshore, property','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('energy_or_oil_and_gas_off_shore_including_rigs','278','Energy/oil and gas - off shore - including rigs','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('marine_offshore_or_rigs','309','Marine offshore / rigs','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('nuclear_personal_accident','408','Nuclear - personal accident','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('nuclear','531','Nuclear','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('offshore','532','Offshore','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('energy_liability_unspecified','561','Energy Liability Unspecified','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('energy_operational_power_generation_transmission_and_utilities','569','Energy Operational Power Generation','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('energy_construction_offshore_property','592','Energy construction offshore property','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('energy_search_offshore_property','593','Energy search offshore property','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('lm_energy_search_offshore_property_GOM_wind_excl_WRO_excl_construct','599','Energy search offshore property GOM wind excluding WRO excluding cons','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('lm_energy_search_offshore_property_excl_GOM_wind_and_WRO','600','Energy search offshore property excluding GOM wind and WRO','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('lm_energy_operators_extra_expenses_and_control_of_well_GOM_wind','601','Energy operators extra expenses and control of well GOM wind','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('lm_energy_operators_extra_expenses_and_control_of_well_excl_GOM_wind','602','Energy operators extra expenses and control of well excluding GOM wind','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('energy_unspecified','603','Energy Unspecified','ENERGY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('film_including_film_completion_bonds','568','Film inc Film Completion Bonds','ENERGY')  
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('boiler_loss_of_profits','088','Boiler - loss of profits','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('boiler_and_machinery','089','Boiler and machinery','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('boiler_and_machinery_contractors_all_risk','090','Boiler and machinery contractors all risk','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('boiler_and_machinery_engineering_general','091','Boiler and machinery engineering - general','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('boiler_and_machinery_erection_all_risk','092','Boiler and machinery erection all risk','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('boiler_and_machinery_machinery_breakdown','093','Boiler and machinery machinery breakdown','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('boiler_and_machinery_unspecified','094','Boiler and machinery unspecified','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('boiler_explosion','095','Boiler explosion','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('machinery_loss_of_profits','096','Machinery - loss of profits','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('machinery_breakdown','097','Machinery breakdown','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('machinery_guarantee','098','Machinery guarantee','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('special_machinery_covers','099','Special machinery covers','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('car_loss_of_profits','472','CAR - loss of profits','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('car_or_ear_and_decennial','473','CAR / EAR and decennial','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('car_or_ear_combined','474','CAR / EAR combined','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('car_or_ear_special_insurance','475','CAR / EAR special insurance','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('combined_car_and_ear','476','Combined CAR / EAR','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('contractors_plant_loss_of_profits','477','Contractors plant - loss of profits','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('contractors_all_risks','478','Contractors'' all risks','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('deterioration_of_stock_loss_of_profits','479','Deterioration of stock - loss of profits','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('ear_loss_of_profits','480','EAR - loss of profits','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('engineering_completed_risks','481','Engineering - completed risks','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('engineering_completed_works_insurance','482','Engineering - completed works insurance','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('engineering_earthquake','483','Engineering - earthquake','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('engineering_leasing','484','Engineering - leasing','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('engineering_special_industrial_all_risk_coverage','485','Engineering - special industrial all risk coverage','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('engineering_unspecified','486','Engineering - unspecified','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('engineering_incl_boiler_and_machinery_contractors_ar_and_engineering','487','Engineering incl boiler and machinery, contractors AR and engineering','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('engineering_insurance_contractors_plant','488','Engineering insurance contractors'' plant','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('machinery_and_car_or_ear','493','Machinery and CAR / EAR','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('various_machinery','494','Various machinery','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('construction_unspecified','552','Construction','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('construction_pollution_liability','616','Construction Pollution Liability','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('construction_wrap_up','617','Construction Wrap Up','CONSTRUCTION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('erection_all_risks','489','Erection all risks','CONSTRUCTION') 
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('industrial_riot','056','Industrial riot','POLITICAL RISKS')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('political_risks_unspecified','065','Political risks - unspecified','POLITICAL RISKS')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('private_riot','067','Private riot','POLITICAL RISKS')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('private_theft','068','Private theft','POLITICAL RISKS')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('terrorism_pool_re','077','Terrorism - Pool Re','POLITICAL RISKS')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('war_unspecified','559','War and Political - War','POLITICAL RISKS')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('kidnap_and_ransom','407','Kidnap and ransom','K & R')
 
----Newly added COB for mail dated 06/apr/2018
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('general_accident','043','General accident','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('accident_unspecified','100','Accident - unspecified','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('accident_liability_and_motor_multilines_accident_predominating','101','Accident, liability and motor multilines - accident predominating','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('accident_liability_and_motor_multilines_liability_predominating','102','Accident, liability and motor multilines - liability predominating','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('accident_liability_and_motor_multilines_motor_predominating','103','Accident, liability and motor multilines - motor predominating','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('accident_liability_motor_and_other_multilines','104','Accident, liability, motor and other multilines','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('film_producers_indemnity_all_risks_cast_or_negative','123','Film producers indemnity - all risks cast/negative','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('film_producers_indemnity_all_risks_negative','124','Film producers indemnity - all risks negative','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('credit_accident_and_health','386','Credit accident and health','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('credit_accident_and_health_group','387','Credit accident and health group','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('credit_accident_and_health_individual','388','Credit accident and health individual','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('credit_accident_and_health_unspecified','389','Credit accident and health unspecified','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('group_accident_and_health','390','Group accident and health','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('group_accident_and_health_personal_accident','391','Group accident and health - personal accident','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('group_accident_and_health_personal_sickness','392','Group accident and health - personal sickness','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('group_accident_and_health_air_travel','393','Group accident and health air travel','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('group_accident_and_health_unspecified','394','Group accident and health unspecified','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('individual_accident_and_health_personal_accident','395','Individual accident and health - personal accident','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('individual_accident_and_health_personal_air_travel','396','Individual accident and health - personal, air travel','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('individual_accident_and_health_personal_all_other','397','Individual accident and health - personal, all other','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('individual_accident_and_health_personal_collectively_renewable','398','Individual accident and health - personal, collectively renewable','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('individual_accident_and_health_personal_guaranteed_renewable','399','Individual accident and health - personal, guaranteed renewable','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('individual_accident_and_health_personal_non_cancellable','400','Individual accident and health - personal (non cancellable)','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('individual_accident_and_health_personal_non_renewable_for_stated_re','401','Individual accident and health - personal, non renewable for stated re','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('individual_accident_and_health_personal_other_accident','402','Individual accident and health - personal, other accident','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('individual_accident_and_health_personal_other_health','403','Individual accident and health - personal, other health','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('individual_accident_and_health_personal_unspecified','404','Individual accident and health - personal, unspecified','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('individual_and_group_sickness_unspecified','405','Individual and group sickness - unspecified','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('individual_sickness','406','Individual sickness','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_group_travel_accident','409','Personal accident - group travel accident','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_individual_and_group_unspecified','410','Personal accident - individual and group - unspecifiedd','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_individual_travel_accident','411','Personal accident - individual travel accident','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_motor_unspecified','412','Personal accident - motor - unspecified','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_motor_driver','413','Personal accident - motor driver','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_motor_passengers','414','Personal accident - motor passengers','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_supplementary','415','Personal accident - supplementary','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_travel_accident_unspecified','416','Personal accident - travel accident - unspecified','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_unspecified','417','Personal accident - unspecified','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_and_health_individual','418','Personal accident and health individual','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_with_premium_refund','419','Personal accident with premium refund','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('sickness_medical_expenses','420','Sickness - medical expenses','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('sickness_unspecified','421','Sickness - unspecified','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('sickness_loss_of_income_long_term','422','Sickness loss of income - long term','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('sickness_loss_of_income_short_term','423','Sickness loss of income - short term','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('temporary_life_and_permanent_health','424','Temporary life and permanent health','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('storage_liability','506','Storage liability','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_including_passive_war','523','Personal accident - including passive war','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_including_war','524','Personal accident - including war','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_war','527','Personal accident - war','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('contingency_liability','540','Contingency liability','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('life','541','Life','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('life_pensions','542','Life pensions','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('life_other','543','Life other','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_individual_and_group_inc_kidnap_and_ransom','577','PA individual and Group including KandR','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('personal_accident_individual_and_group_inc_sports_disability_excl_acc','578','PA individual and Group including sports disability excluding accidental','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('film_producers_indemnity','629','Film Producers Indemnity','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('accident_and_health','632','Accident and Health','A & H')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('bloodstock','012','Bloodstock','B & L STOCK')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('fishfarm','038','Fishfarm','B & L STOCK')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('livestock','058','Livestock','B & L STOCK')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('bankers_blanket_bonds','011','Bankers blanket bonds','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('directors_and_officers_liability','109','Directors and officers liability','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('errors_and_omissions_or_professional_indemnity','115','Errors and omissions/professional indemnity','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('medical_malpractice','130','Medical malpractice','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('medical_malpractice_hospitals','133','Medical malpractice hospitals','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('medical_malpractice_nursing_homes','135','Medical malpractice nursing homes','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('medical_malpractice_unspecified','144','Medical malpractice unspecified','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('other_liability_directors_and_officers_financial_institutions','152','Other liability, directors and officers, financial institutions','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('other_liability_directors_and_officers_and_nonfinancial_institutions','153','Other liability, directors and officers and non-financial institutions','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('other_liability_errors_and_omissions_accountants','155','Other liability, errors and omissions, accountants','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('other_liability_errors_and_omissions_architects_and_engineers','156','Other liability, errors and omissions, architects and engineers','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('other_liability_errors_and_omissions_insurance_agent','157','Other liability, errors and omissions, insurance agent','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('other_liability_errors_and_omissions_lawyers','158','Other liability, errors and omissions, lawyers','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('other_liability_errors_and_omissions_miscellaneous','159','Other liability, errors and omissions, miscellaneous','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('other_liability_umbrella_directors_and_officers','165','Other liability, umbrella directors and officers','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('other_liability_umbrella_errors_and_omissions','167','Other liability, umbrella errors and omissions','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('professional_liability_doctors_and_hospitals','183','Professional liability - doctors and hospitals','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('fidelity','444','Fidelity','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('fidelity_commercial','445','Fidelity commercial','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('fidelity_financial_institutions','446','Fidelity financial institutions','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('fidelity_umbrella_commercial','452','Fidelity umbrella commercial','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('fidelity_umbrella_financial_institutions','453','Fidelity umbrella financial institutions','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('fidelity_computer_crime_and_bankers_policies_burglary_robbery_theft_forgery','455','Fidelity computer crime and bankers policies(and burglary,robbery,theft,forgery)','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('financial_guarantee','456','Financial guarantee','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('surety_or_financial_guarantee','465','Surety / financial guarantee','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('mortgage_guarantee','534','Mortgage Guarantee','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('financial','539','Financial','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('intellectual_property','553','Financial - Intellectual Property','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('other_liability_errors_and_omissions_financial_institutions','564','Other liability, errors and omissions, financial institutions','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('employment_practice_liability','618','Employment Practice Liability','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('financial_services_loss_of_licence','619','Financial Services Loss Of Licence','FINPRO')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('property_terrorism','546','Property terrorism','TERRORISM')

----Newly added COB for mail dated 14/jun/2018
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation','332','Aviation','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_liability_excluding_war','333','Aviation liability - excluding war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_liability_including_war_passenger','334','Aviation liability - including war - passenger','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_liability_including_war_products','335','Aviation liability - including war - products','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_liability_including_war_third_party','336','Aviation liability - including war - third party','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_liability_unspecified','337','Aviation liability - unspecified','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_liability_war_only','338','Aviation liability - war only','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_personal_accident_excluding_war','339','Aviation - personal accident excluding war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_personal_accident_including_war','340','Aviation - personal accident including war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_personal_accident_loss_of_license','341','Aviation - personal accident loss of license','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_personal_accident_war_only','342','Aviation - personal accident war only','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_all_classes_excluding_war','343','Aviation all classes - excluding war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_all_classes_including_war','344','Aviation all classes - including war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_all_classes_war_only','345','Aviation all classes - war only','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_all_classes_airline_business_excluding_war','346','Aviation all classes airline business excluding war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_all_classes_airline_business_including_war','347','Aviation all classes airline business including war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_all_classes_airline_business_war_only','348','Aviation all classes airline business war only','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_all_classes_general_aviation_business','349','Aviation all classes general aviation business','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull','350','Aviation hull','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull_including_war','351','Aviation hull - including war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull_unspecified','352','Aviation hull - unspecified','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull_war','353','Aviation hull - war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull_airline_business_excluding_war','354','Aviation hull airline business excluding war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull_airline_business_including_war','355','Aviation hull airline business including war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull_airline_business_war_only','356','Aviation hull airline business war only','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull_general_aviation_business_including_war','357','Aviation hull general aviation business - including war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull_general_aviation_business_war_only','358','Aviation hull general aviation business - war only','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull_manufacturers_excluding_war','359','Aviation hull manufacturers - excluding war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull_manufacturers_including_war','360','Aviation hull manufacturers - including war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull_manufacturers_war_only','361','Aviation hull manufacturers - war only','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_liabilities_premises','362','Aviation liabilities - premises','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_liability','363','Aviation liability','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_other_liabilities','364','Aviation other liabilities','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_satellites','365','Aviation satellites','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_unspecified','366','Aviation unspecified','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_general','367','Aviation - general','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('liability_airline_airport','368','Liability airline airport','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('liability_airline_combined_single_limit','369','Liability airline combined single limit','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('liability_airline_passenger','370','Liability airline passenger','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('liability_airline_products','371','Liability airline products','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('liability_airline_third_party','372','Liability airline third party','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('liability_general_aviation_airport','373','Liability general aviation airport','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('liability_general_aviation_combined_single_limit','374','Liability general aviation combined single limit','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('liability_general_aviation_passenger','375','Liability general aviation passenger','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('liability_general_aviation_products','376','Liability general aviation products','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('liability_general_aviation_third_party','377','Liability general aviation third party','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('space_all_classes','378','Space - all classes','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('space_in_orbit','379','Space - in orbit','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('space_launch','380','Space - launch','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('space_launch_and_commissioning_period','381','Space - launch and commissioning period','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('space_liability','382','Space - liability','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('space_pre_launch','383','Space - pre launch','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('space_unspecified','384','Space unspecified','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_personal_accident_unspecified','385','Aviation - personal accident unspecified','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_cargo_including_war','520','Aviation cargo, including war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_cargo_excluding_war','521','Aviation cargo, excluding war','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_products','548','Aviation Products','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_cargo','610','Aviation Cargo','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull_and_liability','611','Aviation Hull and Liability','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull_deductible','612','Aviation Hull Deductible','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_spares','613','Aviation Spares','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull_airline_business','624','Aviation Hull Airline Business','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('liability_airline','625','Liability Airline','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('aviation_hull_manufacturers','626','Aviation Hull Manufacturers','AVIATION')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('other_liability_environmental_impairment_liability','154','Other liability, environmental impairment liability','CASUALTY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('environmental_or_pollution_liability','114','Environmental/pollution liability','CASUALTY')
INSERT INTO @COBList(LongCode,JVCode,[Description],PPL_REPORTING_CLASS) VALUES('general_cyber','633','General Cyber','FINPRO')

---------------------------------------------------------------------------------------------
SELECT DISTINCT VCLASBUS.Description [Class Of Business], CB.PPL_REPORTING_CLASS ,COUNT(CASE WHEN ', ' + tmp.RE_INSURER_STATUS +',' LIKE '%Bound%' THEN 1 END)  AS TotalCount
FROM
CORE.VW_CODE VCLASBUS 
INNER JOIN @COBList CB on VCLASBUS.[DESCRIPTION]=CB.Description
LEFT JOIN
(
	Select 
		DISTINCT PLACE.UMR AS 'UNIQUE_MARKET_REFERENCE',
		PLACDETAIL.ClassOfBusinessId,		
		(SELECT  CASE WHEN EXISTS ( SELECT 1 FROM [placement].PlacementAction PLACTION21 where PLACTION21.MarketId= MKT.MarketId and PLACTION21.ActionTypeId IN(2,6,7,8,34))
		THEN
		(SELECT TOP 1 
				CASE 
				WHEN PLACTION2.ActionTypeId = 2  and MKT.MarketStatusId = 28 then 'Bound' 
				WHEN PLACTION2.ActionTypeId = 6  and MKT.MarketStatusId = 28 then 'Bound' -- with Line Conditions
				WHEN PLACTION2.ActionTypeId = 7  and MKT.MarketStatusId = 28 then 'Bound'-- with Subjectivities
				WHEN PLACTION2.ActionTypeId = 8  and MKT.MarketStatusId = 28 then 'Bound'-- with Line Conditions and Subjectivities
				ELSE 
				CASE
				WHEN MKT.MarketStatusId = 24 OR MKT.MarketStatusId = 34 then 'Bound'-- Awaiting Broker Completion of Subjectivities
				WHEN PLACTION2.ActionTypeId = 34 and  MKT.MarketStatusId = 27 then 'Line Removed'     
				ELSE 
				MktStatus.MarketStatus
				END  
				END  AS 'RE_INSURER_STATUS'
			FROM [placement].PlacementAction PLACTION2 where PLACTION2.MarketId = MKT.MarketId and PLACTION2.ActionTypeId IN(2,6,7,8,34))		
		ELSE
			MktStatus.MarketStatus
		END ) AS 'RE_INSURER_STATUS'
		,CAST(SIGNED_DATE.SIGNED_LINE_DATE as DATE) as dt

	FROM [placement].Programme PROG WITH (NOLOCK)              
			JOIN [placement].Placement PLACE WITH (NOLOCK) ON PROG.ProgrammeId = PLACE.ProgrammeId      
			JOIN [placement].PlacementDetail PLACDETAIL WITH (NOLOCK) ON PLACE.PlacementId = PLACDETAIL.PlacementId      
			JOIN [placement].Section SEC  WITH (NOLOCK) ON PLACDETAIL.PLACEMENTDETAILID = SEC.PLACEMENTDETAILID        
			JOIN  [placement].Market MKT WITH (NOLOCK) ON MKT.SectionId = SEC.SectionId   
						
			LEFT JOIN lookup.PlacementStatus PLSTATUS ON PLSTATUS.PlacementStatusId = PLACDETAIL.PlacementStatusId     
			LEFT JOIN lookup.MarketStatus MktStatus ON MktStatus.MarketStatusId = MKT.MarketStatusId
					
			CROSS APPLY (SELECT max(PLACTION.SentTimestamp) SIGNED_LINE_DATE FROM [placement].PlacementAction PLACTION WITH (NOLOCK) 
              WHERE PLACTION.MarketId = MKT.MarketId and PLACTION.ACTIONTYPEID = 36) SIGNED_DATE

			WHERE (PLACE.OrganisationDisplayName NOT LIKE '%Post Bounce%' AND PLACE.OrganisationDisplayName NOT LIKE '%Test%') -- Removed Test Org
					AND PLSTATUS.PlacementStatus = 'Sign And Close Complete'  -- LAYER_STATUS = 'CLOSED'
					AND CAST(SIGNED_DATE.SIGNED_LINE_DATE as DATE) = CAST(@PullDate as DATE)
) tmp ON VCLASBUS.ID = tmp.ClassOfBusinessId      
GROUP BY VCLASBUS.Description,CB.PPL_REPORTING_CLASS
ORDER BY CB.PPL_REPORTING_CLASS, VCLASBUS.Description


--DROP table @COBList