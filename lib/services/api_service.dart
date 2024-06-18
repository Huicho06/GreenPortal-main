import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Usa la dirección IP de tu máquina local
  static const String _baseUrl = 'http://192.168.130.187:8000/greenportalCRUD';

  static Future<Map<String, dynamic>> _post(String path, Map<String, String> body) async {
    final url = Uri.parse('$_baseUrl/$path');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed request: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during HTTP request: $e');
      throw Exception('Error during HTTP request: $e');
    }
  }

  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await _post('login.php', {'email': email, 'password': password});
    return response;
  }

  static Future<void> registerUser(String nombre, String email, String password) async {
    final response = await _post('register.php', {'nombre': nombre, 'email': email, 'password': password});
    if (response['success']) {
      print('User registered');
    } else {
      throw Exception(response['message']);
    }
  }

  static Future<void> addProduct(String nombre, String descripcion, double precio, int stock) async {
    final response = await _post('add_product.php', {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio.toString(),
      'stock': stock.toString(),
    });
    if (response['success']) {
      print('Product added');
    } else {
      throw Exception('Failed to add product');
    }
  }

  static Future<void> updateProduct(int id, String nombre, String descripcion, double precio, int stock) async {
    final response = await _post('update_product.php', {
      'id': id.toString(),
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio.toString(),
      'stock': stock.toString(),
    });
    if (response['success']) {
      print('Product updated');
    } else {
      throw Exception('Failed to update product');
    }
  }

  static Future<void> deleteProduct(int id) async {
    final response = await _post('delete_product.php', {'id': id.toString()});
    if (response['success']) {
      print('Product deleted');
    } else {
      throw Exception('Failed to delete product');
    }
  }

  static Future<List<Map<String, dynamic>>> getProducts() async {
    final url = Uri.parse('$_baseUrl/get_products.php');
    try {
      final response = await http.get(url);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> products = json.decode(response.body);
        return products.map((product) => product as Map<String, dynamic>).toList();
      } else {
        print('Failed request: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed request: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during HTTP request: $e');
      throw Exception('Error during HTTP request: $e');
    }
  }
}
