import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  final String cloudName = 'dlwydwqi9';
  // final String uploadPreset = 'SeniorPassStep_Projects';
  // final String uploadPreset = 'SeniorPassStep_Users';
  // final String uploadPreset = 'SeniorPassStep_Internships';

  Future<String?> uploadImage(File imageFile, String uploadPreset) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final result = jsonDecode(responseString);
        return result['secure_url'];
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
