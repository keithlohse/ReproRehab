import numpy as np
import pandas as pd
import os

# 2.0. Wrangling Data
os.chdir("C:/Users/kelop/Documents/GitHub/ReproRehab/")
os.listdir()
os.chdir("./data/")
os.listdir()

DATA = pd.read_csv("./MASTER_EO_and_EC_EEG.csv")
DATA.head()

# selecting specific columns
DATA[["subID", "condition", "Hz", "Fz"]]

DATA.loc[:, "subID":"F3"]

DAT2 = DATA.drop(columns=["Unnamed: 0"])
DAT2.head()

# filtering specific rows
DAT2[DAT2["subID"] == "oa01"]

DAT2[(DAT2["subID"] == "oa01") | (DAT2["subID"] == "oa02")]

DAT2[(DAT2["subID"] == "oa01") & (DAT2["Hz"] == 0.997)]


# computing new variables
DAT3 = DAT2[DAT2["Hz"] <= 30]
DAT3["Frontal"] = (DAT3["F3"] + DAT3["F7"] + DAT3["Fz"] + DAT3["F4"] + DAT3["F8"]) / 5
DAT3.head()

DAT3["frontal"] = DAT3[["F3", "F7", "Fz", "F4", "F8"]].mean(axis=1, skipna=True)
DAT3["central"] = DAT3[["C3", "Cz", "C4"]].mean(axis=1, skipna=True)
DAT3["parietal"] = DAT3[["P3", "P7", "Pz", "P4", "P8"]].mean(axis=1, skipna=True)
DAT3["occipital"] = DAT3[["O1", "Oz", "O2"]].mean(axis=1, skipna=True)
DAT3.head()

import matplotlib.pyplot as plt

plt.scatter(DAT3["Frontal"], DAT3["frontal"])
plt.show()

corr = DAT3[["Frontal", "frontal"]].dropna().corr(method="pearson")
corr

# Selecting only the columns we want
DAT4 = DAT3[["subID", "condition", "Hz", "Frontal", "central", "parietal", "occipital"]].copy()
DAT4["ln_Hz"] = np.log(DAT4["Hz"])
DAT4["ln_frontal"] = np.log(DAT4["Frontal"])
DAT4["ln_central"] = np.log(DAT4["central"])
DAT4["ln_parietal"] = np.log(DAT4["parietal"])
DAT4["ln_occipital"] = np.log(DAT4["occipital"])
DAT4.head()

os.chdir("C:/Users/kelop/Documents/GitHub/ReproRehab/data/")
DAT4.to_csv("data_PROCESSED_EEG.csv", index=False)
