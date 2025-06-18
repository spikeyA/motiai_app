class MoodScreen extends StatelessWidget {
  final moods = ['😊 Happy', '😔 Stressed', '💪 Motivated'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Mood')),
      body: GridView.count(
        crossAxisCount: 2,
        children: moods.map((mood) => InkWell(
          onTap: () async {
            final quote = await generateQuote(mood);
            Navigator.pop(context, quote);
          },
          child: Card(child: Center(child: Text(mood))),
        )).toList(),
      ),
    );
  }
}