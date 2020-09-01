#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version = 1.0

//	2020 Hyungu Kang, www.hazykinetics.com, hyunguboy@gmail.com
//
//	GNU GPLv3. Please feel free to modify the code as necessary for your needs.
//
//	Version 1.0 (Released 2020-xx-xx)
//	1. Initial release tested with Igor Pro 8.04 with AirKorea data. These
//		functions are not compatible with Igor Pro 6.

////////////////////////////////////////////////////////////////////////////////
	
//	Makes annual and weekly air quality tile plots like those by the EPA.
//	The tile plot functions require the following:
//	1.	Time and pollutant concentration waves.
//	2.	Number of pollution levels and their cutoff values.
//	3.	Color (RGB) designations for each pollution level.
//
//	The tile plot functions can be accessed from the menu at the top, which
//	opens panels for convenient use.
//
//	I also included functions that prepares the air pollution time series data
//	published by AirKorea. I was interested in the PM10 trend over time in
//	Gireum-dong, Seongbuk-gu, Seoul, Korea. The earliest data I could find
//	on AirKorea was from 2001.
//
//	AirKorea does not archive their data consistently, and the data
//	format appears to change on what webpage you download the data from.
//	For instance, in 2014, the PM2.5 column was added, but measurements do not
//	appear until 2015. AirKorea reports hourly averages, with data being time
//	stamped at the last measurement.
//
//	Also, sometimes missing data is labeled as -999 or NaN.
//
//	As of 2020, the four PM10 pollution levels designated by the 
//	Ministry of Environment of Korea are Good, Moderate, Unhealthy,
//	and Very Unhealthy.
//
//	www.airkorea.or.kr

////////////////////////////////////////////////////////////////////////////////

Menu "TilePlot"

	"Open TilePlot Panel", HKang_TilePlotPanel()
	"Open Report"
	
End

////////////////////////////////////////////////////////////////////////////////

Function HKang_TilePlotPanel()



End

////////////////////////////////////////////////////////////////////////////////

//	w_conc:		Concentration wave.
//	w_time:		Time wave with regular intervals.
//	w_bounds:		Boundaries that separate the different pollution levels.
//					First point must be 0, and last point must be infinity.
//	w_colorRef:	RGB wave for the colors of each corresponding
//					pollution level (three columns).
//	w_labels:		Text wave with the labels for each pollution level.
//
//	Color references (RGB):
//	Blue:		0			0			65535
//	Green:		2			39321		1
//	Yellow:	65535		43690		0
//	Red:		65535		0			0
//	Gray:		45000		45000		45000
//	White:		65535		65535		65535
//Function HKang_EPATilePlot_Annual(w_conc, w_time, w_bounds, w_colorRef, w_labels)
//	Wave w_conc, w_time, w_bounds, w_colorRef
//	Wave/T w_labels
//
//	Variable v_year, v_month, v_day, v_hour
//	Variable v_daysNumberOf
//	Variable v_yearMin, v_yearMax, v_yearsNumberOf
//	Variable iloop, jloop
//	Variable v_timerRefNum, v_timerElapsed
//	String s_pollutionTimeRaw
//	DFREF dfr_current
//
//	dfr_current = GetDataFolderDFR()
//
//	// Set data folder to prevent cluttering.
//	If(datafolderexists("root:TilePlot") != 1)
//		Print "Aborting: 'root:TilePlot' not found."
//		Abort "Create folder and place input waves in that folder."
//	Else
//		SetDataFolder root:TilePlot
//	EndIf
//
//	// Error messages in case the user makes a mistake.
//	HKang_EPATilePlot_ErrorMessages(w_time, w_conc, w_bounds, w_labels, w_colorRef)
//
//	// Timer for diagnostics and code improvements.
//	Print "Started calculation at: ", time()
//
//	v_timerRefNum = startmstimer
//
//	// Identify number of years in the time wave. This will determine
//	// the number of tile plots generated.
//	secs2date(
//	v_year_minimum = V_min
//	v_year_maximum = V_max
//	v_year_number_of = v_year_maximum - v_year_minimum + 1
//	
//	// Make time wave (one day basis) for the tile plot. 
//	v_days_number_of = (date2secs(v_year_maximum, 12, 31) - date2secs(v_year_minimum, 1, 1) + 24 * 60 * 60)/(24 * 60 * 60)
//	
//	Make/O/D/N = (v_days_number_of) w_TilePlot_time_all_days
//	Make/O/D/N = (v_days_number_of) w_TilePlot_pollution_conc_avg_all_days
//	Make/O/D/N = (v_days_number_of) w_TilePlot_pollution_conc_stddev_all_days
//	w_TilePlot_time_all_days = NaN
//	w_TilePlot_pollution_conc_avg_all_days = NaN
//	w_TilePlot_pollution_conc_stddev_all_days = NaN
//	
//	SetScale d, 0, 0, "dat", w_TilePlot_time_all_days
//	
//	// Make daily pollution concentration average wave.
//	v_loop2 = 0
//	
//	For(v_loop1 = 1; v_loop1 < numpnts(w_TilePlot_time_all_days); v_loop1 += 1)
//	
//		Make/O/D/N = 0 w_bin
//		
//		Do
//		
//			If(numpnts(w_bin) == 24)
//				Break
//			EndIf
//		
//			If(v_loop2 < numpnts(w_pollution_time))
//				Break
//			EndIf
//			
//			
//		
//			If(w_pollution_time[v_loop2] > w_TilePlot_time_all_days[v_loop1 - 1] && w_pollution_time[v_loop2] <= w_TilePlot_time_all_days[v_loop1])
//				InsertPoints/M = 0 0, 1, w_bin
//				w_bin[0] = w_pollution_conc[v_loop2]	
//			EndIf
//		
//			If(numpnts(w_bin) == 24)
//				Break
//			EndIf
//					
//
//		
//		If(numpnts(w_bin) < 18)
//			w_TilePlot_pollution_conc_avg_all_days[v_loop1 - 1] = NaN
//		
//		
//		Else
//		WaveStats/Q w_bin
//		
//		EndIf
//		
//		While(1)
//	
//	EndFor
//
//	
//	
//	
//	
//
//	
//	
//	
//	
//	
//	
//	
//	
//
//	
//	// Make color reference wave for entire time range.
//	Make/O/D/N = (numpnts(w_pollution_time_raw)) w_pollution_level_color
//	Redimension/N = (-1,3) w_pollution_level_color
//	w_pollution_level_color = NaN
//	
//	For(v_loop1 = 0; v_loop1 < numpnts(w_pollution_time_raw); v_loop1 += 1)
//	
//		If(numtype(w_pollution_conc[v_loop1]) == 2)			// NaN concentrations are gray.
//			w_pollution_level_color[v_loop1][0] = 45000
//			w_pollution_level_color[v_loop1][1] = 45000
//			w_pollution_level_color[v_loop1][2] = 45000
//		Else
//			For(v_loop2 = 1; v_loop2 < dimsize(w_pollution_level_color_reference, 0); v_loop2 += 1)
//			
//				If(w_pollution_conc[v_loop1] == 0)
//					w_pollution_level_color[v_loop1][0] = w_pollution_level_color_reference[0][0]
//					w_pollution_level_color[v_loop1][1] = w_pollution_level_color_reference[0][1]
//					w_pollution_level_color[v_loop1][2] = w_pollution_level_color_reference[0][2]
//				EndIf
//				
//				If(w_pollution_conc[v_loop1] > w_pollution_level_bounds[v_loop2 - 1] && w_pollution_conc[v_loop1] <= w_pollution_level_bounds[v_loop2])
//					w_pollution_level_color[v_loop1][0] = w_pollution_level_color_reference[v_loop2 - 1][0]
//					w_pollution_level_color[v_loop1][1] = w_pollution_level_color_reference[v_loop2 - 1][1]
//					w_pollution_level_color[v_loop1][2] = w_pollution_level_color_reference[v_loop2 - 1][2]					
//				EndIf
//	
//			EndFor
//		EndIf
//		
//	EndFor
//	
//
//	
//	
//	
//	
//	//generate annual tileplot
//	//generate weekly profile
//	//generate diurnal profile
//	// use jittered box whiskers plot. show avg and median. Use enoise for uniform random distribution.
//	
//	
//	v_timer_elapsed = stopmstimer(v_timer_refnum)
//	Print "Total processing time (seconds):", v_timer_elapsed/1000000
//
//
//	SetDataFolder dfr_current
//
//End

////////////////////////////////////////////////////////////////////////////////

Function HK_EPATilePlot_Weekly(w_time, w_conc, w_bounds, w_labels, w_colorRef)
	wave w_time, w_conc, w_bounds, w_labels, w_colorRef
End

////////////////////////////////////////////////////////////////////////////////

// Error messages.
static Function HKang_EPATilePlot_ErrorMessages(w_time, w_conc, w_bounds, w_labels, w_colorRef)
	Wave w_time, w_conc, w_bounds, w_labels, w_colorRef

	Variable iloop

	If(numpnts(w_time) != numpnts(w_conc))
		Abort "Aborting: Time and concentration waves' lengths do not match."
	EndIf

	If(numpnts(w_bounds) != dimsize(w_colorRef, 0) + 1)
		Abort "Aborting: Number of pollution level categories and number` of corresponding colors do not match."
	EndIf

	If(dimsize(w_colorRef, 1) != 3)
		Abort "Aborting: Number of columns in color reference wave is not 3 (RGB)."
	EndIf

	For(iloop = 1; iloop < numpnts(w_time); iloop += 1)
		If(w_time[iloop] < w_time[iloop - 1])
			Abort "Aborting: Time wave is not sorted. Sort time and corresponding concentration waves."
		EndIf
	EndFor

	If(w_bounds[0] != 0)
		Abort "Aborting: Lowest pollution level bound is not 0. Set it to 0."
	EndIf

	If(numtype(w_bounds[numpnts(w_bounds) - 1]) != 1)
		Abort "Aborting: Highest pollution level bound is not Inf. Set it to Inf."
	EndIf

End

////////////////////////////////////////////////////////////////////////////////

//	Check time series and convert into a daily time series if necessary.
static Function HKang_ConvertToDailyTime(w_conc, w_time)
	Wave w_conc, w_time






















End


















