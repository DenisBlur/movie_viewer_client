import 'package:shared_preferences/shared_preferences.dart';

class SaveData {
  Future<String?> loadUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? out = prefs.getString('username');
    return out;
  }

  saveUsername(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', value);
  }


}
