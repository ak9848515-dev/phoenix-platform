/// Types of resume points the Continue Journey Engine can detect.
///
/// Each represents an activity the user left incomplete and can resume.
enum JourneyResumePoint {
  lesson('Lesson', 'Resume your lesson'),
  mission('Mission', 'Continue your mission'),
  project('Project', 'Pick up your project'),
  interview('Interview Prep', 'Resume interview practice'),
  habit('Habit', 'Complete your habit'),
  assessment('Assessment', 'Resume assessment'),
  learningPath('Learning Path', 'Continue learning path'),
  unknown('Activity', 'Resume activity');

  const JourneyResumePoint(this.displayName, this.resumeLabel);

  /// User-friendly display name.
  final String displayName;

  /// The label for the resume action button.
  final String resumeLabel;
}
