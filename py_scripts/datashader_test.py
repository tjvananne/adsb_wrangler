import datashader as ds
import datashader.transfer_functions as tf
from datashader.colors import inferno
import pandas as pd

# df = pd.read_csv("../data/daily_agg/all_daily_2017-07-30.csv", skipinitialspace=True)
df = pd.read_csv("../data/daily_agg/all_daily_2017-07-30_clean.csv", skipinitialspace=True)

print(df.columns.values)
cvs = ds.Canvas(plot_width=360, plot_height=360)
agg = cvs.line(df, 'Lat', 'Long', ds.reductions.count('Id'))
img = tf.shade(agg, cmap=['lightblue', 'darkblue'], how='log')
img
