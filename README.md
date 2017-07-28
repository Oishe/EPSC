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

| **DataCell:**  |        |  description                   |
| -------------- | ------ | ------------------------------ |
| filename       |        | 'sub-folder/*.abf'             |
| Type           |        | 'K/W'                          |
| Age            |        | (days)                         |
| Gender         |        | 'M/F'                          |
| startSample    |        | '-1' = do not include cell     |
| stopSample     |        | '-1' = record to end           |
| Fs             |        | sample frequency (Hz)          |
| decimateValue  |        | down sample                    |
| newFs          |        | new fequency (Hz)              |
| stdWindow      |        | moving std window (ms)         |
| stdThreshold   |        | threshold for detecting events |
| spreadTime     |        | mask spread time (ms)          |
| numOfEvents    |        | detected events                |
| baselineWindow |        | points to find baseline        |
| averageWindow  |        | points to average events       |
| averageEvent   |        | average over all Events        |
| amplitudes     |        | array with event amplitudes    |
| **events:**    |        |                                |
|      | eventStartSample | sample in internal patch (Fs)  |
|      | eventStopSample  | sample in internal patch       |
|      | baseline         | for zero-ing                   |
|      | amplitude        | min value from baseline        |
|      | decay            | time to 37% decay              |
|      | area             | area under the event           |
|      | powerSpectrum    |                                |

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
