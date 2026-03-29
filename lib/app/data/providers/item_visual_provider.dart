import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class ItemVisualProvider {
  final _client = SupabaseService.to.client;

  Future<List<Map<String, dynamic>>> getByOrg(String orgId) async {
    return await _client
        .from('item_visuals')
        .select()
        .eq('organisation_id', orgId)
        .order('item_name');
  }

  Future<Map<String, dynamic>?> getByItemName(String orgId, String itemName) async {
    return await _client
        .from('item_visuals')
        .select()
        .eq('organisation_id', orgId)
        .eq('item_name', itemName)
        .maybeSingle();
  }

  Future<Map<String, dynamic>> upsert(Map<String, dynamic> data) async {
    return await _client
        .from('item_visuals')
        .upsert(data, onConflict: 'organisation_id,item_name')
        .select()
        .single();
  }

  Future<String> uploadPhoto(String orgId, String itemName, Uint8List bytes) async {
    final safeName = itemName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final path = '$orgId/${safeName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _client.storage.from('item-photos').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
    );
    return _client.storage.from('item-photos').getPublicUrl(path);
  }
}
