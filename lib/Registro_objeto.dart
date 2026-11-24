import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proyecto/services/servicio.dart';

class RegistroObjeto extends StatefulWidget {
  const RegistroObjeto({super.key});

  @override
  State<RegistroObjeto> createState() => _RegistroObjetoState();
}

class _RegistroObjetoState extends State<RegistroObjeto> {
  List<String> lista_categorias = [
    'Electronica',
    'Documentos',
    'Ropa y accesorios',
    'Llaves',
    'Utiles',
    'Otros',
  ];

  List<String> lista_tipo = ['Perdido', 'Encontrado'];
  DateTime? fechaSeleccionada;
  String tipo_escogido = 'Perdido';
  String categoria_escogida = 'Electronica';
  Uint8List? foto_bytes;

  final TextEditingController controlador_titulo = TextEditingController();
  final TextEditingController controlador_descripcion = TextEditingController();
  final TextEditingController controlador_Lugar = TextEditingController();
  final TextEditingController controlador_Fecha = TextEditingController();

  Future<void> seleccionarFechaHora() async {
    DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      TimeOfDay? hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (hora != null) {
        setState(() {
          fechaSeleccionada = DateTime(
            fecha.year,
            fecha.month,
            fecha.day,
            hora.hour,
            hora.minute,
          );
          controlador_Fecha.text =
              '${fecha.day}/${fecha.month}/${fecha.year} ${hora.hour}:${hora.minute.toString().padLeft(2, '0')}';
        });
      }
    }
  }

  Future<void> seleccionarFoto(ImageSource fuente) async {
    final ImagePicker picker = ImagePicker();
    final XFile? foto = await picker.pickImage(
      source: fuente,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );
    if (foto != null) {
      Uint8List bytes = await foto.readAsBytes();
      if (bytes.lengthInBytes > 900000) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La foto es muy grande, intenta con otra')),
        );
        return;
      }
      setState(() => foto_bytes = bytes);
    }
  }

  void mostrarOpcionesFoto() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Tomar foto'),
            onTap: () {
              Navigator.pop(context);
              seleccionarFoto(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Elegir de galería'),
            onTap: () {
              Navigator.pop(context);
              seleccionarFoto(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nueva publicación')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Align(alignment: Alignment.centerLeft, child: Text('Título')),
              TextField(
                controller: controlador_titulo,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Descripción'),
              ),
              TextField(
                controller: controlador_descripcion,
                maxLines: 3,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Align(alignment: Alignment.centerLeft, child: Text('Tipo')),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.find_in_page),
                ),
                value: tipo_escogido,
                items: lista_tipo.map((opcion) {
                  return DropdownMenuItem(value: opcion, child: Text(opcion));
                }).toList(),
                onChanged: (nuevoValor) {
                  setState(() => tipo_escogido = nuevoValor!);
                },
              ),
              SizedBox(height: 20),
              Align(alignment: Alignment.centerLeft, child: Text('Categoría')),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: categoria_escogida,
                items: lista_categorias.map((opcion) {
                  return DropdownMenuItem(value: opcion, child: Text(opcion));
                }).toList(),
                onChanged: (nuevoValor) {
                  setState(() => categoria_escogida = nuevoValor!);
                },
              ),
              SizedBox(height: 20),
              Align(alignment: Alignment.centerLeft, child: Text('Lugar')),
              TextField(
                controller: controlador_Lugar,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Fecha y Hora'),
              ),
              TextFormField(
                controller: controlador_Fecha,
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                  hintText: 'DD/MM/AAAA hh:mm',
                ),
                onTap: seleccionarFechaHora,
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Foto del objeto'),
              ),
              GestureDetector(
                onTap: mostrarOpcionesFoto,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: foto_bytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(foto_bytes!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 40,
                              color: Colors.grey,
                            ),
                            Text(
                              'Toca para agregar foto',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'cancelar',
                    backgroundColor: Colors.grey,
                    label: Text('Cancelar'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  FloatingActionButton.extended(
                    heroTag: 'guardar',
                    label: Text('Guardar'),
                    onPressed: () async {
                      if (controlador_titulo.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('El título es obligatorio')),
                        );
                        return;
                      }
                      if (controlador_descripcion.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('La descripción es obligatoria'),
                          ),
                        );
                        return;
                      }
                      if (controlador_Lugar.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('El lugar es obligatorio')),
                        );
                        return;
                      }
                      if (controlador_Fecha.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('La fecha es obligatoria')),
                        );
                        return;
                      }
                      if (foto_bytes == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('La foto es obligatoria')),
                        );
                        return;
                      }

                      final user = FirebaseAuth.instance.currentUser;
                      await Guardar_objeto().guardar(
                        controlador_titulo.text.trim(),
                        controlador_descripcion.text.trim(),
                        tipo_escogido,
                        categoria_escogida,
                        controlador_Lugar.text.trim(),
                        controlador_Fecha.text.trim(),
                        Blob(foto_bytes!),
                        user?.email ?? '',
                      );

                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
