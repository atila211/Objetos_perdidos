import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/Detalle_objeto.dart';
import 'package:proyecto/services/servicio.dart';

class MisPublicaciones extends StatelessWidget {
  const MisPublicaciones({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Mis publicaciones')),
      body: StreamBuilder<QuerySnapshot>(
        stream: Solicitar_objetos().mis_objetos(user?.email ?? ''),
        builder: (context, snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No tienes publicaciones'));
          }
          return ListView.separated(
            separatorBuilder: (context, index) => Divider(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var obj = snapshot.data!.docs[index];
              bool devuelto = obj['Estado'] == 'Devuelto';
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleObjeto(doc: obj),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: devuelto ? Colors.grey.shade200 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Image.memory(
                          obj['Foto'].bytes,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              obj['Titulo'],
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            SizedBox(height: 4),
                            Text('${obj['Tipo']} · ${obj['Categoria']}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: devuelto ? Colors.grey : Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                obj['Estado'],
                                style: TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
