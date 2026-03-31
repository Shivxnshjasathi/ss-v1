import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoutingUtils {
  /// Map a user role to its corresponding application route.
  static String getRouteByRole(String? role) {
    if (role == null) return '/home';
    
    switch (role.toLowerCase()) {
      case 'builder / agent':
      case 'builderAgent':
        return '/provider/builder';
      case 'construction partner':
      case 'constructionPartner':
        return '/provider/construction';
      case 'legal advisor':
      case 'legalAdvisor':
        return '/provider/legal';
      case 'material vendor':
      case 'materialVendor':
        return '/provider/marketplace';
      case 'loan / emi expert':
      case 'loanexpert':
      case 'loanExpert':
        return '/provider/finance';
      case 'packersmovers':
      case 'packersMovers':
        return '/provider/movers';
      default:
        return '/home';
    }
  }

  /// Perform navigation based on the user's role.
  static void navigateByRole(BuildContext context, String? role) {
    final route = getRouteByRole(role);
    context.go(route);
  }
}
