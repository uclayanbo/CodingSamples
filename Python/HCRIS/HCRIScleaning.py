
###############################################################################
#create a function to identify data version
def getFileInfo(filename):
    if "long" in filename.lower():
        year_pos = 3
    else:
        year_pos = 1
    
    #"snf" data has version 96 or 10
    if "snf" in filename.lower():
        data_category="SNF"
        if "_10_" in filename or "snf10" in filename.lower():
            version="10"
        else:
            version="96"
    
    #"hosp" has 96 version and 10
    if "hosp" in filename:
        data_category="HOSP"
        if "hosp" in filename:
            version="10"
        else:
            version="96"
    
    #"hospc" data has 99 and 14 version
    if "hospc" in filename:
        data_category="HOSPC"
        if "hospc14" in filename:
            version="14"
        else:
            version="99"
    
    #"cmhc" has 10 and 17 version
    if "cmhc" in filename:
        data_category="CMHC"
        if "cmhc17" in filename:
            version="17"
        else:
            version="10"
    
    year = int(filename.split('_')[year_pos])
    return version, data_category, year


###############################################################################
def widesheet(filename, folder_path, linecombination = False):
    import pandas as pd
    import numpy as np
    
    if "nber" in folder_path.lower():
        df = pd.read_csv(folder_path + "/" + filename, low_memory = False)
    else:
        df = pd.read_csv(folder_path + "/" + filename, names = ['rpt_rec_num', 'wksht_cd', 'line_num', 'clmn_num', 'itm_val_num'], low_memory = False)
    
    vsn, dc, year = getFileInfo(filename)
    
    if linecombination == True:
        
        #The line number minues its residual to 100 will return the its closest 100 digits value
        def f(x):
            return x-x%100
        
        # Take the all the lines out and convert it to an array
        line_num = df.values.T[2]
        
        # Create an array with new line_num
        new_line_num = np.vectorize(f)(line_num)
        
        # Change the line num to the new array
        df['line_num']=new_line_num
        
        # Sum itm_val_num of duplicate rows
        df=df.groupby(['rpt_rec_num', 'wksht_cd', 'line_num', 'clmn_num'],as_index=False)[['itm_val_num']].sum()
    
    
    # Change line number and column number's format. For example, line number 100 will be 00100
    df['line_num']=df['line_num'].map(str).str.zfill(5)
    df['clmn_num']=df['clmn_num'].map(str).str.zfill(5)
    
    # Create a new column to help convert the long sheet into a wide sheet
    df['MERGE_VARIABLE'] = df['wksht_cd'] + '_' + df['line_num'].map(str) + '_' + df['clmn_num'].map(str)
    
    
    # Convert long sheet into wide sheet with all variables
    df.drop_duplicates(subset = ['rpt_rec_num', 'MERGE_VARIABLE'], keep = 'last', inplace = True)
    df = df.pivot(index = 'rpt_rec_num', columns='MERGE_VARIABLE', values='itm_val_num')
    df.columns.name = None
    df=df.reset_index('rpt_rec_num')
    
    df["version"]=vsn
    df["data_category"]=dc
    df["HCRIS_file_year"]=year
    
    return df


###############################################################################
#Convert the data from long sheet to wide sheet by inputing the requested year
#data_category input format: which data wanted to be imported(for example, SNF) with quotation
#data_year input format: 1995 to 2017 withought quotation
#Linecombination true if we want to combine all data such as line 101 to 100
def convert(data_category, data_year, HCRISdatadir, linecombination = False):
    import pandas as pd
    import numpy as np
    import os
    from datetime import datetime
    
    print("Processing: ", data_category, " ", data_year, " ", datetime.now().strftime("%d/%m/%Y %H:%M:%S"))
    
    #direct the path to the correct folder, allow for switching between different types of healthcare provider
    folder_path = HCRISdatadir + "/" + data_category
    
    # Find the correct file name based on the input. 
    filenames =  [i for i in os.listdir(folder_path) if str(data_year) in i and "nmrc" in i.lower()]
    Final_Wide_Sheet=[widesheet(ff,folder_path) for ff in filenames]
    
    return Final_Wide_Sheet


###############################################################################
#data_category input format: which data wanted to be imported(for example, SNF) with quotation
#Version is should be inputed in the same format as the label file's tab name. If it is a string please include quotation
#If merge is true then items with same line will merge
def label(data_file,HCRIScodedir):
    import pandas as pd
    import numpy as np
    
    #This should not be needed anymore but is good for robustness.
    if isinstance(data_file, list): #Check if a list
        if len(data_file)==1: #If a one-element vector, use only dataframe.
            data_file = data_file[0]
        else: #If multiple elements, send each into label() individually and concatenate.
            return pd.concat([label(dd,HCRIScodedir) for dd in data_file])
    
    #load data category and data version from the wide sheet
    data_category=data_file["data_category"].unique()[0]
    version=data_file["version"].unique()[0]
    
    #direct the path to the correct folder
    label_sheet=pd.read_excel(HCRIScodedir+"/"+data_category+"/Labels.xlsx",sheet_name=str(version))
    
    vname=['rpt_rec_num','data_category','HCRIS_file_year','version']
    vlocation=['rpt_rec_num','data_category','HCRIS_file_year','version']
    for i in range(len(label_sheet)):
        #To make sure all columns will be selected    
        for j in range(label_sheet.iloc[i]['column_min'],label_sheet.iloc[i]['column_max']+1):
            a=label_sheet.iloc[i]['sheet'] + str(label_sheet.iloc[i]['sheet_modifier']) + '0000' + str(label_sheet.iloc[i]['sheet_part'])+'_' + str(label_sheet.iloc[i]['line_num']*100).zfill(5) + '_' + str(j*100).zfill(5)
            # There are some variables that don't have value in the entire database, this if function
            # is to only pick values that are not null for entire data set. 
            if a in data_file.columns:
                b=label_sheet.iloc[i]['var_name']
                vname.append(b)
                vlocation.append(a)
    
    
    # To only select variables from label excel
    labeled_sheet=data_file[vlocation]
    # Rename columns by description
    labeled_sheet.columns=vname
    
    
    #Select duplicate titles
    duplicate_titles=[]
    not_duplicate_titles=[]
    for i in vname:
        #find titles that are duplicates in variable name
        if vname.count(i)>1:
            # only append once for each duplicate names
            if i not in duplicate_titles:
                duplicate_titles.append(i)
        else:
            not_duplicate_titles.append(i)
    
    #Sum values for duplicate variables names
    table_after_sum=labeled_sheet[duplicate_titles].groupby(sort=False,level=0, axis=1).sum(min_count=1)
    #create dataframe with variable names that do not need to sum
    table_of_nonduplicates=labeled_sheet[not_duplicate_titles]
    
    #Combine two tables
    final_labeled_sheet=pd.concat([table_after_sum, table_of_nonduplicates], axis=1, sort=False)
    
    return final_labeled_sheet


###############################################################################
def assemble_HCRIS_category(data_category,
                            data_year,                # for which years of the data we want to process
                            datadir,                  # data directory
                            codedir,                  # code directory, where cleaning.py and the label files are located
                            outputpath,               # path and name of the output file
                            linecombination = False):
    
    import pandas as pd
    import numpy as np
    import os
    import sys
    sys.path.insert(1, codedir)
    
    file_list = os.listdir(datadir + "/" + data_category)
    if "nber" in data_category.lower():
        print("WARNING: HCRIS-SNF files from NBER contain duplicates for 2010-2012 because both 96 and 10 forms were reported.")
    
    #header for the RPT data files
    RPT_header = ["rpt_rec_num", "prvdr_ctrl_type_cd", "prvdr_num", "npi", "rpt_stus_cd",
                  "fy_bgn_dt", "fy_end_dt", "proc_dt", "initl_rpt_sw", "last_rpt_sw", "trnsmtl_num",
                  "fi_num", "adr_vndr_cd", "fi_creat_dt", "util_cd", "npr_dt", "spec_ind", "fi_rcpt_dt"]
    
    #Load and append all labeled HCRIS data.
    labeled_df = pd.concat([label(convert(data_category, i, datadir, linecombination = linecombination),
                                  codedir) for i in data_year], ignore_index = True)
    
    #Appends all report files
    if "nber" in data_category.lower():
        print("WARNING: HCRIS-SNF files from NBER contain duplicates for 2010-2012 because both 96 and 10 forms were reported.")
        RPTs = pd.concat([pd.read_csv(datadir + "/" + data_category + "/" + ff) for ff in file_list if "rpt" in ff.lower()], ignore_index = True)
    else:
        RPTs = pd.concat([pd.read_csv(datadir + "/" + data_category + "/" + ff, names = RPT_header) for ff in file_list if "rpt" in ff.lower()], ignore_index = True)
    
    
    #Confirms that no duplicates for rpt_rec_num
    assert ~any(RPTs.duplicated(subset = ['rpt_rec_num']))
    
    #Merge the reports onto the labeled_df
    output_df = labeled_df.merge(RPTs, on = 'rpt_rec_num')
    
    #have to convert "trnsmtl_num" (mixed of int and str types) to str type
    output_df["trnsmtl_num"] = output_df["trnsmtl_num"].astype(str)
    
    print("Output data's dimension:", output_df.shape)
    print("Labeled data's dimension:", labeled_df.shape)
    
    if "nber" not in data_category.lower():
        assert output_df.shape[0] == labeled_df.shape[0] #Make sure we matched every labeled_df observation.
    output_df.dropna(axis = 1, how = "all").to_stata(outputpath)

