
import os
import sys
HCBdir = str(sys.argv[1])
HCBcode = str(sys.argv[2])
os.chdir(HCBcode + "/Cleaning/HCRIS")

from HCRIScleaning import assemble_HCRIS_category

#Convert all SNF numeric raw data into longsheets, label them, and merge them with raw RPT data.
#Concatenate the data from all available years.
assemble_HCRIS_category(data_category = "SNF_CMS",
                        data_year = [x for x in range(1995, 2024)],
                        datadir = HCBdir + "/Data/raw/HCRIS",
                        codedir = HCBcode + "/Cleaning/HCRIS",
                        outputpath = HCBdir + "/Data/intermediate/HCRIS/HCRIS_SNF_CMS_95to23_raw.dta")


assemble_HCRIS_category(data_category = "SNF_NBER",
                        data_year = [x for x in range(1995, 2022)],
                        datadir = HCBdir + "/Data/raw/HCRIS",
                        codedir = HCBcode + "/Cleaning/HCRIS",
                        outputpath = HCBdir + "/Data/intermediate/HCRIS/HCRIS_SNF_NBER_95to21_raw.dta")

