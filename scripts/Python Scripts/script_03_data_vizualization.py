import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
import scipy.stats as stats

# 3.0. Data Visualization
data_path = "C:/Users/kelop/Documents/GitHub//ReproRehab/"
os.listdir(data_path+"data")
data = pd.read_csv(data_path + "data/data_PROCESSED_EEG.csv")
data.head()
data = data.drop(columns=["Unnamed: 0"])

# Aggregating the data across all participants
data_grouped = data.groupby("Hz").mean(numeric_only=True)
data_grouped.reset_index(inplace=True)

# Plotting frontal power
plt.close()
plt.plot(data_grouped["Hz"], data_grouped["frontal"], color="black")
plt.scatter(data_grouped["Hz"], data_grouped["frontal"], marker="o", color="black")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Power (uV^2)")
plt.title("Frontal Power")
plt.grid(True)
plt.show()

# Plotting ln_frontal power
plt.close()
plt.plot(data_grouped["Hz"], data_grouped["ln_frontal"], color="black")
plt.scatter(data_grouped["Hz"], data_grouped["ln_frontal"], marker="o", color="black")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Log-Power ln(uV^2)")
plt.title("Frontal Power")
plt.grid(True)
plt.show()

# Plotting all regions by transforming data from long to wide
data_grouped
data_wide = data_grouped[["Hz", "frontal", "central", "parietal", "occipital"]]
data_wide

plt.close()
plt.plot(data_grouped["Hz"], data_grouped["frontal"], linestyle="-", marker="o", label="Frontal")
plt.plot(data_grouped["Hz"], data_grouped["central"], linestyle="-", marker="o", label="Central")
plt.plot(data_grouped["Hz"], data_grouped["parietal"], linestyle="-", marker="o", label="Frontal")
plt.plot(data_grouped["Hz"], data_grouped["occipital"], linestyle="-", marker="o", label="Central")
plt.xlabel("Frequency log(Hz)")
plt.ylabel("Power log(uV^2)")
plt.legend(title="Region")
plt.grid(True)
plt.show()

# Plotting ln_power for all regions
data_grouped
data_wide = data_grouped[["Hz", "ln_frontal", "ln_central", "ln_parietal", "ln_occipital"]]
data_wide

plt.close()
plt.plot(data_grouped["Hz"], data_grouped["ln_frontal"], linestyle="-", marker="o", label="Frontal")
plt.plot(data_grouped["Hz"], data_grouped["ln_central"], linestyle="-", marker="o", label="Central")
plt.plot(data_grouped["Hz"], data_grouped["ln_parietal"], linestyle="-", marker="o", label="Frontal")
plt.plot(data_grouped["Hz"], data_grouped["ln_occipital"], linestyle="-", marker="o", label="Central")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Log-Power log(uV^2)")
plt.legend(title="Region")
plt.grid(True)
plt.show()


##### Resume work here:
# Averages within each condition ----
DAT_COND_AVE = data.groupby(['condition', 'Hz']).mean(numeric_only=True).reset_index()

# Plotting power by region and condition
DAT_COND_LONG = pd.melt(DAT_COND_AVE, id_vars=['condition', 'Hz'], value_vars=['frontal', 'occipital'], var_name='region', value_name='power')

plt.plot(DAT_COND_LONG['Hz'], DAT_COND_LONG['power'], color='black')
plt.scatter(DAT_COND_LONG['Hz'], DAT_COND_LONG['power'], color='black', marker='o')
plt.xlabel("Frequency (Hz)")
plt.ylabel("Power (uV^2)")
plt.title("Power by Region and Condition")
plt.legend(['frontal', 'occipital'])
plt.grid(True)
plt.show()

# Plotting power by region and condition (log scale)
DAT_COND_LONG_LOG = pd.melt(DAT_COND_AVE, id_vars=['condition', 'Hz'], value_vars=['ln_frontal', 'ln_occipital'], var_name='region', value_name='ln_power')

plt.plot(DAT_COND_LONG_LOG['Hz'], DAT_COND_LONG_LOG['ln_power'], color='black')
plt.scatter(DAT_COND_LONG_LOG['Hz'], DAT_COND_LONG_LOG['ln_power'], color='black', marker='o')
plt.xlabel("Frequency (Hz)")
plt.ylabel("Power log(uV^2)")
plt.title("Power by Region and Condition (log scale)")
plt.legend(['frontal', 'occipital'])
plt.grid(True)
plt.show()

# Spaghetti plots layering individual participant data with aggregate data
plt.figure(figsize=(10, 6))
plt.gca().set_prop_cycle(plt.cycler('color', plt.cm.Set2.colors))
for subID in DATA['subID'].unique():
    sub_data = DATA[DATA['subID'] == subID]
    plt.plot(sub_data['Hz'], sub_data['ln_occipital'], alpha=0.5)
DAT_COND_AVE.reset_index().plot(x='Hz', y='ln_occipital', color='black', linewidth=1, legend=False)
plt.xlabel("Frequency, ln(Hz)")
plt.ylabel("Power, ln(uV^2)")
plt.title("Spaghetti Plots of ln_occipital by Condition")
plt.grid(True)
plt.legend().set_visible(False)
plt.show()

# Plotting the differences between EO and EC conditions
DAT_OCCIP_WIDE = DATA[['subID', 'condition', 'Hz', 'occipital', 'ln_Hz', 'ln_occipital']].pivot(index=['subID', 'Hz'], columns='condition')
DAT_OCCIP_WIDE.columns = ['_'.join(col) for col in DAT_OCCIP_WIDE.columns]

plt.plot(DAT_OCCIP_WIDE.index.get_level_values('Hz'), DAT_OCCIP_WIDE['occipital_EC'], color='black')
plt.plot(DAT_OCCIP_WIDE.index.get_level_values('Hz'), DAT_OCCIP_WIDE['occipital_EO'], color='black')
plt.xlabel("Frequency (Hz)")
plt.ylabel("Power (uV^2)")
plt.title("Differences between EO and EC conditions")
plt.legend(['EC', 'EO'])
plt.grid(True)
plt.show()
