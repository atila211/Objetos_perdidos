import 'package:cloud_firestore/cloud_firestore.dart';

class Guardar_objeto {
  Future<void> guardar(String titulo, String descripcion, String tipo,
      String categoria, String lugar, String fecha, Blob foto, String autor) {
    return FirebaseFirestore.instance.collection('Objetos').add({
      'Titulo': titulo,
      'Descripcion': descripcion,
      'Tipo': tipo,
      'Categoria': categoria,
      'Lugar': lugar,
      'Fecha': fecha,
      'Foto': foto,
      'Estado': 'Vigente',
      'Autor': autor,
    });
  }
}

class Eliminar_objeto {
  Future<void> eliminar(String id) {
    return FirebaseFirestore.instance.collection('Objetos').doc(id).delete();
  }
}

class Actualizar_estado {
  Future<void> marcar_devuelto(String id) {
    return FirebaseFirestore.instance.collection('Objetos').doc(id).update({
      'Estado': 'Devuelto',
    });
  }
}

class Solicitar_categorias {
  Stream<QuerySnapshot> categorias() {
    return FirebaseFirestore.instance.collection('Categorias').snapshots();
  }
}

class Solicitar_objetos {
  Stream<QuerySnapshot> objetos() {
    return FirebaseFirestore.instance.collection('Objetos').snapshots();
  }

  Stream<QuerySnapshot> mis_objetos(String email) {
    return FirebaseFirestore.instance
        .collection('Objetos')
        .where('Autor', isEqualTo: email)
        .snapshots();
  }
}
