# This scripts does a spectral analysis with the new settings every 10ms taking the duration
beginPause: "Script spectral analyses - fricatives"
comment: "Leave empty to select with the browser your path"
#sentence: "parent_directory", "C:\Users\Natalja ULRICH\Desktop\Paper_Pal\test"
comment: "What is the name of your results file?"
  	sentence: "results", "spectralResultsFricatives"
  	comment: "Tier number"
  		positive: "tier", "1"
	comment: "Parameters"
		optionMenu: "Filter", 1
			option: "yes"
			option: "no"
		real: "Min frequency (Hz)", "1000"
		real: "Max frequency (Hz)", "20500"
	comment: "Peak frequency range"
		real: "Min frequency peak (Hz)", "1000"
		real: "Max frequency peak (Hz)", "20500"
	comment: "Dynamic amplitude - low"
		real: "Min frequency amplitude low (Hz)", "0"
		real: "Max frequency amplitude low (Hz)", "2000"
	comment: "Dynamic amplitude - high"
		real: "Min frequency amplitude high (Hz)", "500"
		real: "Max frequency amplitude high (Hz)", "20500"
clicked = endPause: "OK", 1

# 10ms windows first to spectrogram, then extract spectral moments

rDir$ = "C:\Users\Natalja ULRICH\Documents\GitHub\paper_Palatalisation\all_sounds_session_1"
wDir$ = "C:\Users\Natalja ULRICH\Documents\GitHub\paper_Palatalisation\spectra"
mDir$ = "C:\Users\Natalja ULRICH\Documents\GitHub\paper_Palatalisation"


# Get file list
fileList= Create Strings as file list: "fileList", rDir$+ "\*.wav"
nFile = Get number of strings

Create Table with column names: "duration_10ms_new", 0, "speaker gender file sound sentence interval nFrame iFrame steps start end dur zcp hnr peakHz peakAmpdB cog sdev skew kurt ampL ampH dynamicAmp ampLMin ampMid sibilance levelMPa levelMPaLevel levelMdB levelHPa levelHPaLevel levelHdB slopedB"


for iFile to nFile
	selectObject:fileList
	file$= Get string: iFile
	name$= file$-".wav"
	
	sound = Read from file: rDir$+"\"+name$+".wav"

	speaker$ = left$ (name$,2)
	gender$ = mid$ (name$, 4,1)
	sentence$ = mid$ (name$, 8,3)
	interval$ = mid$ (name$, 12,2)
	sound$ = mid$ (name$, 15,2)

	

selectObject: sound
dur = Get total duration
startSound = Get start time
windowLength = 0.01
nFrame = 11
#ntime = dur*100
#nFrame = floor (ntime)
steps = (dur-windowLength)/(nFrame-1)


for iFrame from 1 to nFrame
		selectObject: sound
		end = startSound+(steps*iFrame)-steps+windowLength
		start = end - windowLength
		part= Extract part: start, end, "Kaiser1", 1, "no"
				if filter = 1
					resampleFrequency = max_frequency * 2
					Resample: resampleFrequency, 50
					Filter (pass Hann band): min_frequency, max_frequency, 100
				endif
				To Spectrum: "yes"
				spectrum = Cepstral smoothing: 1000
				ltas = To Ltas (1-to-1)
				peakHz = Get frequency of maximum: min_frequency_peak, max_frequency_peak, "Parabolic"
				peakAmpdB = Get maximum: min_frequency_peak, max_frequency_peak, "Parabolic"
				ampL = Get mean: min_frequency_amplitude_low, max_frequency_amplitude_low, "dB"
				ampH = Get mean: min_frequency_amplitude_high, max_frequency_amplitude_high, "dB"
				dynamicAmp = ampH - ampL
				ampLMin = Get mean: 550, 3000, "dB"
				ampMid = Get mean: 3000, 7000, "dB"
				sibilance = ampMid - ampLMin
				selectObject: spectrum
				cog = Get centre of gravity: 2
				sdev = Get standard deviation... 2
				skew = Get skewness... 2
				kurt = Get kurtosis... 2
				levelMPa = Get band energy: 0, cog
				levelMPaLevel = levelMPa/0.01
				levelMdB = 10*log10((levelMPaLevel/0.00002)^2)
				levelHPa = Get band energy: cog, 22050
				levelHPaLevel = levelHPa/0.01
				levelHdB = 10*log10((levelHPaLevel/0.00002)^2)
				slopedB = levelMdB - levelHdB


selectObject: part
To PointProcess (zeroes): 1, "yes", "yes"
zcp = Get number of points

selectObject: sound
To Harmonicity (cc): 0.01, 75, 0.1, 1
hnr = Get value in frame: iFrame


iFrame$ = string$(iFrame)

selectObject: spectrum
Write to binary file: wDir$ + "\" + name$ + "_" + iFrame$ + "_" + "dur" + ".Spectrum"




# write values for every time frame
selectObject: "Table duration_10ms_new"
Insert row: 1
Set string value: 1, "speaker", speaker$
Set string value: 1, "gender", gender$
Set string value: 1, "file", name$
Set string value: 1, "sound", sound$
Set string value: 1, "sentence", sentence$
Set string value: 1, "interval", interval$
Set numeric value: 1, "nFrame", nFrame
Set numeric value: 1, "iFrame", iFrame
Set numeric value: 1, "steps", steps
Set numeric value: 1, "start", start
Set numeric value: 1, "end", end 
Set numeric value: 1, "dur", dur
Set numeric value: 1, "zcp", zcp
Set numeric value: 1, "hnr", hnr
Set numeric value: 1, "peakHz", peakHz
Set numeric value: 1, "peakAmpdB", peakAmpdB
Set numeric value: 1, "cog", cog
Set numeric value: 1, "sdev", sdev
Set numeric value: 1, "skew", skew
Set numeric value: 1, "kurt", kurt
Set numeric value: 1, "ampL", ampL
Set numeric value: 1, "ampH", ampH
Set numeric value: 1, "dynamicAmp", dynamicAmp
Set numeric value: 1, "ampLMin", ampLMin
Set numeric value: 1, "ampMid", ampMid
Set numeric value: 1, "sibilance", sibilance
Set numeric value: 1, "levelMPa", levelMPa
Set numeric value: 1, "levelMPaLevel", levelMPaLevel
Set numeric value: 1, "levelMdB", levelMdB
Set numeric value: 1, "levelHPa", levelHPa
Set numeric value: 1, "levelHPaLevel", levelHPaLevel
Set numeric value: 1, "levelHdB", levelHdB
Set numeric value: 1, "slopedB", slopedB
endfor


selectObject: "Table duration_10ms_new"


# Remove unused data
select all
minusObject: "Table duration_10ms_new"
minusObject: "Strings fileList"
Remove

endfor


selectObject: "Table duration_10ms_new"
Save as comma-separated file: "'mDir$'\duration_10ms_new" + ".csv"

writeInfoLine: "done"