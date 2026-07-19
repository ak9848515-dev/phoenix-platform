/// All AI capabilities supported by Phoenix.
///
/// Each capability maps to one or more provider strategies.
/// The [AICapabilityRouter] uses this to determine the best provider.
enum AICapability {
  coding('Coding', 'Code generation and debugging'),
  learning('Learning', 'Learning path and content generation'),
  career('Career', 'Career advice and planning'),
  resume('Resume', 'Resume building and optimization'),
  interview('Interview', 'Interview preparation and practice'),
  research('Research', 'Deep research and analysis'),
  writing('Writing', 'Content and document writing'),
  reasoning('Reasoning', 'Complex reasoning and problem solving'),
  planning('Planning', 'Task and project planning'),
  image('Image', 'Image generation and analysis'),
  vision('Vision', 'Image and video understanding'),
  speech('Speech', 'Speech-to-text and text-to-speech'),
  translation('Translation', 'Language translation'),
  summarization('Summarization', 'Content summarization'),
  generalChat('General Chat', 'Open-ended conversation');

  const AICapability(this.displayName, this.description);

  /// Human-readable name.
  final String displayName;

  /// Short description of what this capability does.
  final String description;
}
