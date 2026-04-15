# FFT for STAR-CCM+ Pressure Data

MATLAB tools for processing STAR-CCM+ pressure data with FFT analysis.

## Files

- `readStarCSV.m` - Read STAR-CCM+ CSV output files
- `fft_StarCCM.m` - FFT analysis for pressure fluctuations
- `example_small.csv` - Sample data (1000 time steps)

## Usage

```matlab
addpath('your/local/path/readStarCSV');

% Read data
T = readStarCSV('example_small.csv');

% FFT analysis
fft_StarCCM
```

## Requirements

- MATLAB
- Signal Processing Toolbox (for pwelch)