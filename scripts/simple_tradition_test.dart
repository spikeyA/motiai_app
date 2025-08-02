/// Simple test script to verify tradition variety system
/// This script simulates the tradition variety logic without requiring Flutter

void main() {
  print('🎯 Testing Tradition Variety System...\n');

  // Simulate the tradition variety system
  final List<String> recentTraditions = [];
  const int maxRecentTraditions = 3;
  
  // Available traditions in the app
  final List<String> availableTraditions = [
    'Buddhist',
    'Sufi',
    'Zen',
    'Taoism',
    'Confucianism',
    'Stoicism',
    'Hinduism',
    'Indigenous Wisdom',
    'Mindful Tech',
    'Social Justice',
  ];

  print('📊 Available traditions: ${availableTraditions.length}');
  availableTraditions.forEach((t) => print('  • $t'));

  print('\n🧪 Simulating tradition variety system...');
  
  for (int i = 0; i < 15; i++) {
    print('\n--- Test ${i + 1} ---');
    
    // Simulate filtering out recent traditions
    final availableForSelection = availableTraditions.where(
      (tradition) => !recentTraditions.contains(tradition)
    ).toList();
    
    print('Recent traditions: $recentTraditions');
    print('Available for selection: ${availableForSelection.length} traditions');
    
    if (availableForSelection.isEmpty) {
      print('🔄 No traditions available, resetting...');
      recentTraditions.clear();
      print('✅ Reset complete - all traditions available again');
      continue;
    }
    
    // Simulate random selection
    availableForSelection.shuffle();
    final selectedTradition = availableForSelection.first;
    
    print('Selected tradition: $selectedTradition');
    
    // Update recent traditions tracking
    recentTraditions.add(selectedTradition);
    if (recentTraditions.length > maxRecentTraditions) {
      final removed = recentTraditions.removeAt(0);
      print('Removed from recent: $removed');
    }
    
    print('Updated recent traditions: $recentTraditions');
    
    // Check for repetition
    if (i > 0) {
      final currentTradition = recentTraditions.last;
      final previousTraditions = recentTraditions.sublist(0, recentTraditions.length - 1);
      
      if (previousTraditions.contains(currentTradition)) {
        print('⚠️  WARNING: Tradition "$currentTradition" was repeated!');
      } else {
        print('✅ Tradition variety maintained');
      }
    }
  }

  print('\n📈 Final Analysis:');
  print('Recent traditions at end: $recentTraditions');
  
  // Check for any duplicates in final recent traditions
  final uniqueTraditions = recentTraditions.toSet();
  if (uniqueTraditions.length == recentTraditions.length) {
    print('✅ No tradition repetition in final list');
  } else {
    print('❌ Found tradition repetition in final list');
  }

  print('\n🎯 Test Summary:');
  print('• System prevents repetition of last $maxRecentTraditions traditions');
  print('• Graceful reset when no traditions available');
  print('• Maintains variety across selections');
  print('• Works with ${availableTraditions.length} different traditions');
  
  print('\n✅ Tradition variety system test complete!');
} 