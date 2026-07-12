import 'package:flutter/material.dart';

import '../models/identity.dart';

/// Provides a curated list of sample identities for the user to choose from.
///
/// This is a presentation-only service. No business logic or engine
/// modifications are included.
class IdentityService {
  const IdentityService();

  /// Returns the full list of available sample identities.
  List<Identity> getSampleIdentities() => const <Identity>[
    Identity(
      id: 'identity-software-engineer',
      title: 'Software Engineer',
      description:
          'Design, build, and maintain scalable software systems '
          'that solve real-world problems.',
      icon: Icons.code_outlined,
      category: 'Technology',
      currentLevel: 1,
      targetLevel: 8,
      estimatedDuration: 730,
      requiredSkills: <String>[
        'Data Structures & Algorithms',
        'System Design',
        'Clean Architecture',
        'Version Control',
      ],
      roadmap: <String>[
        'Master a programming language',
        'Build your first full-stack app',
        'Contribute to open source',
        'Architect distributed systems',
      ],
      status: IdentityStatus.available,
    ),
    Identity(
      id: 'identity-sap-consultant',
      title: 'SAP Consultant',
      description:
          'Help enterprises optimise their business processes using '
          'SAP modules and best practices.',
      icon: Icons.business_outlined,
      category: 'Business',
      currentLevel: 1,
      targetLevel: 7,
      estimatedDuration: 600,
      requiredSkills: <String>[
        'SAP FICO / MM / SD',
        'Business Process Mapping',
        'ABAP Basics',
        'Client Communication',
      ],
      roadmap: <String>[
        'Complete SAP Fundamentals',
        'Specialise in one module',
        'Lead a greenfield implementation',
        'Obtain SAP Certification',
      ],
      status: IdentityStatus.available,
    ),
    Identity(
      id: 'identity-flutter-developer',
      title: 'Flutter Developer',
      description:
          'Craft beautiful, performant cross-platform applications '
          'with Flutter and Dart.',
      icon: Icons.phone_android_outlined,
      category: 'Technology',
      currentLevel: 1,
      targetLevel: 7,
      estimatedDuration: 400,
      requiredSkills: <String>[
        'Dart Language',
        'Flutter Widgets',
        'State Management',
        'Platform Integrations',
      ],
      roadmap: <String>[
        'Learn Dart fundamentals',
        'Build a simple Flutter app',
        'Master state management',
        'Publish to App Store & Play Store',
      ],
      status: IdentityStatus.available,
    ),
    Identity(
      id: 'identity-content-creator',
      title: 'Content Creator',
      description:
          'Produce engaging digital content that educates, entertains, '
          'and inspires your audience.',
      icon: Icons.edit_outlined,
      category: 'Creative',
      currentLevel: 1,
      targetLevel: 6,
      estimatedDuration: 365,
      requiredSkills: <String>[
        'Writing & Storytelling',
        'Video Editing',
        'SEO Fundamentals',
        'Audience Growth',
      ],
      roadmap: <String>[
        'Define your niche',
        'Create 10 pieces of content',
        'Build an audience of 1,000',
        'Monetise your content',
      ],
      status: IdentityStatus.available,
    ),
    Identity(
      id: 'identity-influencer',
      title: 'Influencer',
      description:
          'Build a personal brand and influence your community across '
          'social media platforms.',
      icon: Icons.person_outlined,
      category: 'Creative',
      currentLevel: 1,
      targetLevel: 6,
      estimatedDuration: 365,
      requiredSkills: <String>[
        'Personal Branding',
        'Social Media Strategy',
        'Photography & Videography',
        'Community Management',
      ],
      roadmap: <String>[
        'Define your personal brand',
        'Grow to 5,000 followers',
        'Collaborate with 5 brands',
        'Build a sustainable income',
      ],
      status: IdentityStatus.available,
    ),
    Identity(
      id: 'identity-entrepreneur',
      title: 'Entrepreneur',
      description:
          'Identify opportunities, build ventures, and create value '
          'through innovation and leadership.',
      icon: Icons.rocket_launch_outlined,
      category: 'Business',
      currentLevel: 1,
      targetLevel: 8,
      estimatedDuration: 730,
      requiredSkills: <String>[
        'Business Modelling',
        'Product-Market Fit',
        'Fundraising',
        'Team Leadership',
      ],
      roadmap: <String>[
        'Validate a business idea',
        'Launch an MVP',
        'Raise seed funding',
        'Scale to 10+ team members',
      ],
      status: IdentityStatus.available,
    ),
    Identity(
      id: 'identity-business-owner',
      title: 'Business Owner',
      description:
          'Run and grow a profitable business while building a strong '
          'team and operational foundation.',
      icon: Icons.store_outlined,
      category: 'Business',
      currentLevel: 1,
      targetLevel: 7,
      estimatedDuration: 540,
      requiredSkills: <String>[
        'Financial Management',
        'Operations & Logistics',
        'Marketing & Sales',
        'People Management',
      ],
      roadmap: <String>[
        'Write a business plan',
        'Register and launch',
        'Hire your first employee',
        'Achieve profitability',
      ],
      status: IdentityStatus.available,
    ),
    Identity(
      id: 'identity-student',
      title: 'Student',
      description:
          'Excel in your academic journey while building skills that '
          'prepare you for a successful career.',
      icon: Icons.school_outlined,
      category: 'Education',
      currentLevel: 1,
      targetLevel: 5,
      estimatedDuration: 300,
      requiredSkills: <String>[
        'Time Management',
        'Critical Thinking',
        'Research & Analysis',
        'Exam Strategy',
      ],
      roadmap: <String>[
        'Set academic goals',
        'Build effective study habits',
        'Complete a major project',
        'Graduate with distinction',
      ],
      status: IdentityStatus.available,
    ),
    Identity(
      id: 'identity-custom',
      title: 'Custom Identity',
      description:
          'Define your own path. Create a personalised identity '
          'tailored to your unique goals and aspirations.',
      icon: Icons.add_circle_outlined,
      category: 'General',
      currentLevel: 1,
      targetLevel: 5,
      estimatedDuration: 0,
      requiredSkills: <String>[],
      roadmap: <String>[
        'Define your vision',
        'Set your milestones',
        'Start your journey',
      ],
      status: IdentityStatus.available,
    ),
  ];

  /// Returns identities filtered by a specific category.
  List<Identity> getIdentitiesByCategory(String category) =>
      getSampleIdentities()
          .where((identity) => identity.category == category)
          .toList();

  /// Returns an identity by its unique id, or null if not found.
  Identity? getIdentityById(String id) {
    try {
      return getSampleIdentities().firstWhere((identity) => identity.id == id);
    } catch (_) {
      return null;
    }
  }
}