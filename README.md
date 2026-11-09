# R-code-for-chord-plots
R code to generate chord diagrams from Excel files, exporting high-resolution PDF and PNG format 
This code generates chord diagrams to visualize the relationship between two categorical variables. The width of each chord is proportional to the data. If a configured file is missing or the code detects a problem when reading it, it shows an error message.

1. Requirements
Install R and RStudio. The script uses the readxl and circlize packages.

2. Format of the Excel file
In the single sheet of each file, place the headers in the first row and the first column of the categorical variables.
Use the database in the file labled "example"

3. Configuration and execution
Before running the script in RStudio, adjust these parameters:
Input path in line 11 and, add the local path to Excel file.
File name with the exact name including the .xlsx extension, the sheet name, and Database identifiers of each categorical variable in lines 15-18.
Adjust the title in line 19.
Run script.
