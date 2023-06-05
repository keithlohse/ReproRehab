import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats import f_oneway
from statsmodels.formula.api import ols
from statsmodels.stats.anova import AnovaRM

# Set the working directory and read the data
data_path = "~/GitHub/ReproRehab/"
DATA = pd.read_csv(data_path + "data/data_PROCESSED_EEG.csv")

# Convert subID to a factor variable
DATA["group"] = pd.Categorical(DATA["subID"].str[:2])
DATA["group"].describe()

# 1. Example plot illustrating Alpha difference
DATA_GRP_COND_AVG = DATA[["group", "condition", "Hz", "frontal", "central", "parietal", "occipital"]] \
    .groupby(["group", "condition", "Hz"]) \
    .mean(numeric_only=True) \
    .reset_index()
DATA_GRP_COND_AVG = DATA_GRP_COND_AVG[DATA_GRP_COND_AVG["Hz"] > 2.0]

plt.figure(figsize=(10, 6))
plt.axvspan(8, 12, ymin=-np.inf, ymax=np.inf, color="grey", alpha=0.2)
for _, row in DATA_GRP_COND_AVG.iterrows():
    plt.plot(row["Hz"], row["occipital_avg"], linestyle=row["condition"])
plt.xlabel("Frequency (Hz)")
plt.ylabel("Power (uV^2)")
plt.title("Example plot illustrating Alpha difference")
plt.legend(DATA_GRP_COND_AVG["condition"].unique())
plt.grid(True)
plt.show()

# 2. Calculating Mean Alpha
X = np.arange(1, 21)
freq_bin = np.where(X < 8, "below alpha", np.where(X <= 12, "alpha", "above alpha"))
plt.plot(freq_bin, DATA["Hz"])
plt.xlabel("Frequency Bin")
plt.ylabel("Hz")
plt.title("Mean Alpha")
plt.show()

DATA_POWER_BINNED = DATA[["subID", "freq_bin", "group", "condition", "Hz", "frontal", "central", "parietal", "occipital"]] \
    .groupby(["subID", "condition", "freq_bin"]) \
    .mean(numeric_only=True) \
    .reset_index()

DATA_ALPHA_POWER = DATA_POWER_BINNED[DATA_POWER_BINNED["freq_bin"] == "alpha"]

# 3. Mixed-Factorial ANOVA of alpha power
print(DATA_ALPHA_POWER["occipital"].describe())
print(pd.crosstab(DATA_ALPHA_POWER["condition"], DATA_ALPHA_POWER["subID"]))

ALPHA = DATA_ALPHA_POWER[(DATA_ALPHA_POWER["subID"] != "oa22") & (DATA_ALPHA_POWER["subID"] != "oa24")]

anova_model = AnovaRM(data=ALPHA, depvar="ln_occipital", subject="subID", within=["condition"], between="group")
anova_results = anova_model.fit()
print(anova_results)

# 4. Plot of Occipital Alpha power by Group
plt.figure(figsize=(10, 6))
for _, row in ALPHA.iterrows():
    plt.plot(row["condition"], np.log(row["occipital"] + 1), linestyle=row["group"])
    plt.scatter(row["condition"], np.log(row["occipital"] + 1), color=row["group"], marker="o")
plt.xlabel("Condition")
plt.ylabel("Alpha Power (uV^2)")
plt.title("Occipital Alpha power by Group")
plt.legend(ALPHA["group"].unique())
plt.grid(True)
plt.show()

ALPHA_summary = ALPHA.groupby(["group", "condition"]).agg(
    average=("occipital", "mean"),
    std=("occipital", "std"),
    med=("occipital", "median"),
    ln_average=("ln_occipital", "mean"),
    ln_std=("ln_occipital", "std"),
    ln_med=("ln_occipital", "median"),
    count=("occipital", "count")
)
print(ALPHA_summary)
