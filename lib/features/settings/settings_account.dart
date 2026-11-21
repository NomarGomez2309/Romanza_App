import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AccountStatus { signedOut, loading, ready, error }

enum PartnerStatus { none, loading, linked, error }

class SettingsAccount {
  const SettingsAccount({
    this.status = AccountStatus.signedOut,
    this.name,
    this.photoUrl,
    this.partnerStatus = PartnerStatus.none,
    this.partnerName,
    this.partnerPhotoUrl,
  });
  final AccountStatus status;
  final String? name, photoUrl, partnerName, partnerPhotoUrl;
  final PartnerStatus partnerStatus;
}

/// Reads the existing profile schema without changing membership or permissions.
/// A denied partner-profile read is an error, never an unlinked state.
class SettingsAccountSubscription {
  SettingsAccountSubscription(this.onChanged) {
    _auth = FirebaseAuth.instance.authStateChanges().listen(
      _userChanged,
      onError: (Object _) {
        ++_generation;
        ++_linkGeneration;
        _profile?.cancel();
        _couple?.cancel();
        _partner?.cancel();
        onChanged(
          const SettingsAccount(
            status: AccountStatus.error,
            partnerStatus: PartnerStatus.error,
          ),
        );
      },
    );
  }
  final void Function(SettingsAccount) onChanged;
  StreamSubscription<User?>? _auth;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profile,
      _couple,
      _partner;
  int _generation = 0;
  int _linkGeneration = 0;
  int _partnerGeneration = 0;

  void _userChanged(User? user) {
    final generation = ++_generation;
    ++_linkGeneration;
    ++_partnerGeneration;
    _profile?.cancel();
    _couple?.cancel();
    _partner?.cancel();
    if (user == null) {
      onChanged(const SettingsAccount());
      return;
    }
    onChanged(
      const SettingsAccount(
        status: AccountStatus.loading,
        partnerStatus: PartnerStatus.loading,
      ),
    );
    _profile = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen(
          (snapshot) {
            if (generation != _generation) return;
            final linkGeneration = ++_linkGeneration;
            _couple?.cancel();
            _partner?.cancel();
            final data = snapshot.data() ?? {};
            final name = _text(data['name']) ?? _text(user.displayName);
            final photo = _text(data['photoUrl']) ?? _text(user.photoURL);
            void emit(
              PartnerStatus status, {
              String? partnerName,
              String? partnerPhoto,
            }) {
              if (generation != _generation ||
                  linkGeneration != _linkGeneration) {
                return;
              }
              onChanged(
                SettingsAccount(
                  status: AccountStatus.ready,
                  name: name,
                  photoUrl: photo,
                  partnerStatus: status,
                  partnerName: partnerName,
                  partnerPhotoUrl: partnerPhoto,
                ),
              );
            }

            final coupleId = _text(data['coupleId']);
            if (!snapshot.exists && snapshot.metadata.isFromCache) {
              emit(PartnerStatus.loading);
              return;
            }
            if (coupleId == null) {
              emit(PartnerStatus.none);
              return;
            }
            emit(PartnerStatus.loading);
            _couple = FirebaseFirestore.instance
                .collection('couples')
                .doc(coupleId)
                .snapshots()
                .listen((couple) {
                  if (generation != _generation ||
                      linkGeneration != _linkGeneration) {
                    return;
                  }
                  _partner?.cancel();
                  final partnerGeneration = ++_partnerGeneration;
                  final record = couple.data();
                  if (record == null) {
                    emit(
                      couple.metadata.isFromCache
                          ? PartnerStatus.loading
                          : PartnerStatus.error,
                    );
                    return;
                  }
                  final rawMembers = record['members'];
                  final members = rawMembers is List
                      ? rawMembers.whereType<String>().toList()
                      : <String>[];
                  if (!members.contains(user.uid)) {
                    emit(PartnerStatus.error);
                    return;
                  }
                  final others = members
                      .where((uid) => uid != user.uid)
                      .toList();
                  if (others.isEmpty && record['status'] == 'pending') {
                    emit(PartnerStatus.none);
                    return;
                  }
                  if (others.length != 1 || record['status'] != 'active') {
                    emit(PartnerStatus.error);
                    return;
                  }
                  emit(PartnerStatus.loading);
                  _partner = FirebaseFirestore.instance
                      .collection('users')
                      .doc(others.single)
                      .snapshots()
                      .listen(
                        (partner) {
                          if (partnerGeneration != _partnerGeneration) return;
                          final profile = partner.data();
                          final partnerName = _text(profile?['name']);
                          if (partnerName == null) {
                            emit(PartnerStatus.error);
                            return;
                          }
                          emit(
                            PartnerStatus.linked,
                            partnerName: partnerName,
                            partnerPhoto: _text(profile?['photoUrl']),
                          );
                        },
                        onError: (Object _) {
                          if (partnerGeneration == _partnerGeneration) {
                            emit(PartnerStatus.error);
                          }
                        },
                      );
                }, onError: (Object _) => emit(PartnerStatus.error));
          },
          onError: (Object _) {
            if (generation != _generation) return;
            ++_linkGeneration;
            _couple?.cancel();
            _partner?.cancel();
            onChanged(
              SettingsAccount(
                status: AccountStatus.error,
                name: user.displayName,
                photoUrl: user.photoURL,
                partnerStatus: PartnerStatus.error,
              ),
            );
          },
        );
  }

  static String? _text(Object? value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;
  void dispose() {
    ++_generation;
    ++_linkGeneration;
    ++_partnerGeneration;
    _auth?.cancel();
    _profile?.cancel();
    _couple?.cancel();
    _partner?.cancel();
  }
}
