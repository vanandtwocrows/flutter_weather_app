import 'package:flutter/material.dart';

class HourlyForcastCard extends StatelessWidget {
  final IconData icon;
  final String time;
  final String temperature;

  const HourlyForcastCard({
    super.key,
    required this.icon,
    required this.time,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Icon(
              icon,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(temperature)
          ],
        ),
      ),
    );
  }
}

class HourlyForcastList extends StatelessWidget {
  final List<Map<String, dynamic>> hourlyForcastList;

  const HourlyForcastList({
    super.key,
    required this.hourlyForcastList,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        itemCount: hourlyForcastList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final currentForcast = hourlyForcastList[index];
          return HourlyForcastCard(
              time: currentForcast['time'],
              icon: currentForcast['icon'],
              temperature: currentForcast['temperature']);
        },
      ),
    );
  }
}
