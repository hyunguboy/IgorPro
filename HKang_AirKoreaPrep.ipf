#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.1

//	2021 Hyungu Kang, www.hazykinetics.com, hyunguboy@gmail.com
//
//	GNU GPLv3. Please feel free to modify the code as necessary for your needs.
//
//	Version 1.1 (Released 2021-03-26)
//	1.	Fixed bugs that occurred due to the function calling a wrong wave name.
//	2.	Code is compatible with Igor Pro 6.37.
//
//	Version 1.0 (Released 2020-07-02)
//	1. Initial release tested with Igor Pro 8.04 with AirKorea data. These
//		functions are not compatible with Igor Pro 6.

////////////////////////////////////////////////////////////////////////////////

//	'HKang_AirKorea_MainPrep' takes the air pollutant concentration and time
//	wave from AirKorea and converts it into something Igor Pro will recognize.
//
// For instance, the date format of AirKorea come in the form of YYYYMMDDHH.
//	Sometimes, AirKorea will report missing values as -999, but other times
//	it's recorded as NaN. I have no idea why, but the function changes
//	the -999 values to NaN.

////////////////////////////////////////////////////////////////////////////////

//	Main function that outputs the corrected concentration and legible time
//	waves unsing AirKorea data.
Function HKang_AirKorea_MainPrep(w_AirKorea_concRaw, w_AirKorea_timeRaw)
	Wave w_AirKorea_concRaw, w_AirKorea_timeRaw

	String str_concCorrected, str_timeCorrected

	If(numpnts(w_AirKorea_concRaw) != numpnts(w_AirKorea_timeRaw))
		Abort "Aborting: Concentration and time waves legnths do not match."
	EndIf

	// Prepare the data.
	HKang_AirKorea_ConcPrep(w_AirKorea_concRaw)
	HKang_AirKorea_TimePrep(w_AirKorea_timeRaw)

	str_concCorrected = nameofwave(w_AirKorea_concRaw) + "_corrected"

	Wave w_AirKorea_time

	// Table for quick look.
	Edit/K=1 w_AirKorea_time, $str_concCorrected

End

////////////////////////////////////////////////////////////////////////////////

//	Prepares the pollution concentration wave from AirKorea by converting the
//	negative values to NaN.
Function HKang_AirKorea_ConcPrep(w_AirKorea_concRaw)
	Wave w_AirKorea_concRaw

	Variable v_negCount = 0	// Count of -999.
	Variable v_NaNCount = 0	// Count of NaN.	
	Variable iloop
	String str_waveName = nameofwave(w_AirKorea_concRaw)

	// Make corrected wave that removes negative nummbers.
	Duplicate/O w_AirKorea_concRaw, $str_waveName + "_corrected"

	Wave w_tempRef = $str_waveName + "_corrected"

	// Remove negative values and count existing NaN points.
	For(iloop = 0; iloop < numpnts(w_AirKorea_concRaw); iloop += 1)
		If(numtype(w_AirKorea_concRaw[iloop]) == 0)
			If(w_AirKorea_concRaw[iloop] < 0)
				w_tempRef[iloop] = NaN

				v_negCount += 1
			EndIf
		Else
			v_NaNCount += 1
		EndIf
	EndFor

	Print "Number of negative concentration points: ", v_negCount
	Print "Number of NaN concentration points: ", v_NaNCount

End

////////////////////////////////////////////////////////////////////////////////

//	Prepares time wave coming from AirKorea, which needs to be converted so that
//	Igor Pro recognizes it. The date format of AirKorea should be in the form of
//	YYYYMMDDHH.
Function HKang_AirKorea_TimePrep(w_AirKorea_timeRaw)
	Wave w_AirKorea_timeRaw

	Variable iloop
	Variable v_year, v_month, v_day, v_hour
	String str_year, str_month, str_day, str_hour
	String str_temptime

	Make/O/D/N=(numpnts(w_AirKorea_timeRaw)) w_AirKorea_time = NaN
	SetScale d, 0, 1, "dat", w_AirKorea_time

	For(iloop = 0; iloop < numpnts(w_AirKorea_timeRaw); iloop += 1)
		str_temptime = num2istr(w_AirKorea_timeRaw[iloop])

		sscanf str_temptime, "%4d%2d%2d%2d", v_year, v_month, v_day, v_hour

		w_AirKorea_time[iloop] = date2secs(v_year, v_month, v_day) + v_hour * 3600
	EndFor

End