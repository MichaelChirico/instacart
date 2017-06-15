from os import listdir
import pandas as pd
import re

#root directory
rt = 'instacart_2017_05_01/'
#get full path of all .csvs
fl = [rt + fn for fn in listdir(rt) if fn.endswith(r'.csv')]
#convert to dictionary for named extraction/clarity
fd = dict(zip([re.sub(r'.*/(.*)\.csv', r'\1', fn) for fn in fl], fl))

#read in files
aisles = pd.read_csv(fd['aisles'])
departments = pd.read_csv(fd['departments'])
#i tried (, index_col = 'product_id') and the column disappeared?
products = pd.read_csv(fd['products'])
orders = pd.read_csv(fd['orders'])
carts = pd.read_csv(fd['order_products__prior'])

#add aisle and department names to products 
# \/ products.join(aisles, on = 'aisle_id') returns strange error... \/
# \/  = makes a copy??? \/
products = pd.merge(products, aisles, on = 'aisle_id')
products = pd.merge(products, departments, on = 'department_id')

carts = pd.merge(carts, products, on = 'product_id')
carts = pd.merge(carts, orders, on = 'order_id')
# \/ memory error \/
carts.set_index(['order_id', 'add_to_cart_order'])

# \/ memory error \/
carts.groupby('order_id').last()
