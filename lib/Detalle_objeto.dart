import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/services/servicio.dart';

class DetalleObjeto extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const DetalleObjeto({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    bool esMio = doc['Autor'] == user?.email;
    bool devuelto = doc['Estado'] == 'Devuelto';

    return Scaffold(
      appBar: AppBar(title: Text('Detalle')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              color: Colors.grey.shade300,
              child: doc.data().toString().contains('Foto')
                  ? Image.memory(doc['Foto'].bytes, fit: BoxFit.cover)
                  : Center(
                      child: Icon(Icons.image, size: 60, color: Colors.grey),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc['Titulo'],
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(label: Text(doc['Tipo'])),
                      Chip(label: Text(doc['Categoria'])),
                      Chip(
                        label: Text(doc['Estado']),
                        backgroundColor: devuelto ? Colors.grey : Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Descripción',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(doc['Descripcion']),
                  SizedBox(height: 10),
                  Text('Lugar', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(doc['Lugar']),
                  SizedBox(height: 10),
                  Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(doc['Fecha']),
                  SizedBox(height: 10),
                  Text('Autor', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(doc['Autor']),
                  SizedBox(height: 24),
                  if (esMio)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!devuelto)
                          ElevatedButton.icon(
                            onPressed: () async {
                              bool? confirmar = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Marcar como devuelto'),
                                  content: Text(
                                    '¿Confirmas que este objeto fue devuelto a su dueño?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(
                                        'Confirmar',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmar == true) {
                                await Actualizar_estado().marcar_devuelto(
                                  doc.id,
                                );
                                Navigator.pop(context);
                              }
                            },
                            icon: Icon(Icons.check),
                            label: Text('Devuelto'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            bool? confirmar = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Eliminar publicación'),
                                content: Text(
                                  '¿Estás seguro que deseas eliminar esta publicación?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirmar == true) {
                              await Eliminar_objeto().eliminar(doc.id);
                              Navigator.pop(context);
                            }
                          },
                          icon: Icon(Icons.delete),
                          label: Text('Eliminar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
