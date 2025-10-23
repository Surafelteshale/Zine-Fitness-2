import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MonthlyStatsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? currentMonthStats;
  List<Map<String, dynamic>> allMonthsStats = [];

  /// --- CONFIGURATION: Change this duration for production ---
  /// Set to 1 minute for easy testing. Change to Duration(days: 30) for production.
  final Duration _rolloverThreshold = const Duration(minutes: 1);
  /// ---------------------------------------------------------

  /// Helper to get the current month ID (e.g., "2025-10")
  String get currentMonthId {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// Fetch or initialize the current month's stats
  Future<void> fetchCurrentMonth() async {
    // 1. Check the document for the ID based on current time (e.g., "2025-10")
    final docRef = _firestore.collection('MonthlyStats').doc(currentMonthId);
    final docSnap = await docRef.get();

    // If current month doc doesn't exist, create it immediately
    if (!docSnap.exists) {
      await _createNewMonth(currentMonthId);
    } else {
      // Logic for duration-based month rollover check
      final data = docSnap.data()!;
      final Timestamp createdAt = data['createdAt'];
      final DateTime createdDate = createdAt.toDate();
      final now = DateTime.now();

      // Calculate the point in time when rollover should occur
      final DateTime rolloverTime = createdDate.add(_rolloverThreshold);

      // Check if the current time has passed the rollover threshold
      if (now.isAfter(rolloverTime)) {
        debugPrint('⚠️ Rollover threshold passed (1 minute duration). Checking for new month creation.');

        // Even if the threshold passed, the document ID might be the same (e.g.,
        // the 1-minute mark passed within the same calendar day).
        // We ensure a document for the *actual* current month (currentMonthId) exists.
        final actualCurrentMonthId = currentMonthId;

        final nextDoc = _firestore.collection('MonthlyStats').doc(actualCurrentMonthId);
        final nextSnap = await nextDoc.get();

        // If the document for the current actual month does not exist, create it.
        // This usually only happens when the application runs for the first time
        // after the threshold has passed and the calendar month has actually changed.
        if (!nextSnap.exists) {
          await _createNewMonth(actualCurrentMonthId);
          debugPrint("✅ New document created for $actualCurrentMonthId after duration rollover.");
        }
      }
    }

    // Load the current month's stats (always based on the current system time ID)
    currentMonthStats =
        (await _firestore.collection('MonthlyStats').doc(currentMonthId).get())
            .data();

    await fetchAllMonths();
    notifyListeners();
  }

  /// Create a new month document with initial values
  Future<void> _createNewMonth(String monthId) async {
    await _firestore.collection('MonthlyStats').doc(monthId).set({
      'income': 0,
      'newUsers': 0,
      'payments': [],
      'newUsersList': [],
      'createdAt': Timestamp.now(),
    });
    debugPrint("✅ New MonthlyStats created for $monthId");
  }

  /// Fetch all months (history)
  Future<void> fetchAllMonths() async {
    final snapshot = await _firestore
        .collection('MonthlyStats')
        .orderBy('createdAt', descending: true)
        .get();

    allMonthsStats =
        snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Refresh stats (alias for convenience)
  Future<void> refreshStats() async {
    await fetchCurrentMonth();
  }

  /// Add a payment to the current month
  Future<void> addPayment(int amount, String userId) async {
    final docRef = _firestore.collection('MonthlyStats').doc(currentMonthId);
    final docSnap = await docRef.get();

    final newPayment = {
      'amount': amount,
      'date': Timestamp.now(),
      'userId': userId,
    };

    if (!docSnap.exists) {
      await _createNewMonth(currentMonthId);
    }

    await docRef.update({
      'income': FieldValue.increment(amount),
      'payments': FieldValue.arrayUnion([newPayment]),
    });

    await fetchCurrentMonth();
  }

  /// Add a new user to the current month
  Future<void> addUser(String userId) async {
    final docRef = _firestore.collection('MonthlyStats').doc(currentMonthId);
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      await _createNewMonth(currentMonthId);
    }

    await docRef.update({
      'newUsers': FieldValue.increment(1),
      'newUsersList': FieldValue.arrayUnion([userId]),
    });

    await fetchCurrentMonth();
  }
}