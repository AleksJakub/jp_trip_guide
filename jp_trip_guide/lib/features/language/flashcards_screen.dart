import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:math';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  List<Map<String, dynamic>> allPhrases = [];
  List<Map<String, dynamic>> currentDeck = [];
  int currentIndex = 0;
  bool showAnswer = false;
  bool isFlipped = false;
  int correctAnswers = 0;
  int totalQuestions = 0;
  bool gameFinished = false;

  @override
  void initState() {
    super.initState();
    _loadPhrases();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ja-JP");
    await flutterTts.setSpeechRate(0.5);
  }

  Future<void> _loadPhrases() async {
    try {
      final String jsonString = await DefaultAssetBundle.of(context).loadString('assets/phrases/phrases_en_jp.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      allPhrases = jsonList.cast<Map<String, dynamic>>();
      _startNewGame();
    } catch (e) {
      // Handle error
    }
  }

  void _startNewGame() {
    setState(() {
      currentDeck = List.from(allPhrases);
      currentDeck.shuffle(Random());
      currentDeck = currentDeck.take(10).toList(); // Take 10 random phrases
      currentIndex = 0;
      showAnswer = false;
      isFlipped = false;
      correctAnswers = 0;
      totalQuestions = currentDeck.length;
      gameFinished = false;
    });
  }

  void _nextCard() {
    if (currentIndex < currentDeck.length - 1) {
      setState(() {
        currentIndex++;
        showAnswer = false;
        isFlipped = false;
      });
    } else {
      setState(() {
        gameFinished = true;
      });
    }
  }

  void _previousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        showAnswer = false;
        isFlipped = false;
      });
    }
  }

  void _toggleAnswer() {
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  void _flipCard() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  void _markCorrect() {
    setState(() {
      correctAnswers++;
    });
    _nextCard();
  }

  void _markIncorrect() {
    _nextCard();
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    if (allPhrases.isEmpty) {
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

    if (gameFinished) {
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 64,
                      color: Colors.yellow,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Game Complete!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Score: $correctAnswers / $totalQuestions',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _startNewGame,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Play Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Progress indicator
                  LinearProgressIndicator(
                    value: (currentIndex + 1) / totalQuestions,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${currentIndex + 1} / $totalQuestions',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Flashcard
                  Expanded(
                    child: GestureDetector(
                      onTap: _flipCard,
                      child: Card(
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue.withOpacity(0.8),
                                Colors.purple.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: AnimatedCrossFade(
                                duration: const Duration(milliseconds: 300),
                                crossFadeState: isFlipped
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                firstChild: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.translate,
                                      size: 48,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Tap to reveal',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                secondChild: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isFlipped ? currentPhrase['english'] ?? '' : currentPhrase['japanese'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    if (isFlipped) ...[
                                      Text(
                                        currentPhrase['romaji'] ?? '',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      IconButton(
                                        icon: const Icon(Icons.volume_up, size: 32),
                                        color: Colors.white,
                                        onPressed: () => _speak(currentPhrase['japanese'] ?? ''),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: currentIndex > 0 ? _previousCard : null,
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                        iconSize: 32,
                      ),
                      ElevatedButton.icon(
                        onPressed: _flipCard,
                        icon: Icon(isFlipped ? Icons.flip_to_back : Icons.flip_to_front),
                        label: Text(isFlipped ? 'Show Question' : 'Show Answer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                      IconButton(
                        onPressed: currentIndex < totalQuestions - 1 ? _nextCard : null,
                        icon: const Icon(Icons.arrow_forward),
                        color: Colors.white,
                        iconSize: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Answer buttons (only show when answer is visible)
                  if (isFlipped)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _markIncorrect,
                          icon: const Icon(Icons.close),
                          label: const Text('Incorrect'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _markCorrect,
                          icon: const Icon(Icons.check),
                          label: const Text('Correct'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
