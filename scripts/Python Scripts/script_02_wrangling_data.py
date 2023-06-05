import numpy as np
import pandas as pd

# 2.0. Wrangling Data
import os

os.chdir("~/GitHub/ReproRehab/")
print(os.listdir())
os.chdir("./data/")
print(os.listdir())

DATA = pd.read_csv("./MASTER_EO_and_EC_EEG.csv", header=True)
print(DATA.head())

# selecting specific columns
print(DATA[["subID", "condition", "Hz", "Fz"]])

print(DATA.loc[:, "subID":"F3"])

DAT2 = DATA.drop(columns=["X"])
print(DAT2.head())

# filtering specific rows
print(DAT2[DAT2["subID"] == "oa01"])

print(DAT2[(DAT2["subID"] == "oa01") | (DAT2["subID"] == "oa02")])

print(DAT2[(DAT2["subID"] == "oa01") & (DAT2["Hz"] == 0.997)])

print(DAT2[DAT2["Hz"] <= 30])

# computing new variables
DAT3 = DAT2.copy()
DAT3["Frontal"] = (DAT3["F3"] + DAT3["F7"] + DAT3["Fz"] + DAT3["F4"] + DAT3["F8"]) / 5
print(DAT3.head())

DAT3["frontal"] = DAT3[["F3", "F7", "Fz", "F4", "F8"]].mean(axis=1, skipna=True)
DAT3["central"] = DAT3[["C3", "Cz", "C4"]].mean(axis=1, skipna=True)
DAT3["parietal"] = DAT3[["P3", "P7", "Pz", "P4", "P8"]].mean(axis=1, skipna=True)
DAT3["occipital"] = DAT3[["O1", "Oz", "O2"]].mean(axis=1, skipna=True)
print(DAT3.head())

import matplotlib.pyplot as plt

plt.scatter(DAT3["Frontal"], DAT3["frontal"])
plt.show()

corr = DAT3[["Frontal", "frontal"]].dropna().corr(method="pearson")
print(corr)

# Selecting only the columns we want
DAT4 = DAT3[["subID", "condition", "Hz", "Frontal", "central", "parietal", "occipital"]].copy()
DAT4["ln_Hz"] = np.log(DAT4["Hz"])
DAT4["ln_frontal"] = np.log(DAT4["Frontal"])
DAT4["ln_central"] = np.log(DAT4["central"])
DAT4["ln_parietal"] = np.log(DAT4["parietal"])
DAT4["ln_occipital"] = np.log(DAT4["occipital"])
print(DAT4.head())

os.chdir("~/GitHub/ReproRehab/data/")
DAT4.to_csv("data_PROCESSED_EEG.csv", index=False)
