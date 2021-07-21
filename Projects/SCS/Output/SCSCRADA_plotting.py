# -*- coding: utf-8 -*-
"""
Created on Thu Jul 15 15:43:30 2021

@author: ereznic2
"""

import pandas
import matplotlib.pyplot as plt
import sqlite3

# Read in the summary data from the database
conn = sqlite3.connect('Default_summary.db')
SCS_data = pd.read_sql_query("SELECT * From Summary",conn)

conn.commit()
conn.close()

# Plot stuff
plt.figure(0)
SCS_data.plot(x='Year',y='Product NPV cost (US$/kg)')

plt.figure(0)
plt.plot(files2load_summary_data_all['Year'], files2load_summary_data_all['Product NPV cost (US$/kg)'])
plt.xlabel('Year',fontsize = 16)
plt.ylabel('LCOH ($/kg)',fontname = 'Arial', fontsize = 16)
plt.xticks(fontname = 'Arial',fontsize = 16,rotation = 45)
plt.yticks(fontname = 'Arial',fontsize = 16)
#plt.axis([2020,8760,0,0.6])
plt.tick_params(direction = 'in',width = 1)
plt.tight_layout()
#plt.savefig('Projects\SCS\Plots\\annual_storagelevel.png',pad_inches = 0.1,dpi = 150)