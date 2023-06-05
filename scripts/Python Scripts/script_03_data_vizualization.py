import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import scipy.stats as stats

# 3.0. Data Visualization
data_path = "~/GitHub/ReproRehab/"
data_files = os.listdir(data_path)
data = pd.read_csv(data_path + "data_PROCESSED_EEG.csv")

# Aggregating the data across all participants
data_grouped = data.drop("X", axis=1).groupby("Hz").mean(numeric_only=True)

# Plotting frontal power
plt.plot(data_grouped.index, data_grouped["frontal_mean"], color="black")
plt.scatter(data_grouped.index, data_grouped["frontal_mean"], marker="o", color="black")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Power (uV^2)")
plt.title("Frontal Power")
plt.grid(True)
plt.show()

# Plotting ln_frontal power
plt.plot(data_grouped["ln_Hz"], data_grouped["ln_frontal"], color="black")
plt.scatter(data_grouped["ln_Hz"], data_grouped["ln_frontal"], marker="o", color="black")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Power (uV^2)")
plt.title("Frontal Power")
plt.grid(True)
plt.show()

# Plotting all regions by transforming data from long to wide
data_wide = data_grouped.drop("ln_Hz", axis=1).unstack().reset_index()
data_wide.columns = ["region", "Hz", "power"]
plt.plot(data_wide["Hz"], data_wide["power"], color=data_wide["region"])
plt.scatter(data_wide["Hz"], data_wide["power"], color=data_wide["region"], marker="o")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Power (uV^2)")
plt.legend(data_wide["region"])
plt.grid(True)
plt.show()

# Plotting ln_power for all regions
data_wide_ln = data_grouped.drop("Hz", axis=1).unstack().reset_index()
data_wide_ln.columns = ["region", "ln_Hz", "ln_power"]
plt.plot(data_wide_ln["ln_Hz"], data_wide_ln["ln_power"], color=data_wide_ln["region"])
plt.scatter(data_wide_ln["ln_Hz"], data_wide_ln["ln_power"], color=data_wide_ln["region"], marker="o")
plt.xlabel("Frequency log(Hz)")
plt.ylabel("Power log(uV^2)")
plt.legend(data_wide_ln["region"])
plt.grid(True)
plt.show()

# Averages within each condition
data_cond_ave = data.groupby("Hz").mean(numeric_only=True).reset_index()

# Plotting power for each condition and region
data_cond_long = pd.melt(data_cond_ave, id_vars=["Hz"], value_vars=["frontal", "ln_frontal"],
                         var_name="region", value_name="power")
plt.plot(data_cond_long["Hz"], data_cond_long["power"], color=data_cond_long["region"])
plt.scatter(data_cond_long["Hz"], data_cond_long["power"], color=data_cond_long["region"], marker="o")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Power (uV^2)")
plt.legend(data_cond_long["region"])
plt.grid(True)
plt.show()

# Plotting ln_power for each condition and region
data_cond_long_ln = pd.melt(data_cond_ave, id_vars=["ln_Hz"], value_vars=["ln_frontal", "ln_occipital"],
                            var_name="region", value_name
###


# Spaghetti Plots layering individual participant data with aggregate data
plt.figure(figsize=(10, 6))
for _, row in DATA.iterrows():
    plt.plot(row["ln_Hz"], row["ln_occipital"], color="gray", alpha=0.5)
plt.gca().set_prop_cycle(None)
for _, row in DAT_COND_AVE.iterrows():
    plt.plot(row["ln_Hz"], row["ln_occipital"], color="black", linewidth=1)
plt.xlabel("Frequency, ln(Hz)")
plt.ylabel("Power, ln(uV^2)")
plt.title("Spaghetti Plots")
plt.legend([], title="Region")
plt.grid(True)
plt.show()

# Plot of the differences between EO and EC conditions
DAT_OCCIP_WIDE = DATA.assign(group=DATA["subID"].str[:2])
DAT_OCCIP_WIDE = DAT_OCCIP_WIDE[["subID", "condition", "group", "Hz", "occipital", "ln_Hz", "ln_occipital"]]
DAT_OCCIP_WIDE = DAT_OCCIP_WIDE.pivot(index=["subID", "group", "Hz", "ln_Hz"], columns="condition",
                                      values=["occipital", "ln_occipital"])
DAT_OCCIP_WIDE.columns = ["occipital_ec", "occipital_eo", "ln_occipital_ec", "ln_occipital_eo"]
DAT_OCCIP_WIDE["diff_ln_power"] = DAT_OCCIP_WIDE["ln_occipital_ec"] - DAT_OCCIP_WIDE["ln_occipital_eo"]

plt.figure(figsize=(10, 6))
for _, row in DAT_OCCIP_WIDE.iterrows():
    plt.plot(row["ln_Hz"], row["diff_ln_power"], color="gray", alpha=0.5)
plt.gca().set_prop_cycle(None)
for _, row in DAT_COND_AVE.iterrows():
    plt.plot(row["ln_Hz"], row["ln_occipital"], color="black", linewidth=1)
plt.xlabel("Frequency (Hz)")
plt.ylabel("Power (uV^2)")
plt.title("Differences between EO and EC conditions")
plt.legend([], title="Region")
plt.grid(True)
plt.show()

# Calculating the group mean differences
DAT_OCCIP_WIDE_GROUP_AVE = DAT_OCCIP_WIDE.groupby(["group", "Hz"]).agg({
    "ln_Hz": lambda x: x.iloc[0],
    "diff_ln_power": "mean"
}).reset_index()

plt.figure(figsize=(10, 6))
for _, row in DAT_OCCIP_WIDE.iterrows():
    plt.plot(row["ln_Hz"], row["diff_ln_power"], color="gray", alpha=0.5)
plt.gca().set_prop_cycle(None)
for _, row in DAT_OCCIP_WIDE_GROUP_AVE.iterrows():
    plt.plot(row["ln_Hz"], row["diff_ln_power"], color="black", linewidth=1)
plt.xlabel("Frequency, ln(Hz)")
plt.ylabel("Change in Log Power (EC-EO)")
plt.title("Group Mean Differences")
plt.legend([], title="Region")
plt.grid(True)
plt.show()
