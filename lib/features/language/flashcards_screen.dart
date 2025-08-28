import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'dart:convert'; // Added for json.decode

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> with TickerProviderStateMixin {
  late FlutterTts flutterTts;
  List<Map<String, String>> phrases = [];
  List<Map<String, String>> currentDeck = [];
  int currentIndex = 0;
  bool isFlipped = false;
  int score = 0;
  int totalCards = 0;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadPhrases();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_flipController);
  }

  void _initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ja-JP");
    flutterTts.setSpeechRate(0.5);
  }

  Future<void> _loadPhrases() async {
    // Load phrases from the JSON file
    try {
      final String response = await DefaultAssetBundle.of(context).loadString('assets/phrases/phrases_en_jp.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        phrases = data.map((e) => Map<String, String>.from(e)).toList();
        _shuffleDeck();
      });
    } catch (e) {
      // Fallback phrases if loading fails
      setState(() {
        phrases = [
          {"english": "Hello", "japanese": "こんにちは", "romaji": "Konnichiwa"},
          {"english": "Thank you", "japanese": "ありがとう", "romaji": "Arigatou"},
          {"english": "Goodbye", "japanese": "さようなら", "romaji": "Sayounara"},
        ];
        _shuffleDeck();
      });
    }
  }

  void _shuffleDeck() {
    final random = Random();
    currentDeck = List.from(phrases)..shuffle(random);
    currentDeck = currentDeck.take(10).toList(); // Take 10 random phrases
    currentIndex = 0;
    score = 0;
    totalCards = currentDeck.length;
    isFlipped = false;
    _flipController.reset();
  }

  void _nextCard() {
    if (currentIndex < currentDeck.length - 1) {
      setState(() {
        currentIndex++;
        isFlipped = false;
        _flipController.reset();
      });
    } else {
      _showGameOver();
    }
  }

  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped;
      if (isFlipped) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    });
  }

  void _markCorrect() {
    setState(() {
      score++;
    });
    _nextCard();
  }

  void _markIncorrect() {
    _nextCard();
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Text('Your score: $score/$totalCards'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _shuffleDeck();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () => context.go('/phrasebook'),
            child: const Text('Back to Phrasebook'),
          ),
        ],
      ),
    );
  }

  void _speakJapanese() {
    if (currentDeck.isNotEmpty) {
      flutterTts.speak(currentDeck[currentIndex]['japanese'] ?? '');
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentDeck.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flashcards'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/phrasebook'),
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/image1.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    final currentPhrase = currentDeck[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/phrasebook'),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/image1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Progress and Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Card ${currentIndex + 1}/$totalCards',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Score: $score',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Flashcard
                  Expanded(
                    child: GestureDetector(
                      onTap: _flipCard,
                      child: AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          final transform = Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(3.14159 * _flipAnimation.value);
                          
                          return Transform(
                            transform: transform,
                            alignment: Alignment.center,
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!isFlipped) ...[
                                      Text(
                                        currentPhrase['english'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Tap to reveal',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ] else ...[
                                      Text(
                                        currentPhrase['japanese'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        currentPhrase['romaji'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 20),
                                      IconButton(
                                        onPressed: _speakJapanese,
                                        icon: const Icon(Icons.volume_up, size: 32),
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  if (isFlipped) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _markIncorrect,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Incorrect'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _markCorrect,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Correct'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
