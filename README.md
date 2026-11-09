# R-code-for-chord-plots
R code to generate chord diagrams from six (6) Excel databases, exporting high-resolution PDF figures  
This code generates chord diagrams to visualize the relationship between two categorical variables. In the temperature project, the diagrams connect 33 territorial units of Colombia with 15 individual years. The width of each chord is proportional to the number of patients seen in the territory and year it connects.
1. Requirements
Install R and RStudio. The script uses the readxl and circlize packages. To run it, gather the six Excel files (.xlsx) in the same folder, each with a single sheet.
2. Obtaining and organizing the data
Extract the counts of patients seen from the SISPRO cubes following the procedure reviewed during the training sessions. Use the values obtained from the cube directly, without performing additional calculations.
Prepare three databases for patients in general and three for patients seen by physicians. In each group, apply the filters that correspond.
Category	Codes included	Required files
Temperature:	Codes associated with cold or heat	One for patients in general and another for patients seen by physicians
Heat:	Only codes associated with heat	One for patients in general and another for patients seen by physicians
Cold:	Only codes associated with cold	One for patients in general and another for patients seen by physicians
Identify each file by its category and population. Record the SISPRO filters that were applied in each extraction.
3. Format of the Excel files
In the single sheet of each file, place the headers in the first row. The first column contains the names of the departments and the next 15 columns correspond to the individual years. Each cell contains the patient count for that combination of territory and year, according to the filters of the file.
Save the counts as numeric values. If you copy them from another sheet, use «Paste Values» so that the file contains the results of the formulas. Leave cells with missing data empty.
**Abbreviated example with fictitious data:
Department	Year 1	Year 2	Year 3
Antioquia	    12	    18	   21
Bogotá	       8	  	14
Valle del Cauca	      6		   9
In the input files, replace the headers of the example with the corresponding years. The original code converts empty cells to zero when generating the diagram.
4. Configuration and execution
Before running the script in RStudio, adjust these parameters:
Parameter               Line    What you must enter
Input path	             11	   Local path of the folder that contains the six Excel files
File names	           16-21   Exact name of each file, including the .xlsx extension
Database identifiers	 28-29	 Identifier of each combination of category and population
Title	                 30-32	 Title of  each diagram
Once the parameters are updated, run the complete script.
5. Output files
The script generates six individual diagrams, one for each Excel file, and a mosaic that brings the six together. The figures are exported in PDF and PNG formats. If a configured file is missing or the code detects a problem when reading it, it shows an error message.
