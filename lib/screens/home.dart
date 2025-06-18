class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Quote')),
      body: FutureBuilder(
        future: Firestore.instance.collection('daily_quotes').doc('today').get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return QuoteCard(text: snapshot.data['text']);
          }
          return CircularProgressIndicator();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => MoodScreen(),
        )),
        child: Icon(Icons.mood),
      ),
    );
  }
}