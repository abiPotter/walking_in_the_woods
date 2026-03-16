import 'package:roam_and_report/enums/vote_status.dart';

class VoteResult {
  final bool successVote;
  final bool decreaseOtherVote;
  final bool needsConfirmation;

  VoteResult(
    this.successVote,
    this.decreaseOtherVote, {
    this.needsConfirmation = false,
  });

  // Named constructor for “needs confirmation”
  VoteResult.needsConfirmation()
    : successVote = false,
      decreaseOtherVote = false,
      needsConfirmation = true;

  static VoteStatus canUserVote(
    Map<String, String> votes,
    String voteChoice,
    String userId,
  ) {
    if (!votes.containsKey(userId)) {
      //user not voted yet
      return VoteStatus.canVote;
    }
    if (votes[userId] == voteChoice) {
      return VoteStatus.cannotVote;
    }
    return VoteStatus.needsConfirmation;
  }
}
