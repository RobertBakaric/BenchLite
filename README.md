# BenchLite

[![License](https://img.shields.io/badge/license-MIT-blue.svg)]( )

Simple CLI benchmarking tool

# Synopsis

	Usage:

	-p	Testing ... (file.bench)  : file containing a list of cmd's to be benchmarked
	-l	Log file                  : file containing execution logs
	-o	output                    : directory contiaining outputs of each tool together with detailed benchmark statistics
	-b	bootstrap                 : the number of times a measurments are to be repeated
	-d	Delta T in sec            : timeframe in which memory consumption should be recorded
	-i	Session Id                : benchmark session identifier segregating different benchmarkings within the same framework
	-f	Monitor flags             : CLI options to be monitored (currently only those taking files are subjected to filesize measurments)


	Example of  my.bench file :
	
	
		#Tool -- comment line
		tool -i in -o out 
		tool2 -i in2 -o out2 


	Execute:
	bench -f "-i -o" -l My_Log_Date -o My_Bench_Out -b 10 -d 10 -s 1  -p my.bench

# Description

	Benchmarking is the practice of comparing processes and performance metrics to 
	industry standard best practice solutions. Parameters typically considered 
	within a measurment process are:
		
		a) quality of the resulting output, 
		b) execution time 
		c) memory usage 
		d) disc usage 

	"bench" is a simple cli application that utilizes all of the above stated quantifiations 
        schemas and crunches out a simple descriptive statistical summary for a set of measurments
        obtained from direct cli app executions

# Author
	
	Robert Bakaric <robertbakaric@zoho.com>

# License


  
	#  Copyright 2020 Robert Bakaric
	#  
	#  This program is free software; you can redistribute it and/or modify
	#  it under the terms of the GNU General Public License as published by
	#  the Free Software Foundation; either version 2 of the License, or
	#  (at your option) any later version.
	#  
	#  This program is distributed in the hope that it will be useful,
	#  but WITHOUT ANY WARRANTY; without even the implied warranty of
	#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	#  GNU General Public License for more details.
	#  
	#  You should have received a copy of the GNU General Public License
	#  along with this program; if not, write to the Free Software
	#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
	#  MA 02110-1301, USA.
	#  
	# 
 
