import pandas as pd
import numpy as np

# --- Sample synthetic data for users and reviews ---
users_data = {
    'user_id':[1,2,3,4,5,6,7,8,9,10],
    'account_age_days':[5,8,12,20,15,400,620,900,1100,750],
    'total_reviews':[22,30,18,25,28,55,80,120,150,95],
    'verified_buyer':[False,False,False,False,False,True,True,True,True,True]
}

reviews_data = {
    'review_id':[1,2,3,4,5,6,7,8,9,10],
    'user_id':[1,2,3,4,5,6,7,8,9,10],
    'product_id':[101,101,101,101,101,101,102,103,104,105],
    'rating':[5,5,5,5,5,4,4,5,4,5],
    'verified_purchase':[False,False,False,False,False,True,True,True,True,True],
    'review_date':['2025-01-01','2025-01-01','2025-01-02','2025-01-02','2025-01-03',
                   '2025-01-05','2025-01-06','2025-01-07','2025-01-08','2025-01-09']
}

# Convert to DataFrames
users_df = pd.DataFrame(users_data)
reviews_df = pd.DataFrame(reviews_data)
reviews_df['review_date'] = pd.to_datetime(reviews_df['review_date'])

# --- Step 1: Compute signals ---

# 1️⃣ Unverified reviews count
unverified_reviews = reviews_df[reviews_df['verified_purchase']==False].groupby('user_id').size().reset_index(name='unverified_count')

# 2️⃣ Extreme ratings count 
extreme_ratings = reviews_df[reviews_df['rating'].isin([1,5])].groupby('user_id').size().reset_index(name='extreme_count')

# 3️⃣ Burst reviews (reviews within 2 days)
burst_counts = reviews_df.groupby('user_id').agg(
    first_review=('review_date','min'),
    last_review=('review_date','max'),
    review_count=('review_id','count')
).reset_index()
burst_counts['days_diff'] = (burst_counts['last_review'] - burst_counts['first_review']).dt.days + 1
burst_counts['burst_flag'] = np.where((burst_counts['review_count']>=3) & (burst_counts['days_diff']<=2),1,0)

# --- Step 2: Merge all signals ---
score_df = users_df.merge(unverified_reviews, on='user_id', how='left') \
                   .merge(extreme_ratings, on='user_id', how='left') \
                   .merge(burst_counts[['user_id','burst_flag']], on='user_id', how='left')

score_df.fillna(0, inplace=True)

# --- Step 3: Calculate Fake Review Score ---
def calc_fake_score(row):
    score = 0
    # account age
    if row['account_age_days'] < 30:
        score += 30
    # total reviews high for new user
    if row['total_reviews'] > 20 and row['account_age_days'] < 30:
        score += 20
    # unverified reviews
    score += min(row['unverified_count']*4,20)  # scale to 20 max
    # extreme ratings
    score += min(row['extreme_count']*4,20)     # scale to 20 max
    # burst
    score += row['burst_flag']*10
    return score

score_df['fake_review_score'] = score_df.apply(calc_fake_score, axis=1)

# --- Step 4: Flag risk ---
def risk_category(score):
    if score > 60:
        return 'High'
    elif score > 40:
        return 'Medium'
    else:
        return 'Low'


score_df['risk_level'] = score_df['fake_review_score'].apply(risk_category)

# Step 5: Display ---
print(score_df[['user_id','fake_review_score','risk_level']])

 # Merge reviews with Fake Review Score
reviews_with_score = reviews_df.merge(score_df[['user_id','fake_review_score']], on='user_id', how='left')

#Calculate adjusted rating 
reviews_with_score['adjusted_rating'] = reviews_with_score['rating'] * (1 - reviews_with_score['fake_review_score']/100)

# Compute Product Trust Score 
product_trust = reviews_with_score.groupby('product_id').agg(
    trust_score = ('adjusted_rating','mean'),
    total_reviews = ('review_id','count')
).reset_index()

# Optional: Round for readability 
product_trust['trust_score'] = product_trust['trust_score'].round(2)

# Display 
print(product_trust)

