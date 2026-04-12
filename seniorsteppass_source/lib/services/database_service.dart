import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/review_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // collect user data
  Stream<UserModel> streamUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      return UserModel.fromJson(snap.data() as Map<String, dynamic>, snap.id);
    });
  }

  // collect project data
  Future<List<ProjectModel>> getUserProjects(String uid) async {
    var query = await _db
        .collection('projects')
        .where('owner_id', isEqualTo: uid)
        .get();
    return query.docs
        .map((doc) => ProjectModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  // collect review data
  Future<List<ReviewModel>> getUserReviews(String uid) async {
    var query = await _db
        .collection('reviews')
        .where('user_id', isEqualTo: uid)
        .get();
    return query.docs
        .map((doc) => ReviewModel.fromJson(doc.data(), doc.id))
        .toList();
  }
}
