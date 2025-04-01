import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

# -----------------------------
# 1. Product Data (IDs and Prices)
# -----------------------------
product_ids = list(range(101, 292))
prices = [
    69, 79, 79, 79, 89, 99, 99, 109, 109, 119, 129, 139, 139, 149, 159, 169, 119, 129, 139, 139,
    159, 159, 169, 179, 189, 109, 119, 119, 119, 129, 129, 129, 149, 159, 159, 169, 179, 189, 199,
    219, 229, 189, 199, 209, 209, 249, 249, 259, 269, 279, 179, 189, 189, 189, 199, 199, 199, 219,
    229, 229, 239, 249, 259, 269, 289, 299, 249, 259, 269, 269, 299, 299, 329, 339, 349, 49, 49,
    49, 59, 59, 59, 79, 89, 89, 89, 49, 59, 69, 69, 79, 89, 99, 109, 49, 59, 59, 59, 49, 59, 59,
    69, 69, 89, 99, 49, 79, 89, 69, 89, 119, 129, 129, 79, 99, 79, 99, 99, 119, 119, 139, 119, 139,
    119, 139, 139, 149, 139, 139, 149, 139, 69, 99, 79, 89, 99, 119, 39, 49, 49, 49, 49, 49, 59,
    69, 79, 99, 99, 99, 79, 59, 19, 25, 25, 29, 29, 49, 59, 69, 69, 59, 49, 49, 49, 49, 59, 59, 59,
    25, 25, 29, 49, 59, 59, 89, 49, 59, 59, 59, 59, 59, 59, 59, 59, 79, 59, 59, 79, 79, 79, 99, 99
]
product_df = pd.DataFrame({"Product_Id": product_ids, "Price": prices})

# Favoured products get extra weight.
favourites = {101, 260, 236, 207}
weights = [5 if pid in product_df["Product_Id"] else 1 for pid in product_df["Product_Id"]]
# Mapping from Product_Id to weight.
prod_weight = dict(zip(product_df["Product_Id"], weights))

# -----------------------------
# 2. Simulation Parameters
# -----------------------------
order_types = ["Delivery", "Takeaway", "Dine-in"]

# Date range: October 27, 2024 to December 25, 2024.
start_date = datetime(2024, 10, 27)
end_date = datetime(2024, 12, 25)
date_list = [start_date.date() + timedelta(days=i) for i in range((end_date - start_date).days + 1)]
# Define holiday period (café closed): October 29 to November 2.
holiday_dates = set(pd.date_range("2024-10-29", "2024-11-02").normalize().tolist())

# We'll adjust daily target ranges so that on working days the target is at least around 13k,
# and on Saturdays and Sundays it can be higher (up to 20k). You can modify these as needed.
def get_daily_target(current_day):
    weekday = current_day.weekday()  # Monday=0, Tuesday=1, etc.
    # For demonstration, let's set:
    # Monday - Friday: target between 13000 and 17000.
    # Saturday, Sunday: target between 17000 and 20000.
    if weekday < 5:
        return random.randint(13000, 17000)
    else:
        return random.randint(17000, 20000)

# Order subtotal constraints (excluding delivery charge)
ORDER_MIN = 49
ORDER_MAX = 349  # Each order's subtotal must be strictly below 349

# Sequential Order ID generator.
order_counter = 100  # Starting three-digit number
order_letter = "a"
def next_order_id():
    global order_counter
    order_id = f"{order_letter}{order_counter:03d}"
    order_counter += 1
    return order_id

# Minimum number of orders per day.
MIN_ORDERS_PER_DAY = 30

# -----------------------------
# 3. Generate Orders per Day until Daily Target is met
# -----------------------------
orders_summary = []   # Detailed order items (one row per order item)
delivery_summary = [] # Daily delivery summary
daily_totals = {}     # Daily total sale per day

for current_day in date_list:
    if current_day in holiday_dates:
        continue  # Skip days when the café is closed.
    
    daily_target = get_daily_target(current_day)
    day_total_sale = 0
    day_order_totals = []  # To track order total repetitions.
    daily_deliveries = 0
    daily_delivery_fees = 0
    
    # For ascending order times, start at 13:00.
    current_time = datetime.combine(current_day, datetime.min.time()) + timedelta(hours=13)
    orders_today = []  # To store orders for this day.
    
    # Generate orders until we have at least MIN_ORDERS_PER_DAY and total sale meets or exceeds the target.
    order_count = 0
    while order_count < MIN_ORDERS_PER_DAY or day_total_sale < daily_target:
        order_id = next_order_id()
        order_items = []
        order_subtotal = 0
        
        # Randomly choose between 1 and 4 distinct product IDs.
        num_items = random.randint(1, 4)
        chosen_products = set()
        for _ in range(num_items):
            available = product_df[~product_df["Product_Id"].isin(chosen_products)]
            if available.empty:
                break
            available_weights = [prod_weight[pid] for pid in available["Product_Id"]]
            prod = available.sample(weights=available_weights, random_state=random.randint(0, 1000)).iloc[0]
            chosen_products.add(prod["Product_Id"])
            quantity = random.randint(1, 4)
            potential_item_total = prod["Price"] * quantity
            if order_subtotal + potential_item_total > ORDER_MAX:
                continue
            order_items.append({
                "Product_Id": prod["Product_Id"],
                "Price": prod["Price"],
                "Quantity": quantity,
                "Subtotal": potential_item_total
            })
            order_subtotal += potential_item_total
        
        # If order subtotal is below ORDER_MIN, try adding one extra item.
        if order_subtotal < ORDER_MIN:
            available = product_df[~product_df["Product_Id"].isin(chosen_products)]
            if not available.empty:
                available_weights = [prod_weight[pid] for pid in available["Product_Id"]]
                prod = available.sample(weights=available_weights).iloc[0]
                chosen_products.add(prod["Product_Id"])
                quantity = random.randint(1, 2)
                potential_item_total = prod["Price"] * quantity
                if order_subtotal + potential_item_total <= ORDER_MAX:
                    order_items.append({
                        "Product_Id": prod["Product_Id"],
                        "Price": prod["Price"],
                        "Quantity": quantity,
                        "Subtotal": potential_item_total
                    })
                    order_subtotal += potential_item_total
        
        # Ensure order_subtotal does not exceed ORDER_MAX.
        order_subtotal = min(order_subtotal, ORDER_MAX)
        
        # Prevent the same order total from repeating more than 3 times in the day.
        if day_order_totals.count(order_subtotal) >= 3:
            if order_items:
                first_item = order_items[0]
                additional_cost = first_item["Price"]
                if order_subtotal + additional_cost <= ORDER_MAX:
                    first_item["Quantity"] += 1
                    first_item["Subtotal"] = first_item["Price"] * first_item["Quantity"]
                    order_subtotal += additional_cost
        day_order_totals.append(order_subtotal)
        
        # Choose order type and calculate delivery charge if applicable.
        order_type = random.choice(order_types)
        delivery_charge = 0
        if order_type == "Delivery":
            daily_deliveries += 1
            if order_subtotal <= 100:
                delivery_charge = 20
            elif order_subtotal <= 200:
                delivery_charge = 10
            daily_delivery_fees += delivery_charge
        
        order_total = order_subtotal + delivery_charge
        
        order_time = current_time.strftime('%H:%M')
        # Increment current time by a random amount between 5 and 15 minutes.
        current_time += timedelta(minutes=random.randint(5, 15))
        
        # For each order item, record a row.
        for item in order_items:
            orders_summary.append({
                "Order_ID": order_id,
                "Date": current_day.strftime('%Y-%m-%d'),
                "Time": order_time,
                "Order_Type": order_type,
                "Product_Id": item["Product_Id"],
                "Price": item["Price"],
                "Quantity": item["Quantity"],
                "Item_Subtotal": item["Subtotal"],
                "Order_Subtotal": order_subtotal,
                "Delivery_Charge": delivery_charge,
                "Order_Total": order_total
            })
        day_total_sale += order_total
        order_count += 1
    
    # If after minimum orders the day_total_sale is still less than target, 
    # add an extra order (with minimal cost item) until target is met.
    while day_total_sale < daily_target:
        order_id = next_order_id()
        # Use a minimal cost product (lowest price from product_df)
        prod = product_df.loc[product_df["Price"].idxmin()]
        quantity = 1
        order_subtotal = prod["Price"] * quantity
        order_type = random.choice(order_types)
        delivery_charge = 0
        if order_type == "Delivery":
            daily_deliveries += 1
            if order_subtotal <= 100:
                delivery_charge = 20
            elif order_subtotal <= 200:
                delivery_charge = 10
            daily_delivery_fees += delivery_charge
        order_total = order_subtotal + delivery_charge
        order_time = current_time.strftime('%H:%M')
        current_time += timedelta(minutes=random.randint(5, 15))
        orders_summary.append({
            "Order_ID": order_id,
            "Date": current_day.strftime('%Y-%m-%d'),
            "Time": order_time,
            "Order_Type": order_type,
            "Product_Id": prod["Product_Id"],
            "Price": prod["Price"],
            "Quantity": quantity,
            "Item_Subtotal": order_subtotal,
            "Order_Subtotal": order_subtotal,
            "Delivery_Charge": delivery_charge,
            "Order_Total": order_total
        })
        day_total_sale += order_total
        order_count += 1

    delivery_summary.append({
        "Date": current_day.strftime('%Y-%m-%d'),
        "Total_Deliveries": daily_deliveries,
        "Total_Delivery_Fees": daily_delivery_fees
    })
    daily_totals[current_day.strftime('%Y-%m-%d')] = day_total_sale

# -----------------------------
# 4. Create DataFrames and Pivot Table
# -----------------------------
orders_df = pd.DataFrame(orders_summary)

# Create a pivot table: each Product_Id becomes a column with total quantity sold per day.
pivot_df = orders_df.pivot_table(index="Date", columns="Product_Id", values="Quantity", aggfunc="sum", fill_value=0)
daily_totals_df = pd.DataFrame(list(daily_totals.items()), columns=["Date", "Daily_Total_Sale"])
pivot_df = pivot_df.merge(daily_totals_df, left_index=True, right_on="Date")

delivery_df = pd.DataFrame(delivery_summary)

# -----------------------------
# 5. Save Outputs to CSV Files
# -----------------------------
orders_df.to_csv("cafe_sales_orders.csv", index=False)
pivot_df.to_csv("cafe_sales_pivot.csv", index=False)
delivery_df.to_csv("cafe_delivery_summary.csv", index=False)

print("CSV files generated:")
print(" - Detailed orders: cafe_sales_orders.csv")
print(" - Pivoted daily sales: cafe_sales_pivot.csv")
print(" - Delivery summary: cafe_delivery_summary.csv")
