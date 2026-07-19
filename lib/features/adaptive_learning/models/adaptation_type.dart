/// Types of learning adaptations the engine can recommend.
enum AdaptationType {
  increaseRevision('Increase Revision', 'More frequent review sessions'),
  decreaseRevision('Decrease Revision', 'Reduce review frequency'),
  increaseDifficulty('Increase Difficulty', 'More challenging content'),
  reduceDifficulty('Reduce Difficulty', 'Easier content'),
  moreProjects('More Projects', 'Add project-based learning'),
  fewerProjects('Fewer Projects', 'Reduce project load'),
  increaseInterviewPractice('More Interview Practice', 'Add interview preparation'),
  increaseAssessments('More Assessments', 'Increase testing frequency'),
  reorderLessons('Reorder Lessons', 'Change learning sequence'),
  adjustMissionPriority('Adjust Mission Priority', 'Change mission focus'),
  reduceWorkload('Reduce Workload', 'Lighten daily tasks'),
  increaseWorkload('Increase Workload', 'Add more daily tasks'),
  recommendReview('Recommend Review', 'Knowledge refresh needed'),
  recommendRecoveryDay('Recovery Day', 'Rest and consolidate');

  const AdaptationType(this.displayName, this.description);

  final String displayName;
  final String description;
}
