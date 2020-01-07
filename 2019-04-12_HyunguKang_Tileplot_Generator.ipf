#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// 2019 Hyungu Kang. hyunguboy@gmail.com, www.hazykinetics.com

// GNU GPLv3. Please feel free to modify the code as necessary for your needs.
// Written in Igor Pro 8. Not sure if this will work in Igor Pro 6.
// Makes annual air quality tile plots like those by the EPA.
// In our case, we are intersted in the PM10 trend over time in Gireum-dong, Seongbuk-gu, Seoul, Korea.

// w_pollution_time_raw: raw time wave from Airkorea data. It needs to be converted so that Igor Pro recognizes it.
// w_pollution_time: time wave of the measurements in seconds. The pollution levels in Korea are reported every hour.
// w_pollution_level_bounds: the bounds that separates the different pollution levels. First point must be 0, and last point must be infinity.
// w_pollution_level_labels: text wave with the labels for each pollution level. As of 2019, the four PM10 pollution levels designated by the Ministry of Environment of Korea are Good, Moderate, Unhealthy, and Very Unhealthy. 
// w_pollution_level_color_reference: RGB designations for the colors of each corresponding pollution level (three columns).

Function TilePlot_Generator(w_pollution_time_raw, w_pollution_conc, w_pollution_level_bounds, w_pollution_level_labels w_pollution_level_color_reference)
	
	Wave w_pollution_time_raw, w_pollution_conc, w_pollution_level_bounds, w_pollution_level_color_reference
	Wave/T w_pollution_level_labels
	Variable v_year, v_month, v_day, v_hour
	Variable v_days_number_of
	Variable v_year_minimum, v_year_maximum, v_year_number_of
	Variable v_loop1, v_loop2
	Variable v_timer_refnum, v_timer_elapsed
	String s_pollution_time_raw
	
	SetDataFolder root:
	
	// Error messages in case the user makes a mistake.
	If(datafolderexists("TilePlot") != 1)
		Abort "Aborting. 'TilePlot' folder not found in root:. Please create folder and place time and data waves in that folder."
	Else
		SetDataFolder root:TilePlot		
	EndIf
	
	If(numpnts(w_pollution_time_raw) != numpnts(w_pollution_conc))
		Abort "Aborting. The time wave and the concentration wave lengths do not match. Please check data."
	EndIf
	
	If(numpnts(w_pollution_level_bounds) != dimsize(w_pollution_level_color_reference, 0) + 1)
		Abort "Aborting. The number of pollution level categories and number of corresponding colors do not match. Please check waves."
	EndIf
	
	If(dimsize(w_pollution_level_color_reference, 1) != 3)
		Abort "Aborting. The number of columns in the color reference wave is not 3 (one each for R, G, and B). Please check color reference wave."
	EndIf
	
	For(v_loop1 = 1; v_loop1 < numpnts(w_pollution_time_raw); v_loop1 += 1)
		
		If(w_pollution_time_raw[v_loop1] < w_pollution_time_raw[v_loop1 - 1])
			Abort "Aborting. The time wave is not sorted. Please sort the time wave and corresponding concentrations waves."
		EndIf
		
	EndFor
	
	If(w_pollution_level_bounds[0] != 0)
		Abort "Aborting. The lowest pollution level bound is not 0. Please set it to 0."
	EndIf
	
	If(numtype(w_pollution_level_bounds[numpnts(w_pollution_level_bounds) - 1]) != 1)
		Abort "Aborting. The highest pollution level bound is not Inf. Please set it to Inf."
	EndIf
	
	v_timer_refnum = startmstimer

	// Converts negative concentrations into NaNs. Airkorea reports NaNs as -999. In case there are already NaNs in the pollution concentration wave, we check for NaNs using numtype.
	// I've found the Airkorea data to be occasionally inconsistent.
	For(v_loop1 = 0; v_loop1 < numpnts(w_pollution_conc); v_loop1 += 1)
	
		If(numtype(w_pollution_conc[v_loop1]) == 0)
			If(w_pollution_conc[v_loop1] < 0)
				w_pollution_conc[v_loop1] = NaN
			EndIf
		Else
			w_pollution_conc[v_loop1] = NaN
		EndIf
		
	EndFor
	
	// Make waves that convert the Airkorea time wave into something Igor Pro recognizes as time. Airkorea reports the time in the form of "YYYYMMDDHH".
	// The following converts this string into times Igor Pro can recognize.
	Duplicate/O/D w_pollution_time_raw, w_pollution_time_year
	Duplicate/O/D w_pollution_time_raw, w_pollution_time_month
	Duplicate/O/D w_pollution_time_raw, w_pollution_time_day
	Duplicate/O/D w_pollution_time_raw, w_pollution_time_hour
	Duplicate/O/D w_pollution_time_raw, w_pollution_time
	w_pollution_time_year = NaN
	w_pollution_time_month = NaN
	w_pollution_time_day = NaN
	w_pollution_time_hour = NaN
	w_pollution_time = NaN
	
	Make/O/T/N = (numpnts(w_pollution_time_raw)) w_pollution_time_raw_text
	
	For(v_loop1 = 0; v_loop1 < numpnts(w_pollution_time_raw); v_loop1 += 1)
		
		sprintf s_pollution_time_raw, "%.16g\r", w_pollution_time_raw[v_loop1]
		w_pollution_time_raw_text[v_loop1] = s_pollution_time_raw
	
	EndFor
	
	SetScale d, 0, 0, "dat", w_pollution_time
	
	For(v_loop1 = 0; v_loop1 < numpnts(w_pollution_time_raw); v_loop1 += 1)
	
		sscanf w_pollution_time_raw_text[v_loop1], "%4d%2d%2d%2d", v_year, v_month, v_day, v_hour
		
		w_pollution_time_year[v_loop1] = v_year
		w_pollution_time_month[v_loop1] = v_month
		w_pollution_time_day[v_loop1] = v_day
		w_pollution_time_hour[v_loop1] = v_hour
		w_pollution_time[v_loop1] = date2secs(v_year, v_month, v_day) + v_hour * 3600
	
	EndFor
	
	// Identify number of years in the time wave. This will determine the number of tile plots generated.	
	WaveStats/Q w_pollution_time_year
	v_year_minimum = v_min
	v_year_maximum = v_max
	v_year_number_of = v_year_maximum - v_year_minimum + 1
	
	// Make time wave (one day basis) for the tile plot. 
	v_days_number_of = (date2secs(v_year_maximum, 12, 31) - date2secs(v_year_minimum, 1, 1) + 24 * 60 * 60)/(24 * 60 * 60)
	
	Make/O/D/N = (v_days_number_of) w_TilePlot_time_all_days
	Make/O/D/N = (v_days_number_of) w_TilePlot_pollution_conc_avg_all_days
	Make/O/D/N = (v_days_number_of) w_TilePlot_pollution_conc_stddev_all_days
	w_TilePlot_time_all_days = NaN
	w_TilePlot_pollution_conc_avg_all_days = NaN
	w_TilePlot_pollution_conc_stddev_all_days = NaN
	
	SetScale d, 0, 0, "dat", w_TilePlot_time_all_days
	
	// Make daily pollution concentration average wave.
	v_loop2 = 0
	
	For(v_loop1 = 1; v_loop1 < numpnts(w_TilePlot_time_all_days); v_loop1 += 1)
	
		Make/O/D/N = 0 w_bin
		
		Do
		
			If(numpnts(w_bin) == 24)
				Break
			EndIf
		
			If(v_loop2 < numpnts(w_pollution_time))
				Break
			EndIf
			
			
		
			If(w_pollution_time[v_loop2] > w_TilePlot_time_all_days[v_loop1 - 1] && w_pollution_time[v_loop2] <= w_TilePlot_time_all_days[v_loop1])
				InsertPoints/M = 0 0, 1, w_bin
				w_bin[0] = w_pollution_conc[v_loop2]	
			EndIf
		
			If(numpnts(w_bin) == 24)
				Break
			EndIf
					

		
		If(numpnts(w_bin) < 18)
			w_TilePlot_pollution_conc_avg_all_days[v_loop1 - 1] = NaN
		
		
		Else
		WaveStats/Q w_bin
		
		EndIf
		
		While(1)
	
	EndFor

	
	
	
	

	
	
	
	
	
	
	
	

	
	// Make color reference wave for entire time range.
	Make/O/D/N = (numpnts(w_pollution_time_raw)) w_pollution_level_color
	Redimension/N = (-1,3) w_pollution_level_color
	w_pollution_level_color = NaN
	
	For(v_loop1 = 0; v_loop1 < numpnts(w_pollution_time_raw); v_loop1 += 1)
	
		If(numtype(w_pollution_conc[v_loop1]) == 2)			// NaN concentrations are gray.
			w_pollution_level_color[v_loop1][0] = 45000
			w_pollution_level_color[v_loop1][1] = 45000
			w_pollution_level_color[v_loop1][2] = 45000
		Else
			For(v_loop2 = 1; v_loop2 < dimsize(w_pollution_level_color_reference, 0); v_loop2 += 1)
			
				If(w_pollution_conc[v_loop1] == 0)
					w_pollution_level_color[v_loop1][0] = w_pollution_level_color_reference[0][0]
					w_pollution_level_color[v_loop1][1] = w_pollution_level_color_reference[0][1]
					w_pollution_level_color[v_loop1][2] = w_pollution_level_color_reference[0][2]
				EndIf
				
				If(w_pollution_conc[v_loop1] > w_pollution_level_bounds[v_loop2 - 1] && w_pollution_conc[v_loop1] <= w_pollution_level_bounds[v_loop2])
					w_pollution_level_color[v_loop1][0] = w_pollution_level_color_reference[v_loop2 - 1][0]
					w_pollution_level_color[v_loop1][1] = w_pollution_level_color_reference[v_loop2 - 1][1]
					w_pollution_level_color[v_loop1][2] = w_pollution_level_color_reference[v_loop2 - 1][2]					
				EndIf
	
			EndFor
		EndIf
		
	EndFor
	

	
	
	
	
	//generate annual tileplot
	//generate weekly profile
	//generate diurnal profile
	// use jittered box whiskers plot. show avg and median. Use enoise for uniform random distribution.
	
	
	v_timer_elapsed = stopmstimer(v_timer_refnum)
	Print "Total processing time (seconds):", v_timer_elapsed/1000000
	
End



