// lib/utils/storage_helper.dart

import 'package:client/utils/storage_stub.dart';

// Importa a implementação mobile por padrão, ou a web se 'dart:html' estiver disponível.
// Esta linha traz a função getStorage() para o escopo deste arquivo.
import 'package:client/utils/storage_mobile.dart'
    if (dart.library.html) 'package:client/utils/storage_web.dart';


// Esta é a classe final que você usará em todo o seu aplicativo.
class StorageHelper implements Storage {

  // 1. Instância privada e estática (padrão Singleton)
  static final StorageHelper _instance = StorageHelper._internal();

  // 2. Variável para guardar a implementação correta (Web ou Mobile)
  late final Storage _storageImplementation;

  // 3. Construtor nomeado e privado.
  // Ele é chamado apenas uma vez para criar a instância _instance.
  StorageHelper._internal() {
    // A função getStorage() vem do import condicional e nos dá
    // a instância correta para a plataforma atual.
    _storageImplementation = getStorage();
  }

  // 4. Getter público estático para acessar a instância única.
  static StorageHelper get instance => _instance;

  // 5. Delegação: Os métodos públicos da nossa classe simplesmente
  // repassam a chamada para a implementação correta.
  @override
  Future<String?> getItem(String key) {
    return _storageImplementation.getItem(key);
  }

  @override
  Future<void> setItem(String key, String value) {
    return _storageImplementation.setItem(key, value);
  }

  @override
  Future<void> removeItem(String key) {
    return _storageImplementation.removeItem(key);
  }
}