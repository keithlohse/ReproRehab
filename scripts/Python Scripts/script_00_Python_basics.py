# installing and loading packages
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# assigning values to variables and basic operations
x = 2
x = x + 3
print(x * 3)

y = 2
print(x / y)

z = "word"
print(x * z)

print(x < 2)
print(x > 2)

print(z < 2)  # This will raise a TypeError
print(z > str(2))

print(isinstance(z, str))
print(isinstance(z, (int, float)))

# some data types
# vectors/arrays
x = np.array([2, 3, 4])
y = np.array([0, 1, 0])
print(x)
print(y)
print(x * y)

z = np.array(["red", "red", "blue", "blue", "green", "green"])
print(np.unique(z, return_counts=True))
print(z.dtype)


z = pd.Series(z)
print(z.describe())
print(z.dtype)

# matrix
mat_data = np.array([1, 2, 3, 4, 5, 6, 7, 8, 9])
mat1 = mat_data.reshape((3, 3))
print(mat1)

print(mat1[0, :])
print(mat1[:, 2])
print(mat1[0, 2])

# lists
my_list = ["a", True, list(range(91, 86, -1))]
print(my_list)

print(my_list[0])
print(my_list[2])
print(my_list[2][2])

# data frames
sex = np.array(["male"] * 10 + ["female"] * 10)
height = np.concatenate((np.random.normal(67, 2.5, 10), np.random.normal(64, 2.2, 10)))

DAT1 = pd.DataFrame({"sex": sex, "height": height})
print(DAT1)

DAT1.plot(x="sex", y="height", kind="scatter")
plt.show()

# functions and arguments
print(x)
print(x.mean())
help(x.mean)

print(type(x))
print(type(z))
print(type(my_list))
print(type(DAT1))

print(pd.Series(my_list).apply(type))
print(DAT1.dtypes)

print(np.mean(x))
x = np.append(x, [np.nan, 0, 15])
print(x)
print(np.nanmean(x))


# setting the working directory
import os

print(os.getcwd())
print(os.listdir())

os.chdir("./GitHub/ReproRehab/")
print(os.listdir())
os.chdir("./data/")
print(os.listdir())

# importing data from your computer
DAT2 = pd.read_csv("data_PROCESSED_EEG.csv")
print(DAT2.head())

# importing data from the web
DAT3 = pd.read_csv("https://raw.githubusercontent.com/keithlohse/grad_stats/main/data/data_THERAPY.csv")
print(DAT3.head())
