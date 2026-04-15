import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class WorkplaceRequestsManagementScreen extends StatefulWidget {
  const WorkplaceRequestsManagementScreen({super.key});

  @override
  State<WorkplaceRequestsManagementScreen> createState() =>
      _WorkplaceRequestsManagementScreenState();
}

class _WorkplaceRequestsManagementScreenState
    extends State<WorkplaceRequestsManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingRequests = [];
  String _filterStatus = 'pending';

  final List<String> _statusOptions = ['pending', 'approved', 'rejected'];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = <Map<String, dynamic>>[];

      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();

      // For each user, get their workplace requests
      for (final userDoc in usersSnapshot.docs) {
        final requestsSnapshot = await userDoc.reference
            .collection('workplace_requests')
            .where('status', isEqualTo: _filterStatus)
            .get();

        for (final requestDoc in requestsSnapshot.docs) {
          final data = requestDoc.data();
          requests.add({
            'id': requestDoc.id,
            'userDocId': userDoc.id,
            'workplace_name': data['workplace_name'] ?? 'N/A',
            'company': data['company'] ?? 'N/A',
            'position': data['position'] ?? 'N/A',
            'description': data['description'] ?? '',
            'requester_name': data['requester_name'] ?? 'Unknown',
            'requester_student_id': data['requester_student_id'] ?? 'N/A',
            'requested_at': data['requested_at'] as Timestamp?,
            'status': data['status'] ?? 'pending',
          });
        }
      }

      // Sort by date (newest first)
      requests.sort((a, b) {
        final timeA = a['requested_at'] as Timestamp?;
        final timeB = b['requested_at'] as Timestamp?;
        return (timeB?.compareTo(timeA ?? Timestamp.now()) ?? 0);
      });

      if (mounted) {
        setState(() {
          _pendingRequests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading requests: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateRequestStatus(
    String userDocId,
    String requestId,
    String newStatus,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userDocId)
          .collection('workplace_requests')
          .doc(requestId)
          .update({'status': newStatus});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request $newStatus successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
        _loadRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating request: $e')),
        );
      }
    }
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workplace Request Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow('Workplace:', request['workplace_name']),
              _DetailRow('Company:', request['company']),
              _DetailRow('Position:', request['position']),
              _DetailRow('Requester:', request['requester_name']),
              _DetailRow('Student ID:', request['requester_student_id']),
              _DetailRow(
                'Requested:',
                request['requested_at'] != null
                    ? (request['requested_at'] as Timestamp)
                        .toDate()
                        .toString()
                    : 'N/A',
              ),
              if (request['description'].isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(request['description']),
              ],
            ],
          ),
        ),
        actions: [
          if (request['status'] == 'pending') ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateRequestStatus(
                  request['userDocId'],
                  request['id'],
                  'rejected',
                );
              },
              child: const Text('Reject', style: TextStyle(color: AppTheme.bad)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateRequestStatus(
                  request['userDocId'],
                  request['id'],
                  'approved',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
              ),
              child: const Text(
                'Approve',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ] else
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: AppTheme.bg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusOptions.map((status) {
                  final isSelected = _filterStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: isSelected
                          ? AppTheme.primary
                          : Colors.grey.shade200,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _filterStatus = status);
                          _loadRequests();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Requests List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pendingRequests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No ${_filterStatus} requests',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _pendingRequests.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final request = _pendingRequests[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () => _showRequestDetails(request),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Header Row
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                request['workplace_name'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.head,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                request['company'],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.head2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: request['status'] ==
                                                    'approved'
                                                ? AppTheme.success
                                                    .withOpacity(0.2)
                                                : request['status'] ==
                                                        'pending'
                                                    ? Colors.orange
                                                        .withOpacity(0.2)
                                                    : Colors.red
                                                        .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            request['status'].toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: request['status'] ==
                                                      'approved'
                                                  ? AppTheme.success
                                                  : request['status'] ==
                                                          'pending'
                                                      ? Colors.orange.shade700
                                                      : Colors.red.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Requester Info
                                    Row(
                                      children: [
                                        const Icon(Icons.person,
                                            size: 14,
                                            color: AppTheme.head3),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            '${request['requester_name']} (${request['requester_student_id']})',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.head2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Position
                                    Row(
                                      children: [
                                        const Icon(Icons.work,
                                            size: 14,
                                            color: AppTheme.head3),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            request['position'],
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.head2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Action Buttons (if pending)
                                    if (request['status'] == 'pending')
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () =>
                                                  _updateRequestStatus(
                                                request['userDocId'],
                                                request['id'],
                                                'rejected',
                                              ),
                                              style:
                                                  OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    AppTheme.bad,
                                              ),
                                              child: const Text('Reject'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  _updateRequestStatus(
                                                request['userDocId'],
                                                request['id'],
                                                'approved',
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppTheme.success,
                                              ),
                                              child: const Text(
                                                'Approve',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
