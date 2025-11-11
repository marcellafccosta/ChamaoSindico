import 'dart:html' as html; 
import 'package:client/utils/storage_stub.dart';

class StorageWeb extends Storage {
  @override
  Future<String?> getItem(String key) async {
    return html.window.localStorage[key];
  }

  @override
  Future<void> setItem(String key, String value) async {
    html.window.localStorage[key] = value;
  }

  @override
  Future<void> removeItem(String key) async {
    html.window.localStorage.remove(key);
  }
}

Storage getStorage() => StorageWeb();