import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'map_container.dart';

class ReportDetails {
  void showDetails(BuildContext context, Map<String, dynamic> report) {
    //open details of report
    final userid = FirebaseAuth.instance.currentUser!.uid;
    final votes = report['votes'];
    String? userVote = votes[userid];
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Report details",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline),
                        ),
                        const SizedBox(height: 16),
                        Text(report['description'] ?? '',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(children: [
                                IconButton(
                                  icon: Icon(Icons.thumb_up,
                                      color: (userVote != null &&
                                              userVote == 'likes')
                                          ? Colors.green[100]
                                          : Colors.green,
                                      size: 28),
                                  onPressed: () async {
                                    final voteResult = await voteReport(
                                        report, 'likes', context);
                                    if (voteResult.successVote) {
                                      setModalState(() {
                                        report['likes']++;
                                        if (voteResult.decreaseOtherVote) {
                                          report['dislikes']--;
                                        }
                                        report['votes'][userid] = 'likes';
                                        userVote = 'likes';
                                      });
                                    }
                                  },
                                ),
                                Text(report['likes'].toString())
                              ]),
                              Column(children: [
                                IconButton(
                                  icon: Icon(Icons.thumb_down,
                                      color: (userVote != null &&
                                              userVote == 'dislikes')
                                          ? Colors.red[100]
                                          : Colors.red,
                                      size: 28),
                                  onPressed: () async {
                                    final voteResult = await voteReport(
                                        report, 'dislikes', context);
                                    if (voteResult.successVote) {
                                      setModalState(() {
                                        report['dislikes']++;
                                        if (voteResult.decreaseOtherVote) {
                                          report['likes']--;
                                        }
                                        report['votes'][userid] = 'dislikes';
                                        userVote = 'dislikes';
                                      });
                                    }
                                  },
                                ),
                                Text(report['dislikes'].toString()),
                              ]),
                            ]),
                        SizedBox(height: 8),
                        Text(report['location text']),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: double.infinity,
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: MapContainer(
                                  showReportsToggle: false,
                                  showSearchBar: false,
                                  showRecentre: false,
                                  initialLocation: LatLng(
                                      report['latitude'], report['longitude']),
                                ))),
                        SizedBox(height: 12),
                        Text(
                            (report['long description'] == null ||
                                    report['long description']
                                        .toString()
                                        .trim()
                                        .isEmpty)
                                ? '(No further details provided)'
                                : report['long description'],
                            style: TextStyle(
                                fontSize: 14, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Reported on: ',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: report['date']
                                    .toDate()
                                    .toString()
                                    .split(' ')[0],
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Status: ',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: report['status'].split('.')[1],
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Photos: ',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        report['photos'] != null && report['photos']!.isNotEmpty
                            ? SizedBox(
                                height: 100,
                                child: GridView.builder(
                                  itemCount: report['photos']?.length ?? 0,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 4,
                                    mainAxisSpacing: 4,
                                  ),
                                  itemBuilder: (context, index) {
                                    return Image.network(
                                      report['photos'][index],
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              )
                            : Text("No images added",
                                style: TextStyle(
                                    fontSize: 14, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ]),
            );
          },
        );
      },
    );
  }

  static String getOppositeVote(voteChoice) {
    if (voteChoice == 'likes') {
      return 'dislikes';
    } else {
      return 'likes';
    }
  }

  static Future<VoteResult> voteReport(Map<String, dynamic> report,
      String voteChoice, BuildContext context) async {
    final userid = FirebaseAuth.instance.currentUser!.uid;

    final votes = report['votes'];
    if (votes.containsKey(userid)) {
      //already voted
      if (votes[userid] == voteChoice) {
        //voted with same vote as before
        return VoteResult(false, false);
      } else {
        //voted with different vote to before
        final replaceVote = await checkUserWantsToChangeVote(context);
        if (!replaceVote) {
          return VoteResult(false, false);
        }
        votes[userid] = voteChoice;
        final oppositeVote = getOppositeVote(voteChoice);
        await FirebaseFirestore.instance
            .collection('reports')
            .doc(report['id'])
            .update({
          voteChoice: FieldValue.increment(1),
          'votes': votes,
          oppositeVote: FieldValue.increment(-1)
        });
        return VoteResult(true, true);
      }
    }

    //not voted on this report before
    votes[userid] = voteChoice;
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(report['id'])
        .update({voteChoice: FieldValue.increment(1), 'votes': votes});

    return VoteResult(true, false);
  }

  static Future<bool> checkUserWantsToChangeVote(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Change your vote"),
            content: const Text(
                "You have already voted on this report. Do you want to change your vote?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("No, cancel")),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Yes, change it")),
            ],
          ),
        ) ??
        false;
  }
}

class VoteResult {
  final bool successVote;
  final bool decreaseOtherVote;

  VoteResult(this.successVote, this.decreaseOtherVote);
}
