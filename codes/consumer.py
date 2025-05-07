import pandas as pd
import re
from collections import Counter
import nltk
from wordcloud import WordCloud
import matplotlib.pyplot as plt

# Download NLTK data
nltk.download('punkt')
nltk.download('stopwords')

from nltk.corpus import stopwords
from nltk.tokenize import word_tokenize

# Load only the first 1000 rows of the dataset
df = pd.read_csv("6.csv", nrows=1000)
print("Initial Data Snapshot:")
print(df.head())

# Combine all review texts
all_text = ' '.join(df['Text'].dropna().astype(str))

# --- REGEX Pattern Extraction ---

# Email addresses (if any)
emails = re.findall(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', all_text)
print(f"\nFound {len(emails)} email addresses (if any):", emails[:5])

# Product codes (e.g., ABC123 or XYZ-456)
product_codes = re.findall(r'\b[A-Z]{2,5}[-]?\d{2,5}\b', all_text)
print(f"Found {len(product_codes)} product codes:", product_codes[:5])

# Timestamps (e.g., 2021-03-12 14:23)
timestamps = re.findall(r'\b\d{4}[-/]\d{2}[-/]\d{2} \d{2}:\d{2}|\d{2}[-/]\d{2}[-/]\d{4}\b', all_text)
print(f"Found {len(timestamps)} timestamps:", timestamps[:5])

# --- Sentiment Keyword Analysis ---

# Define keywords
keywords = ['excellent', 'great', 'awesome', 'good', 'bad', 'poor', 'terrible', 'refund', 'disappointed', 'love', 'hate']
keyword_counter = Counter()

# Tokenize and normalize
tokens = word_tokenize(all_text.lower())
filtered_tokens = [word for word in tokens if word.isalpha() and word not in stopwords.words('english')]

# Count sentiment keywords
for word in filtered_tokens:
    if word in keywords:
        keyword_counter[word] += 1

print("\nSentiment Keyword Frequencies:")
for word, count in keyword_counter.items():
    print(f"{word}: {count}")

# --- Word Cloud Visualization ---

# Generate word cloud
wordcloud = WordCloud(width=800, height=400, background_color='white').generate_from_frequencies(keyword_counter)

# Display word cloud
plt.figure(figsize=(10, 5))
plt.imshow(wordcloud, interpolation='bilinear')
plt.axis('off')
plt.title("Sentiment Keyword Frequency Word Cloud (First 1000 Reviews)")
plt.show()
