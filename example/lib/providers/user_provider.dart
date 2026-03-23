import 'package:riverpod_craft/riverpod_craft.dart';

part 'user_provider.craft.dart';

@provider
class User extends _$User {
  @override
  Future<UserModel> create() async => fetchUserModel();
}

UserModel fetchUserModel() {
  return UserModel(userId: '', uuid: '', fullName: '');
}

class UserModel {
  UserModel({required this.userId, required this.uuid, required this.fullName});

  final String userId;
  final String uuid;
  final String fullName;
}
