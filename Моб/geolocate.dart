import 'dart:convert' as convert;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

Future<String> getadress(String arguments) async {
  // This example uses the Google Books API to search for books about http.
  // https://developers.google.com/books/docs/overview
  print('hui');

   var position = await determinePosition();

  print(position.longitude);
  // Await the http get response, then decode the json-formatted response.

  var url = Uri.parse(
      'https://suggestions.dadata.ru/suggestions/api/4_1/rs/geolocate/address');
  var response = await http.post(url,
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-type': 'application/json',
        'Authorization': 'Token a29000408ff35f96119caf675e6714e746d6391d',
      },
      body: convert.jsonEncode({"lat": position.latitude, "lon": position.longitude}));
      var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
  print('Response status: ${response.statusCode}');
  print('Response body: ${jsonResponse['suggestions'][0]['value']}');
  //print(await http.read(Uri.https('example.com', 'foobar.txt')));
  return await jsonResponse['suggestions'][0]['value'].toString();
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  //print(Geolocator.getCurrentPosition());
  var currentLocation = Geolocator.getCurrentPosition();

  return await Geolocator.getCurrentPosition();
}
