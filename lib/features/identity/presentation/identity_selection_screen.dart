import 'package:flutter/material.dart';

import '../../../shared/widgets/phoenix_primary_button.dart';
import '../../../theme/spacing.dart';
import '../models/identity.dart';
import '../services/identity_service.dart';
import '../widgets/identity_card.dart';
import '../widgets/identity_header.dart';

/// The Identity Selection Screen asks the user:
///
/// "Who do you want to become?"
///
/// This is a presentation-only screen. No business logic or engine
/// modifications are included.
class IdentitySelectionScreen extends StatelessWidget {
  const IdentitySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final identityService = const IdentityService();
    final identities = identityService.getSampleIdentities();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const IdentityHeader(),
          const SizedBox(height: AppSpacing.xl),
          ...identities.map(
            (identity) => IdentityCard(
              identity: identity,
              onSelected: () => _onIdentitySelected(context, identity),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PhoenixPrimaryButton(
            onPressed: () => _onSkip(context),
            label: 'Skip for now',
            fullWidth: true,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _onIdentitySelected(BuildContext context, Identity identity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${identity.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onSkip(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You can always choose an identity later.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}