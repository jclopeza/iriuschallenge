# word_counter.py
import re
from collections import Counter
from typing import List, Dict

def count_frequent_words(text: str, top_n: int = 10) -> List[Dict[str, int]]:
    """
        Function to count the most frequent words in a given text.
        
        :param text: The text to analyze.
        :param top_n: The number of most frequent words to return. Default is 10.
        :return: List of tuples (word, frequency).
    """
    # Convert the text to lowercase and extract only the words
    words = re.findall(r'\b\w+\b', text.lower())
    
    # Count the words and get the most common ones
    word_counts = Counter(words).most_common(top_n)
    
    # Return the result as a list of dictionaries
    return [{"word": word, "count": count} for word, count in word_counts]
