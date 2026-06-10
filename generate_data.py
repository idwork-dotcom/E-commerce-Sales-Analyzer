import os
import random
import datetime
import numpy as np
import pandas as pd
from faker import Faker

# Set random seeds for reproducibility
random.seed(42)
np.random.seed(42)

# Initialize Faker
fake = Faker()

print("Starting e-commerce synthetic dataset generation...")

# Output directory
output_dir = "data"
os.makedirs(output_dir, exist_ok=True)

# ---------------------------------------------------------
# 1. CHANNELS
# ---------------------------------------------------------
channels_data = [
    {"channel_id": "CHAN-1", "channel_name": "Shopify", "platform_fee_pct": 0.029},
    {"channel_id": "CHAN-2", "channel_name": "Amazon", "platform_fee_pct": 0.150},
    {"channel_id": "CHAN-3", "channel_name": "Etsy", "platform_fee_pct": 0.065},
    {"channel_id": "CHAN-4", "channel_name": "WooCommerce", "platform_fee_pct": 0.000},
    {"channel_id": "CHAN-5", "channel_name": "Manual Order", "platform_fee_pct": 0.000}
]
df_channels = pd.DataFrame(channels_data)
df_channels.to_csv(os.path.join(output_dir, "channels.csv"), index=False)
print("Saved channels.csv")

# ---------------------------------------------------------
# 2. PRODUCTS
# ---------------------------------------------------------
categories = {
    "Apparel": {
        "prefix": "APP",
        "cost_min": 8.0, "cost_max": 45.0,
        "markup_min": 0.6, "markup_max": 1.2,
        "items": [
            'Eco-Cotton Unisex Hoodie', 'Casual Linen Button-Down', 'Tailored Chino Pants', 'Merino Wool Crewneck', 
            'High-Waist Denim Jeans', 'Waterproof Trail Jacket', 'Seamless Athletic Leggings', 'Classic Leather Belt', 
            'Bamboo Pajama Set', 'Activewear Running Shorts', 'Ribbed Knit Beanie', 'Canvas Everyday Tote Bag', 
            'Suede Chelsea Boots', 'Packable Puffer Vest', 'Organic Cotton Crew Socks (3-pack)', 'Breathable Mesh Sneakers', 
            'Vintage Graphic Tee', 'Flowy Summer Sundress', 'Structured Office Blazer', 'Cozy Flannel Shirt', 
            'Premium Silk Scarf', 'Lightweight Windbreaker', 'Thermal Base Layer Set', 'Casual Slip-On Loafers', 
            'Fleece Quarter-Zip Pull'
        ]
    },
    "Electronics Accessories": {
        "prefix": "ELC",
        "cost_min": 10.0, "cost_max": 80.0,
        "markup_min": 0.4, "markup_max": 0.8,
        "items": [
            'Wireless ANC Earbuds', 'MagSafe Compatible Power Bank', 'USB-C Multi-Port Hub', 'Ergonomic Wireless Mouse', 
            'Mechanical Gaming Keyboard', 'Dual-Device Wireless Charger', 'Premium Laptop Sleeve (14-inch)', 
            'Flexible Desk Tripod with Ring Light', 'HD Webcam with Privacy Cover', 'Noise-Isolating In-Ear Headphones', 
            'Adjustable Tablet Stand', 'Waterproof Portable Bluetooth Speaker', 'Smart Fitness Tracker Band', 
            'Anti-Blue Light Screen Protector', 'Braided Nylon USB-C Cable (6ft)', 'Leather AirTag Keychain Case', 
            'Hard Shell Travel Tech Organizer', 'Universal Travel Plug Adapter', 'RGB Desk Mouse Pad (Extra Large)', 
            'Wireless Presentation Clicker', 'Car Vent Magnetic Phone Mount', 'Clip-On Lapel Microphone', 
            'Silicone Cable Organizer Straps', 'Bluetooth Keyboard for Tablets', 'Mini USB Desk Fan'
        ]
    },
    "Home Decor": {
        "prefix": "DEC",
        "cost_min": 5.0, "cost_max": 60.0,
        "markup_min": 0.8, "markup_max": 1.5,
        "items": [
            'Ceramic Soy Scented Candle', 'Minimalist Floating Wall Shelves', 'Woven Macrame Plant Hanger', 
            'Textured Boho Throw Pillow Cover', 'Abstract Canvas Wall Art', 'Modern Amber Glass Vase', 
            'Handwoven Seagrass Basket Set', 'Geometric Ceramic Table Lamp', 'Faux Eucalyptus Potted Plant', 
            'Soft Cotton Waffle Throw Blanket', 'Minimalist Metal Desk Organizer', 'Stained Glass Sun Catcher', 
            'Velvet Accent Cushion', 'Brass Hanging Photo Frame', 'Rustic Wooden Serving Tray', 'Abstract Pattern Area Rug', 
            'Dried Pampas Grass Bundle', 'Modern Wall Clock (12-inch)', 'Marble Coaster Set of 4', 'Aromatic Essential Oil Diffuser', 
            'Sleek Matte Black Candle Wick Trimmer', 'Chunky Knit Floor Pouf', 'Decorative Ceramic Incense Holder', 
            'Framed Botanical Art Prints', 'Metal Wire Magazine Rack'
        ]
    },
    "Beauty": {
        "prefix": "BEA",
        "cost_min": 2.0, "cost_max": 15.0,
        "markup_min": 1.0, "markup_max": 2.0,
        "items": [
            'Hydrating Hyaluronic Acid Serum', 'Vitamin C Brightening Facial Oil', 'Gentle Oat Cleansing Balm', 
            'Niacinamide Pore-Refining Toner', 'Mineral Broad Spectrum SPF 30', 'Ultra-Nourishing Shea Butter Lip Balm', 
            'Rosewater Soothing Face Mist', 'Exfoliating Bamboo Face Scrub', 'Clay Detoxifying Mask', 
            'Anti-Aging Retinol Night Cream', 'Organic Argan Hair Treatment Oil', 'Caffeine Under-Eye Cream', 
            'Hydrogel Collagen Eye Patches', 'Gentle Foaming Daily Cleanser', 'Calming Chamomile Body Wash', 
            'Vanilla Bean Hydrating Body Lotion', 'Tea Tree Spot Treatment Gel', 'Natural Deodorant Stick (Lavender)', 
            'Silicone Facial Cleansing Brush', 'Guasha Facial Massage Stone', 'Rose Quartz Roller', 
            'Biodegradable Cotton Swabs Pack', 'Moisturizing Hand Cream Set', 'Clarifying Charcoal Shampoo', 
            'Coconut Milk Hair Conditioner'
        ]
    },
    "Fitness": {
        "prefix": "FIT",
        "cost_min": 15.0, "cost_max": 120.0,
        "markup_min": 0.3, "markup_max": 0.7,
        "items": [
            'High-Density TPE Yoga Mat', 'Adjustable Dumbbell Set (10-25 lbs)', 'Fabric Resistance Bands (Set of 3)', 
            'Insulated Stainless Steel Water Bottle', 'High-Speed Jump Rope', 'Ab Roller Wheel with Knee Pad', 
            'Massage Lacrosse Ball for Myofascial', 'Deep Tissue Foam Roller', 'Pilates Exercise Ball', 
            'Weighted Wrist & Ankle Weights', 'Liquid Chalk for Grip', 'Gym Chalk Bag with Belt', 
            'Microfiber Quick-Dry Towel Pack', 'Under-Desk Walking Pad', 'Ergonomic Hand Gripper Strengthener', 
            'Push-Up Bars with Foam Grips', 'Yoga Block Duo with Strap', 'Reflective Running Vest', 
            'Breathable Workout Gym Gloves', 'Running Phone Armband Sleeve', 'Adjustable Kettlebell (5-15 lbs)', 
            'Portable Suspension Training Kit', 'Massage Gun with 4 Attachments', 'Exercise Balance Disc Cushion', 
            'Waterproof Swim Goggles'
        ]
    },
    "Stationery": {
        "prefix": "STA",
        "cost_min": 1.0, "cost_max": 10.0,
        "markup_min": 0.7, "markup_max": 1.2,
        "items": [
            'A5 Hardcover Dotted Journal', 'Dual Brush Pen Set (12-Pack)', 'Gel Ink Fineliner Pens (0.5mm)', 
            'Aesthetic Desk Pad Blotter', 'Gold Metal Paperclips (Set of 100)', 'Weekly Planner Pad (Undated)', 
            'Self-Adhesive Sticky Notes (Pastel)', 'Handcrafted Brass Bookmark', 'Washi Tape Set (10 Rolls)', 
            'Refillable Fountain Pen', 'Premium Writing Ink (30ml)', 'Grid Index Cards Pack', 
            'Minimalist Scissors & Stapler Set', 'Desktop Document Tray (Wood)', 'Leather Pencil Pouch', 
            'Calligraphy Starter Kit', 'Erasable Highlighters (6-Pack)', 'Customizable Wax Seal Stamp Kit', 
            'Perforated Notepad (Letter Size)', 'Expanding Accordion File Folder', 'Cork Bulletin Board (12x12)', 
            'Sketchbook for Drawing (9x12)', 'Dual-Tip Acrylic Paint Markers', 'Decorative Gift Wrapping Paper', 
            'Magnetic Whiteboard Eraser'
        ]
    }
}

products_data = []
prod_idx = 1

for cat_name, cat_info in categories.items():
    prefix = cat_info["prefix"]
    items = cat_info["items"]
    for i, item in enumerate(items):
        product_id = f"PROD-{prod_idx:03d}"
        cost = round(random.uniform(cat_info["cost_min"], cat_info["cost_max"]), 2)
        markup = random.uniform(cat_info["markup_min"], cat_info["markup_max"])
        raw_price = cost * (1 + markup)
        
        # Round prices to realistic values e.g. X.99, X.95, or X.00
        cents_option = random.choice([0.99, 0.95, 0.00])
        price = round(raw_price)
        if cents_option != 0.00:
            price = float(int(price) - 1) + cents_option
        else:
            price = float(round(price))
            
        # Guarantee margin safety
        if price <= cost:
            price = round(cost * 1.5, 2)
            
        sku = f"{prefix}-{i+1:02d}-{int(price)}"
        
        products_data.append({
            "product_id": product_id,
            "product_name": item,
            "category": cat_name,
            "cost": cost,
            "price": price,
            "sku": sku
        })
        prod_idx += 1

df_products = pd.DataFrame(products_data)
df_products.to_csv(os.path.join(output_dir, "products.csv"), index=False)
print(f"Saved products.csv with {len(df_products)} rows")

# ---------------------------------------------------------
# 3. CUSTOMERS
# ---------------------------------------------------------
# Mapping states to US Census regions
STATE_TO_REGION = {
    'AL': 'South', 'AK': 'West', 'AZ': 'West', 'AR': 'South', 'CA': 'West', 'CO': 'West',
    'CT': 'Northeast', 'DE': 'South', 'FL': 'South', 'GA': 'South', 'HI': 'West', 'ID': 'West',
    'IL': 'Midwest', 'IN': 'Midwest', 'IA': 'Midwest', 'KS': 'Midwest', 'KY': 'South', 'LA': 'South',
    'ME': 'Northeast', 'MD': 'South', 'MA': 'Northeast', 'MI': 'Midwest', 'MN': 'Midwest', 'MS': 'South',
    'MO': 'Midwest', 'MT': 'West', 'NE': 'Midwest', 'NV': 'West', 'NH': 'Northeast', 'NJ': 'Northeast',
    'NM': 'West', 'NY': 'Northeast', 'NC': 'South', 'ND': 'Midwest', 'OH': 'Midwest', 'OK': 'South',
    'OR': 'West', 'PA': 'Northeast', 'RI': 'Northeast', 'SC': 'South', 'SD': 'Midwest', 'TN': 'South',
    'TX': 'South', 'UT': 'West', 'VT': 'Northeast', 'VA': 'South', 'WA': 'West', 'WV': 'South',
    'WI': 'Midwest', 'WY': 'West', 'DC': 'South'
}

customers_data = []
customer_ids = [f"CUST-{i:04d}" for i in range(1, 2001)]

for cid in customer_ids:
    first_name = fake.first_name()
    last_name = fake.last_name()
    email = f"{first_name.lower()}.{last_name.lower()}@{fake.free_email_domain()}"
    phone = fake.phone_number()
    
    # State & City
    state_abbr = random.choice(list(STATE_TO_REGION.keys()))
    region = STATE_TO_REGION[state_abbr]
    city = fake.city()
    zip_code = fake.zipcode_in_state(state_abbr)
    
    # Customer signup date: 2023-01-01 to 2025-12-31
    # We allow signup dates inside 24-month order window too, to simulate new customers joining
    signup_date = fake.date_between(
        start_date=datetime.date(2023, 1, 1),
        end_date=datetime.date(2025, 12, 31)
    )
    
    customers_data.append({
        "customer_id": cid,
        "first_name": first_name,
        "last_name": last_name,
        "email": email,
        "phone": phone,
        "city": city,
        "state": state_abbr,
        "zip_code": zip_code,
        "country": "United States",
        "region": region,
        "signup_date": signup_date
    })

df_customers = pd.DataFrame(customers_data)
# We will save this at the end to allow dynamic adjustment of signup dates if an order happens before signup!

# ---------------------------------------------------------
# 4. ORDERS
# ---------------------------------------------------------
num_orders = 10000

# Pareto/Zipf-like customer purchase probability
cust_weights = 1.0 / (np.arange(1, 2001) ** 0.65)
cust_weights /= cust_weights.sum()

# Skewed product selection weights
prod_weights = 1.0 / (np.arange(1, 151) ** 0.55)
prod_weights /= prod_weights.sum()

# Channel selection probability
channel_choices = df_channels["channel_id"].tolist()
channel_weights = [0.45, 0.35, 0.10, 0.07, 0.03]  # Shopify, Amazon, Etsy, WooCommerce, Manual

# Order quantity weights (skewed towards 1 and 2 units)
qty_options = [1, 2, 3, 4, 5]
qty_weights = [0.70, 0.20, 0.06, 0.03, 0.01]

# Month-of-year sales volume weights (for seasonality)
# Q4 high spikes (Nov/Dec), Q1 lower, Q3 summer uptick (July)
monthly_weights = {
    1: 0.05, 2: 0.05, 3: 0.06,
    4: 0.07, 5: 0.08, 6: 0.08,
    7: 0.09, 8: 0.07, 9: 0.08,
    10: 0.09, 11: 0.14, 12: 0.14
}

# Generate dates for 10,000 orders covering exactly 2024-01-01 to 2025-12-31
orders_list = []

# To ensure the orders cover EXACTLY 24 months, we explicitly assign at least a few orders to
# the very start (Jan 2024) and very end (Dec 2025)
order_dates = []

# Build probability distribution over all days in the 24 month period
start_date = datetime.date(2024, 1, 1)
end_date = datetime.date(2025, 12, 31)
date_range = pd.date_range(start=start_date, end=end_date)
date_list = date_range.date.tolist()  # Convert to standard Python datetime.date objects

day_weights = []
for d in date_range:
    m_weight = monthly_weights[d.month]
    # Add day-of-week seasonality (higher orders on Sunday/Monday, lower on Friday/Saturday)
    dow = d.dayofweek
    dow_multiplier = 1.2 if dow in [0, 6] else (0.8 if dow in [4, 5] else 1.0)
    
    # Add Black Friday & Christmas week spikes in Nov/Dec
    spike_multiplier = 1.0
    if d.month == 11 and 20 <= d.day <= 30: # Black Friday / Cyber Monday window
        spike_multiplier = 2.5
    elif d.month == 12 and 10 <= d.day <= 23: # Pre-Christmas rush
        spike_multiplier = 2.0
        
    day_weights.append(m_weight * dow_multiplier * spike_multiplier)

day_weights = np.array(day_weights)
day_weights /= day_weights.sum()

# Sample 10,000 dates from the date list using day weights
sampled_dates = np.random.choice(date_list, size=num_orders, replace=True, p=day_weights)
# Sort dates to keep orders chronological
sampled_dates = sorted(sampled_dates)

# Map product properties for quick lookup
prod_dict = df_products.set_index("product_id").to_dict(orient="index")

print("Generating 10,000 orders...")
for i in range(num_orders):
    order_id = f"ORD-{i+1:05d}"
    
    # Pick customer using Pareto probability
    customer_id = np.random.choice(df_customers["customer_id"].tolist(), p=cust_weights)
    
    # Pick product using power-law weights
    product_id = np.random.choice(df_products["product_id"].tolist(), p=prod_weights)
    
    # Pick channel using weights
    channel_id = np.random.choice(channel_choices, p=channel_weights)
    
    # Order date
    order_timestamp = sampled_dates[i]
    order_date = order_timestamp
    
    # Quantity
    quantity = int(np.random.choice(qty_options, p=qty_weights))
    
    # Price
    unit_price = prod_dict[product_id]["price"]
    
    # Discount
    # 65% of orders get 0% discount, 35% get some promotional discount (up to 40% in 5% steps)
    has_discount = random.random() < 0.35
    discount_pct = round(random.choice([0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40]), 2) if has_discount else 0.00
    
    # Subtotal
    subtotal = unit_price * quantity * (1 - discount_pct)
    
    # Shipping Cost
    # Free shipping on orders >= $75, otherwise shipping is $4.99, $5.99, $8.99, $11.99
    if subtotal >= 75.0:
        shipping_cost = 0.00
    else:
        shipping_cost = random.choice([4.99, 5.99, 8.99, 11.99])
        
    # Initially assign order status
    # 96.5% Completed, 3.5% Cancelled
    is_cancelled = random.random() < 0.035
    
    if is_cancelled:
        order_status = "Cancelled"
        total_amount = 0.00
        shipping_cost = 0.00
        discount_pct = 0.00
    else:
        order_status = "Completed"
        total_amount = round(subtotal + shipping_cost, 2)
        
    # Check customer signup alignment:
    # Customer MUST have signed up ON OR BEFORE order_date.
    cust_idx = df_customers[df_customers["customer_id"] == customer_id].index[0]
    cust_signup = df_customers.at[cust_idx, "signup_date"]
    
    if cust_signup > order_date:
        # Move signup date to a random period of 0-30 days before order_date
        new_signup = order_date - datetime.timedelta(days=random.randint(0, 30))
        # Ensure it doesn't go before 2023-01-01
        if new_signup < datetime.date(2023, 1, 1):
            new_signup = datetime.date(2023, 1, 1)
        df_customers.at[cust_idx, "signup_date"] = new_signup
        
    orders_list.append({
        "order_id": order_id,
        "customer_id": customer_id,
        "product_id": product_id,
        "channel_id": channel_id,
        "order_date": order_date,
        "quantity": quantity,
        "unit_price": unit_price,
        "discount_pct": discount_pct,
        "shipping_cost": shipping_cost,
        "order_status": order_status,
        "total_amount": total_amount
    })

# Convert to DataFrame
df_orders = pd.DataFrame(orders_list)

# ---------------------------------------------------------
# 5. RETURNS & REFUNDS (6% to 12% of Completed Orders)
# ---------------------------------------------------------
print("Generating returns...")

# Get order IDs that were completed
completed_mask = df_orders["order_status"] == "Completed"
df_completed = df_orders[completed_mask]

# Target ~8.5% return rate
return_rate = 0.085
num_returns = int(len(df_completed) * return_rate)

# Sample order indices to return
return_indices = np.random.choice(df_completed.index, size=num_returns, replace=False)

returns_list = []
return_reasons = ["Damaged Item", "Wrong Size", "Late Delivery", "Changed Mind", "Product Not as Described", "Defective Item"]

ret_idx = 1
for idx in return_indices:
    order_row = df_orders.loc[idx]
    order_id = order_row["order_id"]
    order_date = order_row["order_date"]
    product_id = order_row["product_id"]
    
    # Return date is between 2 to 14 days after order_date
    return_date = order_date + datetime.timedelta(days=random.randint(2, 14))
    
    # Category-specific returns logic for extreme realism:
    prod_cat = prod_dict[product_id]["category"]
    
    if prod_cat == "Apparel":
        # Apparel returns are heavily weighted towards Wrong Size
        reason = np.random.choice(return_reasons, p=[0.10, 0.60, 0.05, 0.10, 0.10, 0.05])
    elif prod_cat == "Electronics Accessories":
        # Electronics are weighted towards Defective Item and Product Not as Described
        reason = np.random.choice(return_reasons, p=[0.15, 0.02, 0.08, 0.10, 0.25, 0.40])
    else:
        # Standard distribution
        reason = np.random.choice(return_reasons)
        
    # Refund amount: Item Subtotal (shipping is non-refundable)
    subtotal = order_row["unit_price"] * order_row["quantity"] * (1 - order_row["discount_pct"])
    refund_amount = round(subtotal, 2)
    
    # 75% marked as Returned, 25% marked as Refunded in orders.csv
    status_choice = "Returned" if random.random() < 0.75 else "Refunded"
    df_orders.at[idx, "order_status"] = status_choice
    
    returns_list.append({
        "return_id": f"RET-{ret_idx:05d}",
        "order_id": order_id,
        "return_date": return_date,
        "return_reason": reason,
        "refund_amount": refund_amount
    })
    ret_idx += 1

df_returns = pd.DataFrame(returns_list)
df_returns.to_csv(os.path.join(output_dir, "returns.csv"), index=False)
print(f"Saved returns.csv with {len(df_returns)} rows")

# Now save the updated orders.csv and customers.csv (which has adjusted signup dates)
df_orders.to_csv(os.path.join(output_dir, "orders.csv"), index=False)
print("Saved orders.csv")

df_customers.to_csv(os.path.join(output_dir, "customers.csv"), index=False)
print("Saved customers.csv")

# ---------------------------------------------------------
# 6. CALENDAR
# ---------------------------------------------------------
calendar_list = []
for d in date_range:
    calendar_list.append({
        "date": d.strftime("%Y-%m-%d"),
        "year": d.year,
        "quarter": (d.month - 1) // 3 + 1,
        "month": d.month,
        "month_name": d.strftime("%B"),
        "day": d.day,
        "day_of_week": d.dayofweek + 1, # 1: Monday, ..., 7: Sunday
        "day_name": d.strftime("%A"),
        "is_weekend": int(d.dayofweek >= 5) # 1 for weekend, 0 for weekday
    })
df_calendar = pd.DataFrame(calendar_list)
df_calendar.to_csv(os.path.join(output_dir, "calendar.csv"), index=False)
print("Saved calendar.csv")

# ---------------------------------------------------------
# DATA INTEGRITY VALIDATION CHECKS
# ---------------------------------------------------------
print("\n" + "="*50)
print("RUNNING DATA VALIDATION CHECKS")
print("="*50)

# Check 1: Record counts
print(f"1. Customers Count: {len(df_customers)} (Expected: 2000)")
print(f"2. Products Count:  {len(df_products)} (Expected: 150)")
print(f"3. Channels Count:  {len(df_channels)} (Expected: 5)")
print(f"4. Orders Count:    {len(df_orders)} (Expected: 10000)")
print(f"5. Returns Count:   {len(df_returns)} (Expected: ~800-900)")
print(f"6. Calendar Count:  {len(df_calendar)} (Expected: 731 days)")

# Check 2: Dates cover exactly 24 months (2024-01-01 to 2025-12-31)
min_order_date = df_orders["order_date"].min()
max_order_date = df_orders["order_date"].max()
print(f"7. Order Dates Range: {min_order_date} to {max_order_date} (Expected: 2024-01-01 to 2025-12-31)")

# Check 3: Return rate validation
completed_and_returned = df_orders[df_orders["order_status"].isin(["Completed", "Returned", "Refunded"])]
actual_return_pct = len(df_returns) / len(completed_and_returned) * 100
print(f"8. Actual Return Rate: {actual_return_pct:.2f}% (Expected: 6% to 12%)")

# Check 4: Cancelled orders revenue validation
cancelled_orders = df_orders[df_orders["order_status"] == "Cancelled"]
cancelled_revenue = cancelled_orders["total_amount"].sum()
print(f"9. Cancelled Orders Total revenue: ${cancelled_revenue:.2f} (Expected: $0.00)")

# Check 5: Margin logic validation (price > cost)
negative_margin_products = df_products[df_products["price"] <= df_products["cost"]]
print(f"10. Products with negative/zero margin: {len(negative_margin_products)} (Expected: 0)")

# Check 6: Integrity check (referential integrity)
invalid_customer_orders = df_orders[~df_orders["customer_id"].isin(df_customers["customer_id"])]
invalid_product_orders = df_orders[~df_orders["product_id"].isin(df_products["product_id"])]
invalid_channel_orders = df_orders[~df_orders["channel_id"].isin(df_channels["channel_id"])]
invalid_returns = df_returns[~df_returns["order_id"].isin(df_orders["order_id"])]

print(f"11. Referencing Errors:")
print(f"    - Invalid Customers in Orders: {len(invalid_customer_orders)}")
print(f"    - Invalid Products in Orders:  {len(invalid_product_orders)}")
print(f"    - Invalid Channels in Orders:  {len(invalid_channel_orders)}")
print(f"    - Invalid Orders in Returns:   {len(invalid_returns)}")

# Check 7: Chronological integrity (Customer signup_date <= order_date)
# Merge orders with customers on customer_id
df_orders_merged = df_orders.merge(df_customers, on="customer_id")
invalid_signup_orders = df_orders_merged[df_orders_merged["signup_date"] > df_orders_merged["order_date"]]
print(f"12. Orders placed before Customer signup: {len(invalid_signup_orders)} (Expected: 0)")

# Check 8: Return date integrity (return_date >= order_date)
df_returns_merged = df_returns.merge(df_orders, on="order_id")
invalid_return_dates = df_returns_merged[df_returns_merged["return_date"] < df_returns_merged["order_date"]]
print(f"13. Returns logged before order date: {len(invalid_return_dates)} (Expected: 0)")

print("="*50)
print("DATASET GENERATION AND VALIDATION COMPLETE!")
print("="*50)
