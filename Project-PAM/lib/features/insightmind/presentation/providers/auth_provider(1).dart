import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleSignInProvider = Provider((ref) => GoogleSignIn(
  scopes: ['email', 'profile'],
));

final authProvider = StateProvider<GoogleSignInAccount?>((ref) => null);