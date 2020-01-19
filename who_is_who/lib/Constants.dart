import 'package:google_sign_in/google_sign_in.dart';

class Constants {
  static const String OpenDeck = 'Open Deck';
  static const String SingIn = 'Sign In';
  static const String NewOrganization = 'New Organization';
  static const String SignOut = 'Sign Out';
  static const String ManageUsers = 'Manage Users';

  static List<String> buildChoices(GoogleSignInAccount account) {
    List<String> choices = <String>[
      Constants.OpenDeck,
      Constants.NewOrganization,
      Constants.ManageUsers
    ];
    if (account != null) {
      choices.add(Constants.SignOut);
    } else {
      choices.add(Constants.SingIn);
    }
    return choices;
  }
}
