# Excitatory Post-Synaptic Currents (EPSCs)
This is a collection of scripts and functions written in Matlab to analyze EPSC's. The `Data.mat` file and individual `.abf` files are not included due to size constraints.

---
## Data Structure
	Data:
	- age
	- gender
	- cell[]:
		- filename                   'Cell#/''.abf'
		- si                         'sample interval microseconds'
		- fs                         'sample frequency Hz'
		- startSample                '-1'= do not include cell
		- stopSample                 '-1'= record to end
		- lpf                        'local field potential'
		- patch                      'raw clamp-patch data'
		- pathFilter                 'filtered patch data'
		- patchStd                   'value of 1-std of patch'
		- patchAvg                   'mean value'
		- lpfStd                     'valuev of 1-std of lpf'
		- lpfAvg                     'mean value'
		- events[]:                  'detected EPSC events'
			- startSample
			- stopSample
			- patch
			- lpf
			- patchMovStd         'moving std from raw patch'
			- patchStd
			- lpfStd
			- baseline            'average baseline of event'
			- amplitude           'max amplitude from baseline'
			- width               'width of the event'
			- rise                'rise-time'
			- decay               'decay-time'
			- area                'area spanned by event'
---
## Cell info.txt
1. Start time in mins | '-1' = do not include cell
2. Stop time in mins | '-1' = record to end

---
## Functions and Scripts
##### Completed Functions
- [x] extractData
- [x] filterAllData
	- [x] filterData
- [x] collectAllEvents
	- [x] collectEvents
	- [ ] displayEvents
- [ ] analyzeEvents
	- [ ] statsEvents

### extractData.m
1. Creates `Data` structure
2. Loops through all subdirectories
3. Reads `times.txt` for specific section
4. Populates cell info in the struct

###### Stores
Data.cell[]:
- filename
- si
- fs
- startSample
- stopSample
- lpf
- patch
---
### filterAllData.m
1. Loads `Data` structure
2. Loops through all cells
3. Calls filterData() and stores values to Data

##### filterData.m
void filterData(Data.cell[]);
1. Loads `cell[]`
2. Applies bandpass filter to cell().patch
3. Finds the standard deviation of total recording
4. Finds mean value of total recording

###### Stores
cell[]:
- patchFilter
- patchStd
- patchAvg
- lpfStd
- lpfAvg
---
### collectAllEvents.m
1. Loads `Data` structure
2. Loops through all cells
3. Calls collectEvents() and stores values to Data
4. Calls analyzeEvents() and stores new values

##### collectEvents.m
void collectEvents(Data.cell[])
1. Loads `cell[].patchFilter`
2. Creates moving standard deviation
3. Checks for values over std threshold
4. Creates wider mask
5. Extracts raw patches from events

###### Stores
cell[].events[]:
- startSample
- stopSample
- patch
- lpf
- patchMovStd	  'moving std from raw patch'

##### analyzeEvents.m
void analyzeEvents(Data.cell[])
1. Loads `cell[].events[]`
2. Loops through all events
2. Finds event std
3. Calculates information about each event

###### Stores
cell[].events[]:
- patchStd
- lpfStd
- baseline
- amplitude
- width
- tau

##### displayEvents.m
- Displays all collected events in a cell patch

##### statsEvents.m
- Display distributions of event properties

---
### Others
##### extractABF.m
1. Loops through all sub-directories
2. Saves full data from abf file in sub-directory `*.mat`
