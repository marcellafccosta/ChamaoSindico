import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

String getApiBaseUrl() {
  if (kIsWeb) {
    final host = Uri.base.host;
    if (host == 'localhost' || host == '127.0.0.1') {
      return 'http://localhost:3000/api';
    } else {
      return 'https://server-10l0.onrender.com/api';
    }
  } else if (Platform.isAndroid) {
    return 'https://server-10l0.onrender.com/api';
  } else {
    return 'https://server-10l0.onrender.com/api';
  }
}

String getSocketBaseUrl() {
  if (kIsWeb) {
    final host = Uri.base.host;
    if (host == 'localhost' || host == '127.0.0.1') {
      return 'http://localhost:3000';
    } else {
      return 'https://server-10l0.onrender.com';
    }
  } else if (Platform.isAndroid) {
    return 'https://server-10l0.onrender.com';
  } else {
    return 'https://server-10l0.onrender.com';
  }
}