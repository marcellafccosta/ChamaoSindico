abstract class Storage {
  Future<String?> getItem(String key);
  Future<void> setItem(String key, String value);
  Future<void> removeItem(String key);
}