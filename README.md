# Excitatory Post-Synaptic Currents (EPSCs)
This repository contains Matlab scripts for detecting EPSCs from patched cell
data.  
It generates a `DataCell.mat` file which contains all the parsed and processed
data.  
The individual `.abf` files that hold the raw data are not included due to size constraints.  
The following steps have to be taken to function properly:
1. The data from `.abf` files must be stored in individual sub-folders
2. Inside the sub-folder must also exist a `.txt` file with the same name as
   the `.abf` file

## DataCell.mat Structure

| **DataCell:**   |        |  description               |
| ----------- | ------ | -------------------------- |
| filename    |        | 'sub-folder/*.abf'         |
| Type        |        | 'K/W'                      |
| Age         |        | (days)                     |
| Gender      |        | 'M/F'                      |
| startSample |        | '-1' = do not include cell |
| stopSample  |        | '-1'= record to end |
| Fs          |        | sample frequency (Hz)      |
| decimateValue |        | down sample times |
| newFs |        | new fequency (Hz) |
| stdWindow|        | Moving std window (ms) |
| stdThreshold|        | threshold for detecting EPSC|
| spreadTime |        | mask spread time (ms) |
| numOfEvents |        | detected events |
| baselineWindow |        | points to find baseline|
| averageWindow |        | points to average events|
| averageEvent |        | average over all Events |
| **events:** |        | |
| | isRejected | if discarded as noise |
| | eventStartSample | sample in internal patch |
| | eventStopSample | sample in internal patch |
| | baseline       | for zero-ing |
| |        | |
| |        | |
| |        | |
| |        | |
| |        | |

- amplitude           'max amplitude from baseline'
- width               'width of the event'
- rise                'rise-time'
- decay               'decay-time'
- area                'area spanned by event'

## Cell Info '*.txt'
Keep this file inside the sub-folder with the `.abf` file.  
Make sure to give this file the same name as the `.abf` file.  
The file structure:
> StartTime (mins)  
> StopTime (mins)  
> Type  
> Age (days)  
> Gender  
Special Characters:
- StartTime
  - '-1' = do not include cell
  - '0' = start from the beginning
- StopTime
  - '-1' = record to the end
- Type
  - 'K' = Knock out
  - 'W' = Wild
  - '?' = Unknown
- Age
  - '-1' = Unknown
- Gender
  - 'M' = Male
  - 'F' = Female
  - '?' = Unknown

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
- patchSmooth
- patchStd
- lpfStd
- baseline
- amplitude
- width
- rise
- decay
- area

##### displayEvents.m
- Displays all collected events in a cell patch

##### statsEvents.m
- Display distributions of event properties

---
### Others
##### extractABF.m
1. Loops through all sub-directories
2. Saves full data from abf file in sub-directory `*.mat`
