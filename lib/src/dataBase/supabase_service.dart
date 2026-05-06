import 'dart:typed_data';

import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart';

/// env
final env = DotEnv()..load();

/// SupabaseClient
class SupabaseService {
  /// SupabaseClient
  SupabaseService() {
    supabase = SupabaseClient(
      supabaseUrl,
      supabaseKey,
    );
  }

  /// supabaseUrl
  final String supabaseUrl = env['SUPABASE_URL'] ?? '';

  /// supabaseKey
  final String supabaseKey = env['SUPABASE_ANON_KEY'] ?? '';

  /// supabase
  late SupabaseClient supabase;

  /// uploadProductImage
  Future<String> uploadProductImage({
    required String id,
    required String mimeType,
    required UploadedFile image,
  }) async {
    final extension = image.name.split('.').last;
    final fileName = '$id.$extension';
    final bytes = await image.readAsBytes();
    final unit8Bytes = Uint8List.fromList(bytes);
    await supabase.storage.from('product_image').uploadBinary(
          fileName,
          unit8Bytes,
          fileOptions: FileOptions(contentType: mimeType),
        );
    final imageUrl =
        supabase.storage.from('product_image').getPublicUrl(fileName);
    return imageUrl;
  }
}
