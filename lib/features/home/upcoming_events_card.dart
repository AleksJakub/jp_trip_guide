import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpcomingEventsCard extends ConsumerWidget {
  const UpcomingEventsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock upcoming events data - in a real app, this would come from an events API
    final List<Map<String, dynamic>> upcomingEvents = [
      {
        'title': 'Cherry Blossom Festival',
        'location': 'Ueno Park, Tokyo',
        'date': 'March 25-30',
        'time': '10:00 AM - 6:00 PM',
        'category': 'Cultural',
        'icon': Icons.local_florist,
        'color': Colors.pink,
      },
      {
        'title': 'Traditional Tea Ceremony',
        'location': 'Kyoto Garden',
        'date': 'March 28',
        'time': '2:00 PM - 4:00 PM',
        'category': 'Cultural',
        'icon': Icons.local_cafe,
        'color': Colors.green,
      },
      {
        'title': 'Night Food Market',
        'location': 'Dotonbori, Osaka',
        'date': 'March 29',
        'time': '6:00 PM - 11:00 PM',
        'category': 'Food',
        'icon': Icons.restaurant,
        'color': Colors.orange,
      },
      {
        'title': 'Sumo Tournament',
        'location': 'Ryogoku Kokugikan, Tokyo',
        'date': 'April 1-15',
        'time': 'Various times',
        'category': 'Sports',
        'icon': Icons.sports_martial_arts,
        'color': Colors.red,
      },
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade50,
              Colors.grey.shade100,
            ],
          ),
        ),
                 child: Padding(
           padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.event,
                    color: Colors.grey.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Upcoming Events',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // TODO: Navigate to events page
                    },
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                    tooltip: 'View All Events',
                  ),
                ],
              ),
                             const SizedBox(height: 10),
               SizedBox(
                 height: 120,
                 child: ListView.builder(
                   scrollDirection: Axis.horizontal,
                   itemCount: upcomingEvents.length,
                   itemBuilder: (context, index) {
                     final event = upcomingEvents[index];
                     return Container(
                       width: 200,
                       margin: const EdgeInsets.only(right: 12),
                       child: Card(
                         elevation: 2,
                         child: Padding(
                           padding: const EdgeInsets.all(10),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Row(
                                 children: [
                                   Container(
                                     padding: const EdgeInsets.all(4),
                                     decoration: BoxDecoration(
                                       color: event['color'].withOpacity(0.2),
                                       borderRadius: BorderRadius.circular(6),
                                     ),
                                     child: Icon(
                                       event['icon'],
                                       color: event['color'],
                                       size: 14,
                                     ),
                                   ),
                                   const SizedBox(width: 6),
                                   Expanded(
                                     child: Text(
                                       event['category'],
                                       style: TextStyle(
                                         color: Colors.grey.shade600,
                                         fontSize: 11,
                                         fontWeight: FontWeight.w500,
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                               const SizedBox(height: 6),
                               Text(
                                 event['title'],
                                 style: const TextStyle(
                                   fontSize: 13,
                                   fontWeight: FontWeight.bold,
                                 ),
                                 maxLines: 2,
                                 overflow: TextOverflow.ellipsis,
                               ),
                               const SizedBox(height: 3),
                               Text(
                                 event['location'],
                                 style: TextStyle(
                                   fontSize: 11,
                                   color: Colors.grey.shade600,
                                 ),
                                 maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                               ),
                               const SizedBox(height: 3),
                               Text(
                                 '${event['date']} • ${event['time']}',
                                 style: TextStyle(
                                   fontSize: 10,
                                   color: Colors.grey.shade500,
                                 ),
                                 maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                               ),
                             ],
                           ),
                         ),
                       ),
                     );
                   },
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
