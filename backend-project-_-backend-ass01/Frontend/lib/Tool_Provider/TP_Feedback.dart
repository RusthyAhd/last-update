import 'package:flutter/material.dart';



class TP_Feedback extends StatelessWidget {
  const TP_Feedback({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  '4.0',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StarDisplay(value: 4), // Star rating display
                    Text('based on 23 reviews'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),

            _buildRatingDistribution(),

            SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  _buildReview(
                    'Joan Perkins',
                    'This chair is a great addition for any room in your home, not only just the living room. Featuring a mid-century design with modern available on the market. However, and with that said, if you are like most people in the market, it is just perfect!',
                    5,
                    '1 days ago',
                  ),
                  _buildReview(
                    'Frank Garrett',
                    'Suspendisse potenti. Nullam tincidunt lacus tellus, aliquam est vehicula a. Pellentesque consectetur condimentum nulla, eleifend condimentum purus.',
                    4,
                    '4 days ago',
                  ),
                  _buildReview(
                    'Randy Palmer',
                    'Aenean ante nisi, gravida non mattis semper, varius et magna. Donec ultricies vulputate arcu, vel commodo eros pellentesque sed. In id tortor gravida orci consequat viverra.',
                    4,
                    '1 month ago',
                  ),
                ],
              ),
            ),

            // Write a review button
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDistribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRatingRow('Excellent', 5, Colors.green, 0.6),
        _buildRatingRow('Good', 4, Colors.greenAccent, 0.3),
        _buildRatingRow('Average', 3, Colors.yellow, 0.2),
        _buildRatingRow('Below Average', 2, Colors.orange, 0.1),
        _buildRatingRow('Poor', 1, Colors.red, 0.05),
      ],
    );
  }

  Widget _buildRatingRow(
      String label, int stars, Color color, double widthFactor) {
    return Row(
      children: [
        Text(label),
        SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: widthFactor,
            color: color,
            backgroundColor: Colors.grey[300],
          ),
        ),
        SizedBox(width: 8),
        StarDisplay(value: stars),
      ],
    );
  }

  Widget _buildReview(String name, String comment, int rating, String timeAgo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(child: Icon(Icons.person)),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                StarDisplay(value: rating),
              ],
            ),
            Spacer(),
            Text(timeAgo),
          ],
        ),
        SizedBox(height: 8),
        Text(comment),
        Divider(),
      ],
    );
  }
}

// Custom widget for displaying stars
class StarDisplay extends StatelessWidget {
  final int value;

  const StarDisplay({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < value ? Icons.star : Icons.star_border,
        );
      }),
    );
  }
}
