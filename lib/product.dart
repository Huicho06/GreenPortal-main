import 'package:flutter/material.dart';
import 'services/api_service.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  List<Map<String, dynamic>> _products = [];
  int? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    try {
      List<Map<String, dynamic>> products = await ApiService.getProducts();
      setState(() {
        _products = products.map((product) {
          return {
            'id': int.tryParse(product['id'].toString()) ?? 0,
            'nombre': product['nombre'] ?? '',
            'descripcion': product['descripcion'] ?? '',
            'precio': double.tryParse(product['precio'].toString()) ?? 0.0,
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar productos: $e')));
    }
  }

  void _insertProduct() async {
    String nombre = _nombreController.text;
    String descripcion = _codigoController.text;
    double precio = double.parse(_precioController.text);
    int stock = 1;

    try {
      await ApiService.addProduct(nombre, descripcion, precio, stock);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Producto insertado con éxito')));
      _loadProducts();
      _clearTextFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al insertar producto: $e')));
    }
  }

  void _updateProduct() async {
    if (_selectedProductId == null) return;

    String nombre = _nombreController.text;
    String descripcion = _codigoController.text;
    double precio = double.parse(_precioController.text);
    int stock = 1;

    try {
      await ApiService.updateProduct(_selectedProductId!, nombre, descripcion, precio, stock);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Producto actualizado con éxito')));
      _loadProducts();
      _clearTextFields();
      _selectedProductId = null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar producto: $e')));
    }
  }

  void _deleteProduct(int id) async {
    try {
      await ApiService.deleteProduct(id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Producto eliminado con éxito')));
      _loadProducts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar producto: $e')));
    }
  }

  void _clearTextFields() {
    _nombreController.clear();
    _codigoController.clear();
    _precioController.clear();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación de cierre de sesión'),
          content: Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cerrar sesión'),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crud Producto'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Cerrar Sesión') {
                _showLogoutDialog(context);
              } else if (value == 'Home') {
                Navigator.pushNamed(context, '/home');
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Home', 'Cerrar Sesión'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bosque2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white70,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del Producto',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _codigoController,
                      decoration: InputDecoration(
                        labelText: 'Código',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _precioController,
                      decoration: InputDecoration(
                        labelText: 'Precio',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _selectedProductId == null ? _insertProduct : _updateProduct,
                          child: Text(_selectedProductId == null ? 'Insertar' : 'Modificar'),
                        ),
                        SizedBox(width: 10),
                        if (_selectedProductId != null)
                          ElevatedButton(
                            onPressed: () {
                              _clearTextFields();
                              setState(() {
                                _selectedProductId = null;
                              });
                            },
                            child: Text('Cancelar'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Nombre')),
                        DataColumn(label: Text('Código')),
                        DataColumn(label: Text('Precio')),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: _products.map((product) {
                        return DataRow(cells: [
                          DataCell(Text(product['nombre'] ?? '')),
                          DataCell(Text(product['descripcion'] ?? '')),
                          DataCell(Text('\$${product['precio'] ?? 0.0}')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  setState(() {
                                    _selectedProductId = product['id'];
                                    _nombreController.text = product['nombre'] ?? '';
                                    _codigoController.text = product['descripcion'] ?? '';
                                    _precioController.text = (product['precio'] ?? 0.0).toString();
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteProduct(product['id']);
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
