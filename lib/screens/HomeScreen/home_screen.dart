import 'package:flutter/material.dart';
import 'package:odomex/data/vehicles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: Vehicles.vehicles.length,
        itemBuilder: (context, index) {
          return Card(
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          Vehicles.vehicles[index].model,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          Vehicles
                              .vehicles[index]
                              .odometerReading
                              .toString(),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.add),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.remove_red_eye),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
