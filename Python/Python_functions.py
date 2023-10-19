#This Python script defines the functions used in the prediction stage.

import os
import pickle
import time
import pandas as pd
import gc
import numpy as np
import lightgbm as lgb
import datetime
from sklearn.metrics import mean_squared_error, mean_absolute_error, log_loss, roc_curve, auc, make_scorer, r2_score, accuracy_score
from sklearn.model_selection import train_test_split, GridSearchCV, KFold
import matplotlib
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm


###############################################################################
#Plot the importance of the features. Not sure how to set the figure size to avoid the top white gap.
def plot_feature_importances(feature_importance, names):
    plt.figure(figsize = (3, len(feature_importance) * .5))
    
    #Make importances relative to max importance.
    feature_importance_scaled = 100.0 * (feature_importance / feature_importance.max())
    sorted_idx = np.argsort(feature_importance_scaled)
    pos = np.arange(sorted_idx.shape[0]) + .5
    
    plt.barh(pos, feature_importance_scaled[sorted_idx], align = 'center')
    plt.yticks(pos, names[sorted_idx])
    plt.xlabel('Relative Importance')
    plt.title('Variable Importance')
    plt.show(block = False)
    plt.close()
    
    print(zip(feature_importance[sorted_idx], names[sorted_idx]))


###############################################################################
#Pick the columns that are sufficiently close in missing rates for adv and non-adv.
def get_cols(data_adv, data_no_adv, max_pct_diff):
    miss_pct_adv = (data_adv.isnull().sum()) / len(data_adv)
    miss_pct_no_adv = (data_no_adv.isnull().sum()) / len(data_no_adv)
    
    d_miss_pct = miss_pct_adv - miss_pct_no_adv
    abs_d_miss = d_miss_pct.abs()
    
    cols = abs_d_miss[abs_d_miss < max_pct_diff].axes[0]
    return cols


###############################################################################
#Fit a ML model for prediction.
def fit_ML(full_data, y_var, i_set, v_set, gridParams, fitParams, scorer,
           objective = 'regression', n_estimators = 10000, early_stopping_rounds = 10,
           percentile_cutoff = 0, selection_function = False, monotone_constraints = None):
    
    if percentile_cutoff > 0:
        print('Selecting Variables')
        selection_cutoff = np.percentile(selection_function.feature_importances_, percentile_cutoff)
        rel_factors = selection_function.feature_importances_ >= selection_cutoff
        v_set_final = v_set[rel_factors]
        
    else:
        print('No Variable Selection')
        v_set_final = v_set
    
    X_full = full_data[i_set][v_set_final]
    y_full = y_var[i_set]
    X_train, X_test, y_train, y_test = train_test_split(X_full, y_full, test_size = .2, random_state = 1)
    
    #Further split the testing set into eval and holdout sets.
    X_eval, X_holdout, y_eval, y_holdout = train_test_split(X_test, y_test, test_size = .5, random_state = 1)
    fitParams['eval_set'] = [(X_eval, y_eval)]
    
    if objective == 'binary':
        gb = lgb.LGBMClassifier(objective = objective, n_estimators = n_estimators, n_jobs = 24)
    
    else:
        gb = lgb.LGBMRegressor(objective = objective, n_estimators = n_estimators, n_jobs = 24,
                               monotone_constraints = monotone_constraints)
    
    cv = KFold(n_splits = 3, shuffle = True)
    grid = GridSearchCV(gb, gridParams, cv = cv, scoring = scorer, n_jobs = 24)
    
    grid.fit(X_train, y_train, early_stopping_rounds = early_stopping_rounds, **fitParams)
    errs_holdout = grid.predict(X_holdout) - y_holdout
    loss_holdout = -scorer(estimator = grid.best_estimator_, X = X_holdout, y_true = y_holdout)
    
    #Out-of-sample R-squared or accuracy (goodness-of-fit).
    if objective == 'binary':
        gof_holdout = accuracy_score(y_true = y_holdout, y_pred = grid.predict(X_holdout))
    
    else:
        gof_holdout = r2_score(y_true = y_holdout, y_pred = grid.predict(X_holdout))
    
    return grid, errs_holdout, loss_holdout, v_set_final, gof_holdout


###############################################################################
#Search for and return the optimal model and parameters.

#Declare the fit parameters.
fitParams = {}
fitParams['eval_metric'] = 'l2'
fitParams['verbose'] = False


def getPreds(XData,
             Y,
             fitParams = fitParams,
             leaf_vals_init = 5,
             lv_init_interval = 10,
             lv_num_intervals = 4,
             lv_interval_expansion = 2,
             learn_vals = [.05, .01, .005, .001],
             start_learn = .01,
             vsel_leaves = 30,
             percentile_cutoff = 75,
             use_vsel_subsample = False,
             vsel_subsample_size = .1,
             use_subsample = False,
             subsample_size = .1,
             itermax = 5):
    
    cols = XData.columns
    
    #Mark samples if using subsampling.
    randnums = np.random.uniform(0, 1, XData.shape[0])
    full_sample = randnums < 2
    subsample = randnums < subsample_size
    randnums_vsel = np.random.uniform(0, 1, XData.shape[0])
    subsample_vsel = randnums < vsel_subsample_size
    
    #Declare the scorer.
    l2_scorer = make_scorer(mean_squared_error, greater_is_better = False)
    
    
    ###############################################################################
    #Select variables.
    if percentile_cutoff > 0:
        gridParams_vsel = {
            'num_leaves': [vsel_leaves],
            'learning_rate': [start_learn],
        }
        
        print("Started selecting variables at: " + str(datetime.datetime.now()))
        if use_vsel_subsample:
            print("Using subsample for variable selection.")
            vsel_grid, vsel_errs, vsel_loss, vsel_vset, _ = fit_ML(XData, Y, subsample_vsel, cols, gridParams_vsel, fitParams, l2_scorer)
        else:
            vsel_grid, vsel_errs, vsel_loss, vsel_vset, _ = fit_ML(XData, Y, full_sample, cols, gridParams_vsel, fitParams, l2_scorer)
        
        feature_importances = vsel_grid.best_estimator_.feature_importances_
        
        #Plot the feature importances to know roughly what they are.
        plot_feature_importances(feature_importances, cols)
        
        #Plot the predictive distribution.
        plt.hist(vsel_grid.best_estimator_.predict(XData[cols], n_jobs = 24), bins = 100, alpha = .5, label = 'VSl Pred Dist', density = True)
        plt.show(block = False)
        
        #Finish selection.
        selection_cutoff = np.percentile(feature_importances, percentile_cutoff)
        rel_factors = feature_importances >= selection_cutoff
        cols = XData[cols[rel_factors]].columns
        
        print("Finished selecting variables at: " + str(datetime.datetime.now()))
        print("The loss was: " + str(vsel_loss))
    
    
    ###############################################################################
    found_opt_leaf = False
    leaf_base = leaf_vals_init
    leaf_interval = lv_init_interval
    
    iternum = 1
    while (found_opt_leaf == False) & (iternum <= itermax):
        leaf_vals = [leaf_base + lvi * leaf_interval for lvi in range(lv_num_intervals)]
        
        #Create the grid parameters.
        gridParams_leaf = {
            'num_leaves': leaf_vals,
            'learning_rate': [start_learn],
        }
        
        #Find optimal number of leaves.
        print("Started leaf grid " + str(leaf_vals) + " at: " + str(datetime.datetime.now()))
        if use_subsample:
            print("Using subsample.")
            leaf_grid, leaf_errs, leaf_loss, leaf_vset, _ = fit_ML(XData, Y, subsample, cols, gridParams_leaf, fitParams, l2_scorer)
        else:
            leaf_grid, leaf_errs, leaf_loss, leaf_vset, _ = fit_ML(XData, Y, full_sample, cols, gridParams_leaf, fitParams, l2_scorer)
        
        print("Finished leaf grid at: " + str(datetime.datetime.now()))
        print("Best loss was: " + str(leaf_loss))
        
        #Print optimal leaves.
        opt_leaves = leaf_grid.best_params_['num_leaves']
        
        iternum += 1
        if opt_leaves == max(leaf_vals):
            if iternum <= itermax:
                print("Optimum leaves, %s, is max of grid. Extending grid." %opt_leaves)
            else:
                print("Reached itermax. Optimum is max of grid, %s. Starting learn grid." %opt_leaves)
            leaf_interval += lv_interval_expansion
            leaf_base = max(leaf_vals)
        else: 
            print("Optimum leaves is %s. Starting learn grid." %opt_leaves)
            found_opt_leaf = True
    
    #Create learning grid.
    gridParams_learn = {
        'num_leaves': [opt_leaves],
        'learning_rate': learn_vals,
    }

    #Find the optimal learning rate.
    print("Started learn grid at: " + str(datetime.datetime.now()))
    if use_subsample:
        learn_grid, learn_errs, learn_loss, learn_vset, _ = fit_ML(XData, Y, subsample, cols, gridParams_learn, fitParams, l2_scorer)
    else:
        learn_grid, learn_errs, learn_loss, learn_vset, _ = fit_ML(XData, Y, full_sample, cols, gridParams_learn, fitParams, l2_scorer)
    
    print("Finished learn grid at: " + str(datetime.datetime.now()))
    print("Best loss was: " + str(learn_loss))

    #Print the optimal learning rate.
    opt_learn = learn_grid.best_params_['learning_rate']
    print('Optimal learn rate: ' + str(opt_learn))
    
    #Print the feature importances.
    plot_feature_importances(learn_grid.best_estimator_.feature_importances_, cols)
    
    #Import the data to predict.
    y_hats = learn_grid.best_estimator_.predict(XData[cols], n_jobs = 24)
    
    return y_hats, learn_grid.best_estimator_, learn_vset


###############################################################################
#A Python equivalent to the Stata texresults command.
#Export a Python variable to a .tex file as a LaTeX macro.
def texresults(value, macro_name, target_file, math_mode = False):
    
    #If math mode is on, there will be $ signs around the number.
    if math_mode == True:
        dollar_sign = '$'
    else:
        dollar_sign = ''
    
    #If the target file does not exist, create one.
    if os.path.isfile(target_file) == False:
        f = open(target_file, 'w+')
        f.write(r'\newcommand{' + '\\' + macro_name + '}{' + dollar_sign + str(value) + dollar_sign + '}\n')
    
    #If the target file exists, append the new LaTeX macro to it.
    else:
        f = open(target_file, "a+")
        f.write(r'\newcommand{' + '\\' + macro_name + '}{' + dollar_sign + str(value) + dollar_sign + '}\n')
    
    f.close()

