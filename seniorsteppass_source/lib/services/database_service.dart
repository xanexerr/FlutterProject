import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seniorsteppass_source/models/company_model.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/review_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

// --- Profile ----
  // collect user data
  Future<UserModel> getUserData(String email) async {
    var query = await _db.collection('users').where('email', isEqualTo: email).get();

    if (query.docs.isNotEmpty) {
      var doc = query.docs.first;
      return UserModel.fromJson(doc.data(), doc.id);
    } else {
      throw Exception("User data not found for email: $email");
    }
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

  Future<String?> getCompanyLogo(String companyName) async {
    var query = await _db
      .collection('internships')
      .where('company_name', isEqualTo: companyName)
      .get();
    if (query.docs.isNotEmpty) {
      return query.docs.first.data()['logo_url']; //
    }
    return null;
  }

  Future<void> addReview(ReviewModel review) async {
    await _db.collection('reviews').add(review.toJson());
  }
// ----------

// ---- Admin Dashbosrd -----
  Future<int> getTotalUsersCount() async {
    var snapshot = await _db.collection('users').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getActiveProjectsCount() async {
    var snapshot = await _db.collection('projects').where('status', isEqualTo: 'Active').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getTotalCompaniesCount() async {
    var snapshot = await _db.collection('internships').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getTotalReviewsCount() async {
    var snapshot = await _db.collection('reviews').count().get();
    return snapshot.count ?? 0;
  }

}
