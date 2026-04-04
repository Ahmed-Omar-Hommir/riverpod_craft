import 'dart:math';

import '../models/quote.dart';

final _random = Random();

const allQuotes = [
  Quote(
    id: '1',
    text: 'The only way to do great work is to love what you do.',
    author: 'Steve Jobs',
  ),
  Quote(
    id: '2',
    text: 'Innovation distinguishes between a leader and a follower.',
    author: 'Steve Jobs',
  ),
  Quote(
    id: '3',
    text: 'Stay hungry, stay foolish.',
    author: 'Steve Jobs',
  ),
  Quote(
    id: '4',
    text: 'Life is what happens when you are busy making other plans.',
    author: 'John Lennon',
  ),
  Quote(
    id: '5',
    text: 'The future belongs to those who believe in the beauty of their dreams.',
    author: 'Eleanor Roosevelt',
  ),
  Quote(
    id: '6',
    text: 'It is during our darkest moments that we must focus to see the light.',
    author: 'Aristotle',
  ),
  Quote(
    id: '7',
    text: 'The best time to plant a tree was 20 years ago. The second best time is now.',
    author: 'Chinese Proverb',
  ),
  Quote(
    id: '8',
    text: 'An unexamined life is not worth living.',
    author: 'Socrates',
  ),
  Quote(
    id: '9',
    text: 'Simplicity is the ultimate sophistication.',
    author: 'Leonardo da Vinci',
  ),
  Quote(
    id: '10',
    text: 'In the middle of difficulty lies opportunity.',
    author: 'Albert Einstein',
  ),
];

Future<Quote> getRandomQuote() async {
  await Future.delayed(const Duration(milliseconds: 600));
  return allQuotes[_random.nextInt(allQuotes.length)];
}

Future<void> saveQuoteToStorage(String quoteId) async {
  await Future.delayed(const Duration(milliseconds: 400));
}
