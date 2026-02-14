class MotivationalQuotesService {
  static final List<Quote> _quotes = [
    // Focus & Productivity
    Quote(
      text: "The secret of getting ahead is getting started.",
      author: "Mark Twain",
      category: "productivity",
    ),
    Quote(
      text: "Focus on being productive instead of busy.",
      author: "Tim Ferriss",
      category: "productivity",
    ),
    Quote(
      text: "It's not that I'm so smart, it's just that I stay with problems longer.",
      author: "Albert Einstein",
      category: "focus",
    ),
    Quote(
      text: "The successful warrior is the average man, with laser-like focus.",
      author: "Bruce Lee",
      category: "focus",
    ),
    Quote(
      text: "Concentrate all your thoughts upon the work at hand.",
      author: "Alexander Graham Bell",
      category: "focus",
    ),
    Quote(
      text: "Where focus goes, energy flows.",
      author: "Tony Robbins",
      category: "focus",
    ),

    // Study & Learning
    Quote(
      text: "The more that you read, the more things you will know.",
      author: "Dr. Seuss",
      category: "study",
    ),
    Quote(
      text: "Education is the passport to the future.",
      author: "Malcolm X",
      category: "study",
    ),
    Quote(
      text: "Live as if you were to die tomorrow. Learn as if you were to live forever.",
      author: "Mahatma Gandhi",
      category: "study",
    ),
    Quote(
      text: "The beautiful thing about learning is that no one can take it away from you.",
      author: "B.B. King",
      category: "study",
    ),
    Quote(
      text: "An investment in knowledge pays the best interest.",
      author: "Benjamin Franklin",
      category: "study",
    ),

    // Persistence & Motivation
    Quote(
      text: "Success is not final, failure is not fatal: it is the courage to continue that counts.",
      author: "Winston Churchill",
      category: "motivation",
    ),
    Quote(
      text: "The only way to do great work is to love what you do.",
      author: "Steve Jobs",
      category: "motivation",
    ),
    Quote(
      text: "Don't watch the clock; do what it does. Keep going.",
      author: "Sam Levenson",
      category: "motivation",
    ),
    Quote(
      text: "Believe you can and you're halfway there.",
      author: "Theodore Roosevelt",
      category: "motivation",
    ),
    Quote(
      text: "The future belongs to those who believe in the beauty of their dreams.",
      author: "Eleanor Roosevelt",
      category: "motivation",
    ),
    Quote(
      text: "It does not matter how slowly you go as long as you do not stop.",
      author: "Confucius",
      category: "motivation",
    ),

    // Work & Excellence
    Quote(
      text: "Quality is not an act, it is a habit.",
      author: "Aristotle",
      category: "work",
    ),
    Quote(
      text: "The way to get started is to quit talking and begin doing.",
      author: "Walt Disney",
      category: "work",
    ),
    Quote(
      text: "Excellence is not a skill. It is an attitude.",
      author: "Ralph Marston",
      category: "work",
    ),
    Quote(
      text: "Hard work beats talent when talent doesn't work hard.",
      author: "Tim Notke",
      category: "work",
    ),

    // Time Management
    Quote(
      text: "Time is what we want most, but what we use worst.",
      author: "William Penn",
      category: "time",
    ),
    Quote(
      text: "The key is not to prioritize what's on your schedule, but to schedule your priorities.",
      author: "Stephen Covey",
      category: "time",
    ),
    Quote(
      text: "Lost time is never found again.",
      author: "Benjamin Franklin",
      category: "time",
    ),
    Quote(
      text: "Time is more valuable than money. You can get more money, but you cannot get more time.",
      author: "Jim Rohn",
      category: "time",
    ),

    // Breaks & Rest
    Quote(
      text: "Almost everything will work again if you unplug it for a few minutes, including you.",
      author: "Anne Lamott",
      category: "break",
    ),
    Quote(
      text: "Rest when you're weary. Refresh and renew yourself.",
      author: "Ralph Marston",
      category: "break",
    ),
    Quote(
      text: "Take rest; a field that has rested gives a bountiful crop.",
      author: "Ovid",
      category: "break",
    ),
  ];

  static Quote getRandomQuote() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return _quotes[random % _quotes.length];
  }

  static Quote getQuoteForCategory(String category) {
    final categoryQuotes = _quotes.where((q) => q.category == category).toList();
    if (categoryQuotes.isEmpty) return getRandomQuote();
    final random = DateTime.now().millisecondsSinceEpoch;
    return categoryQuotes[random % categoryQuotes.length];
  }

  static Quote getQuoteForBreak() {
    return getQuoteForCategory('break');
  }

  static Quote getQuoteForStudy() {
    return getQuoteForCategory('study');
  }

  static Quote getQuoteForWork() {
    return getQuoteForCategory('work');
  }

  static Quote getDailyQuote() {
    // Same quote for the entire day based on day of year
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }
}

class Quote {
  final String text;
  final String author;
  final String category;

  const Quote({
    required this.text,
    required this.author,
    required this.category,
  });
}
