library(data.table)
ff = list.files('/media/data_drive/instacart_2017_05_01',
                pattern = '\\.csv', full.names = TRUE)
names(ff) = gsub('.*/(.*)\\.csv', '\\1', ff)

aisles = fread(ff['aisles'])
departments = fread(ff['departments'])
products = fread(ff['products'], key = 'product_id')
orders = fread(ff['orders'])
carts = fread(ff['order_products__prior'])

products[aisles, aisle := i.aisle, on = 'aisle_id']
products[departments, department := i.department, on = 'department_id']

carts = merge(carts, products, by = 'product_id', all.x = TRUE)
carts = merge(carts, orders, by = 'order_id', all.x = TRUE)
setkey(carts, order_id, add_to_cart_order)

pdf('~/Desktop/yumm.pdf',
    height = 10, width = 10)
carts[ , add_to_cart_order[.N], by = order_id][ , plot(table(V1))]
dev.off()

carts[department == 'alcohol', .N, keyby = .(V = order_dow, aisle)
      ][ , dcast(.SD, V ~ aisle, value.var = 'N')
         ][ , {
           y = .SD[ , !"V"]
           matplot(V, y)
         }]
carts[ , .(c = sum(grepl('Condom', product_name, fixed = TRUE)), 
           l = sum(grepl('Personal Lubricant', product_name, fixed = TRUE))),
       keyby = order_hour_of_day
       ][ , matplot(order_hour_of_day, cbind(c, l))]

#user behavior doesn't change _much_ with longevity -- long-time
#  users buy same # of products as beginners (save for shortening tails)
carts[ , .(order_number[1L], .N), keyby = order_id][ , {boxplot(N ~ V1, log = 'y'); NULL}]
carts[ , plot(table(order_number, department))]
carts[!department_id %in% c(4L, 7L, 16L, 19L), plot(table(order_number, department))]

# veteran customers order more frequently
carts[order_number > 1L, .SD[1L], by = order_id, .SDcols = c('order_number', 'days_since_prior_order')
      ][ , {boxplot(days_since_prior_order ~ order_number); NULL}]


