import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_first_app/model/response/trip_idx_get_res.dart';
import '../config/config.dart';

class TripPage extends StatefulWidget {
  final int idx;
  TripPage({super.key, required this.idx});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  String url = '';
  late TripIdxGetResponse tripIdxGetResponse;
  late Future<void> loadData;

  @override
  void initState() {
    super.initState();
    loadData = loadDataAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ชื่อทริปตัวหนา
                Text(
                  tripIdxGetResponse.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // ประเทศ
                Text(
                  tripIdxGetResponse.country,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),

                // รูปภาพ
                tripIdxGetResponse.coverimage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          tripIdxGetResponse.coverimage,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 50),
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 50),
                        ),
                      ),
                const SizedBox(height: 12),

                // แถวราคาและโซน
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ราคา: ${tripIdxGetResponse.price} บาท',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'โซน${destinationZoneValues.reverse[tripIdxGetResponse.destinationZone]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // รายละเอียด
                Text(
                  tripIdxGetResponse.detail,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // ปุ่มจองตรงกลาง
                Center(
                  child: FilledButton(
                    onPressed: () {},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      child: Text('จองเลย', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    url = config['apiEndpoint'];
    var res = await http.get(Uri.parse('$url/trips/${widget.idx}'));
    log(res.body);
    tripIdxGetResponse = tripIdxGetResponseFromJson(res.body);
  }
}
