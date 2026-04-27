Goal: The goal is to extract actionable insights from AirBnB’s datasets.
Dataset: [Download data from this link.](https://drive.google.com/drive/folders/15aLPuIqtYxKYP4N6t-pG5QR30SBRSIn4)

Listings Table
Tracks detailed information about properties listed on AirBnB:
id: Unique identifier for the listing.
name: Title of the listing.
description: Detailed property description.
host_id: Identifier for the host managing the property.
host_name: Name of the host.
property_type: Type of property (e.g., house, apartment).
room_type: Type of room (e.g., entire home, private room).
accommodates: Maximum number of guests.
price: Price per night.
review_scores_rating: Average guest rating.
number_of_reviews: Total number of reviews.

Calendar Table
Captures booking and availability data:
listing_id: Foreign key linking to the id column in the listings table.
date: Specific date for the entry.
available: Indicates if the listing is available (t for true, f for false).
price: Nightly price for the listing.

Reviews Table
Records guest feedback:
listing_id: Foreign key linking to the id column in the listings table.
id: Unique identifier for each review.
date: Date the review was posted.
reviewer_id: Identifier for the reviewer.
reviewer_name: Name of the reviewer.
comments: Text of the guest's feedback.


Questions
1. Analyze Customer Engagement Trends:
The team wants to analyze customer engagement across all listings within a specific time period. By identifying and ranking reviews submitted between two dates, the business can understand trends in customer interactions and review activity during that timeframe. 

Question: Rank all reviews submitted between '2015-01-01' and '2015-06-30' by their submission date. 
Display:
Listing ID
Review Date
Reviewer Name
Rank of the Review by Date

2. Identify Most Active Hosts
The management team wants to identify the most active hosts based on the total number of reviews their listings have received. This analysis will help the team recognize high-performing hosts who maintain popular and engaging properties. The total number of reviews for each host is calculated by summing up the reviews of all their listings.

Question: Calculate the total number of reviews received by each host across all their listings. Rank the hosts based on the total number of reviews. 
Display:
Host ID
Host Name
Total Number of Reviews (sum of reviews for all their listings)
Rank of the Host by Reviews

3. Analyze Revenue for Top Listings
The finance team wants to identify the top revenue-generating listings. By analyzing the total revenue earned by each listing, the team can prioritize these listings for promotional strategies or investment. The revenue is calculated by summing up the price for all available days in the calendars table.

Question: Calculate the total revenue for each listing by summing up the price for all available days. Use a window function to rank the listings based on their total revenue in descending order. 
Display:
Listing ID
Total Revenue
Rank of the Listing by Revenue

4. Compare Property Type Performance in Summer
The marketing team wants to identify how property types perform relative to each other during the summer months. By calculating percentile ranks for property types based on their total summer revenue, the team can classify property types into performance tiers, such as top-80 percentile performing property types.

Question: Calculate the total summer revenue (June, July, and August) for each property type. Determine its percentile rank among all property types based on their revenue. Display:
Property Type
Total Summer Revenue
Percentile Rank (based on summer revenue, between 0 and 1)

5. Analyze Year-over-Year (YoY) Growth in Listing RevenueThe finance team wants to analyze how listing revenue changes over time by comparing year-over-year (YoY) growth. This information can help identify trends in revenue generation and highlight listings that are growing or declining in performance.

Question: For each listing, calculate the total revenue per year and determine its YoY growth as a percentage. calculate the YoY growth. Finally, rank listings based on their YoY growth percentage to identify top-performing listings. 
Display:
Listing ID
Year
Total Revenue
Year-over-Year Growth (%)
Rank of Each Listing by YoY Growth
