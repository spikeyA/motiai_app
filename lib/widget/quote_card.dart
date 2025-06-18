class QuoteCard extends StatelessWidget {
  final String text;

  const QuoteCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text(text, style: TextStyle(fontSize: 18)),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () => Share.share(text),
            ),
          ],
        ),
      ),
    );
  }
}