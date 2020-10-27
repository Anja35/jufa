import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:jufa/service/AuthService.dart';

import 'BackendService.dart';

class DynamicLinkService {
  static Future<String> createOrganizerLink() async {
    var parameters = DynamicLinkParameters(
        uriPrefix: "https://jufa.page.link",
        androidParameters: AndroidParameters(packageName: "de.schultek.jufa"),
        link: Uri.parse("https://jufa20.web.app/?isOrganizer=yes"));
    final Uri dynamicUrl = await parameters.buildUrl();
    return dynamicUrl.toString();
  }

  static Future<String> createParticipantLink(String tripId) async {
    var parameters = DynamicLinkParameters(
        uriPrefix: "https://jufa.page.link",
        androidParameters: AndroidParameters(packageName: "de.schultek.jufa"),
        link: Uri.parse("https://jufa20.web.app/?isParticipant=yes&tripId=$tripId"));
    final ShortDynamicLink dynamicUrl = await parameters.buildShortLink();
    return dynamicUrl.shortUrl.toString();
  }

  static Future<String> createLeaderLink(String tripId) async {
    var parameters = DynamicLinkParameters(
        uriPrefix: "https://jufa.page.link",
        androidParameters: AndroidParameters(packageName: "de.schultek.jufa"),
        link: Uri.parse("https://jufa20.web.app/?isLeader=yes&tripId=$tripId"));
    final ShortDynamicLink dynamicUrl = await parameters.buildShortLink();
    return dynamicUrl.shortUrl.toString();
  }

  static void handleDynamicLinks() async {
    // TODO: remove this line
    print(await DynamicLinkService.createOrganizerLink());

    var link = await FirebaseDynamicLinks.instance.getInitialLink();
    if (link != null) {
      _handleDynamicLink(link);
    }

    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData link) async {
      _handleDynamicLink(link);
    });
  }

  static void _handleDynamicLink(PendingDynamicLinkData link) async {
    var queryParameters = link.link.queryParameters;
    print(queryParameters);
    if (queryParameters.containsKey("isOrganizer")) {
      if (queryParameters["isOrganizer"] == "yes") {
        await BackendService.updateUserRole(UserRoles.Organizer);
      }
    }
    if (queryParameters.containsKey("isParticipant")) {
      if (queryParameters["isParticipant"] == "yes") {
        await BackendService.updateUserRole(UserRoles.Participant);
        await BackendService.addUserToTrip(queryParameters["tripId"]);
        await AuthService.instance.updateUserRole();
      }
    }
    if (queryParameters.containsKey("isLeader")) {
      if (queryParameters["isLeader"] == "yes") {
        await BackendService.updateUserRole(UserRoles.Leader);
        await BackendService.addUserToTrip(queryParameters["tripId"]);
        await AuthService.instance.updateUserRole();
      }
    }
  }
}
