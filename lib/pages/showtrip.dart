import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/model/response/trip_get_res.dart';
import 'package:my_first_app/pages/profile.dart';
import 'package:my_first_app/pages/trip.dart';
import '../config/config.dart';

class ShowTripPage extends StatefulWidget {
  final int cid;
  const ShowTripPage({super.key, required this.cid});

  @override
  State<ShowTripPage> createState() => _ShowTripPageState();
}

class _ShowTripPageState extends State<ShowTripPage> {
  String url = '';
  List<TripGetResponse> tripGetResponse = [];
  late Future<List<TripGetResponse>> loadData;

  final List<String> continents = [
    'ทั้งหมด',
    'ยุโรป',
    'เอเชีย',
    'เอเชียตะวันออกเฉียงใต้',
    'ประเทศไทย',
  ];

  String selectedContinent = 'ทั้งหมด';

  @override
  void initState() {
    super.initState();
    loadData = loadDataAsync();
  }

  DestinationZone? getDestinationZoneFromString(String continent) {
    if (continent == 'ทั้งหมด') return null;
    return destinationZoneValues.map[continent];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการทริป'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              log(value);
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(idx: widget.cid),
                  ),
                );
              } else if (value == 'logout') {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('ข้อมูลส่วนตัว'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('ออกจากระบบ'),
              ),
            ],
          ),
        ],
      ),

      body: FutureBuilder<List<TripGetResponse>>(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("เกิดข้อผิดพลาด: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("ไม่พบทริปที่สามารถแสดงได้"));
          }

          tripGetResponse = snapshot.data!;

          DestinationZone? selectedZone = getDestinationZoneFromString(
            selectedContinent,
          );

          List<TripGetResponse> filteredTrips = selectedZone == null
              ? tripGetResponse
              : tripGetResponse
                    .where((trip) => trip.destinationZone == selectedZone)
                    .toList();

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: continents.map((continent) {
                      bool isSelected = continent == selectedContinent;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: isSelected
                                ? const Color.fromARGB(255, 155, 5, 193)
                                : null,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedContinent = continent;
                            });
                          },
                          child: Text(
                            continent,
                            style: TextStyle(
                              color: isSelected ? Colors.white : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 10),
                // ListView ของทริป
                Expanded(
                  child: filteredTrips.isEmpty
                      ? const Center(child: Text('ไม่พบทริปในทวีปนี้'))
                      : ListView.builder(
                          itemCount: filteredTrips.length,
                          itemBuilder: (context, index) {
                            final trip = filteredTrips[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    trip.coverimage.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              trip.coverimage,
                                              height: 100,
                                              width: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      height: 100,
                                                      width: 100,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          color: Colors.grey,
                                                          size: 40,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            ),
                                          )
                                        : Container(
                                            height: 100,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 40,
                                              ),
                                            ),
                                          ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            trip.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text('ประเทศ: ${trip.country}'),
                                          Text(
                                            'ระยะเวลา: ${trip.duration} วัน',
                                          ),
                                          Text('ราคา: ${trip.price} บาท'),
                                          const SizedBox(height: 8),
                                          FilledButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TripPage(idx: trip.idx),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'รายละเอียดเพิ่มเติม',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<List<TripGetResponse>> loadDataAsync() async {
    var config = await Configuration.getConfig();
    url = config['apiEndpoint'];

    var res = await http.get(Uri.parse('$url/trips'));
    log(res.body);

    final trips = tripGetResponseFromJson(res.body);
    log("โหลดทริปทั้งหมด: ${trips.length}");

    return trips;
  }
}
