# R-code-for-chord-plots
R code to generate chord diagrams from six (6) Excel databases, exporting high-resolution PDF figures  
This code generates chord diagrams to visualize the relationship between two categorical variables. The width of each chord is proportional to the data. The script generates six individual diagrams, one for each Excel file, and a mosaic that brings the six together. The figures are exported in PDF and PNG formats. If a configured file is missing or the code detects a problem when reading it, it shows an error message.

1. Requirements
Install R and RStudio. The script uses the readxl and circlize packages. To run it, gather the six Excel files (.xlsx) in the same folder, each with a single sheet.

2. Format of the Excel files
In the single sheet of each file, place the headers in the first row and the first column of the categorical variables.
Save the counts as numeric values. If you copy them from another sheet, use «Paste Values» so that the file contains the results of the formulas. Leave cells with missing data empty.

**Abbreviated example with fictitious data:
Department	Year 1	Year 2	Year 3
Antioquia	    12	    18	   21
Bogotá	       8	  	14
Valle del Cauca	      6		   9

3. Configuration and execution
Before running the script in RStudio, adjust these parameters:
Parameter               Line    What you must enter

Input path	             11	   Local path of the folder that contains the six Excel files

File names	           16-21   Exact name of each file, including the .xlsx extension

Database identifiers	 28-29	 Identifier of each combination of category and population

Title	                 30-32	 Title of  each diagram

Once the parameters are updated, run the complete script.
