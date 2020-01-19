import 'package:google_sign_in/google_sign_in.dart';

class Constants {
  static const String OpenDeck = 'Open Deck';
  static const String SingIn = 'Sign In';
  static const String NewOrganization = 'New Organization';
  static const String SignOut = 'Sign Out';
  static const String ManageUsers = 'Manage Users';
  static const String GetOrganizationDeck = 'Load organization deck';

  static List<String> buildChoices(GoogleSignInAccount account, bool isAdmin) {
    List<String> choices = <String>[
      Constants.OpenDeck,
      Constants.NewOrganization,
    ];
    if (account != null) {
      choices.add(Constants.SignOut);
      choices.add(Constants.GetOrganizationDeck);
    } else {
      choices.add(Constants.SingIn);
    }
    if(isAdmin){
      choices.add(ManageUsers);
    }
    return choices;
  }
}
