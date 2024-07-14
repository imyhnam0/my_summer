import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'startroutinename_play.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'user_provider.dart';
import 'package:provider/provider.dart';
import 'create_routine.dart';

class PlayMyRoutinePage extends StatefulWidget {
  final String clickroutinename;
  const PlayMyRoutinePage({Key? key, required this.clickroutinename});

  @override
  State<PlayMyRoutinePage> createState() => _PlayMyRoutinePageState();
}

class _PlayMyRoutinePageState extends State<PlayMyRoutinePage> {
  TextEditingController nameController = TextEditingController();
  late String _title = widget.clickroutinename;
  List<String> collectionNames = [];
  List<Map<String, dynamic>> exercisesData = [];
  int result = 0;
  int sumweight = 0;
  int _seconds = 0;
  late Timer _timer;
  String? uid;
  List<bool> completionStatus = [];
  int totalWeight = 0; // 총 무게 상태 변수 추가
int totalRows = 0; // 총 행 수 상태 변수 추가



  @override
  void initState() {
    super.initState();
    uid = Provider.of<UserProvider>(context, listen: false).uid;
    myCollectionName();
    totalRoutineReps();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> saveRoutine(
    String title, int result, int sumweight, int timerSeconds) async {
  final DateTime now = DateTime.now();
  final String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  final db = FirebaseFirestore.instance;
  final batch = db.batch(); // Batch 쓰기 시작

  try {
    final healthDocRef =
        db.collection('users').doc(uid).collection('Calender').doc('health');

    // 새로운 문서 ID 생성
    final routineDocRef = healthDocRef.collection('routines').doc();

    batch.set(routineDocRef, {
      '오늘 한 루틴이름': title,
      '오늘 총 세트수': result,
      '오늘 총 볼륨': sumweight,
      '오늘 총 시간': _formatTime(timerSeconds),
      '날짜': formattedDate,
    });

    await batch.commit(); // Batch 쓰기 커밋
  } catch (e) {
    print('Error adding document: $e');
  }
}
Future<void> myCollectionName() async {
  try {
    // Firestore에서 데이터를 가져옵니다.
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Routine')
        .doc('Myroutine')
        .get();

    // 문서가 존재하는지 확인합니다.
    if (documentSnapshot.exists) {
      var data = documentSnapshot.data() as Map<String, dynamic>;

      // _title이 키로 존재하는지 확인합니다.
      if (data.containsKey(widget.clickroutinename)) {
        List<dynamic> myRoutineList = data[widget.clickroutinename];

        List<String> names = [];
        // 각 루틴을 순회하며 키 값을 가져옵니다.
        for (var routine in myRoutineList) {
          if (routine is Map<String, dynamic>) {
            routine.forEach((key, value) {
              names.add(key);
            });
          }
        }

        // 상태를 업데이트합니다.
        setState(() {
          collectionNames = names;
          completionStatus = List<bool>.filled(names.length, false);
        });
      }
    }
  } catch (e) {
    // 에러 발생 시 콘솔에 출력합니다.
    print('Error fetching collection names: $e');
  }
}

  Future<void> totalRoutineReps() async {
  try {
    // Firestore에서 데이터를 가져옵니다.
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Routine')
        .doc('Myroutine')
        .get();

       int tempTotalWeight = 0;
    int tempTotalRows = 0; // 총 행 수를 저장할 변수

    // 문서가 존재하는지 확인합니다.
    if (documentSnapshot.exists) {
      var data = documentSnapshot.data() as Map<String, dynamic>;

      // _title이 키로 존재하는지 확인합니다.
      if (data.containsKey(widget.clickroutinename)) {
        List<dynamic> myRoutineList = data[widget.clickroutinename];

        for (var routine in myRoutineList) {
          if (routine is Map<String, dynamic>) {
            routine.forEach((key, value) {
              if (value.containsKey('exercises')) {
                List<Map<String, dynamic>> exercises = List<Map<String, dynamic>>.from(value['exercises']
                    .map((exercise) => {
                          'reps': exercise['reps'],
                          'weight': exercise['weight'],
                        })
                    .toList());

                     tempTotalRows += exercises.length;// 총 행 수를 더합니다.

                for (var exercise in exercises) {
                  int weight = 0;
                  int reps = 0;

                  if (exercise['weight'] is int) {
                    weight = exercise['weight'];
                  } else if (exercise['weight'] is String) {
                    weight = int.tryParse(exercise['weight']) ?? 0;
                  }

                  if (exercise['reps'] is int) {
                    reps = exercise['reps'];
                  } else if (exercise['reps'] is String) {
                    reps = int.tryParse(exercise['reps']) ?? 0;
                  }

                     tempTotalWeight += weight * reps;
                }
              }
            });
          }
        }
      }
    }

       setState(() {
      totalWeight = tempTotalWeight;
      totalRows = tempTotalRows;
    });
    // 결과 출력
    print('Total weight: $totalWeight');
    print('Total rows: $totalRows'); // 총 행 수를 출력합니다.
  } catch (e) {
    // 에러 발생 시 콘솔에 출력합니다.
    print('Error fetching routine stats: $e');
  }
}

  // Future<void> myCollectionName() async {
  //   try {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(uid)
  //         .collection('Routine')
  //         .doc('Myroutine')
  //         .collection(widget.clickroutinename)
  //         .get();
  //     List<String> names = querySnapshot.docs.map((doc) => doc.id).toList();

  //     setState(() {
  //       collectionNames = names;
  //       completionStatus = List<bool>.filled(names.length, false);
  //     });
  //   } catch (e) {
  //     print('Error fetching collection names: $e');
  //   }
  // }

  // Future<void> totalRoutineReps() async {
  //   try {
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(uid)
  //         .collection('Routine')
  //         .doc('Myroutine')
  //         .collection(widget.clickroutinename)
  //         .get();

  //     int totalExercises = 0;
  //     int totalWeight = 0;

  //     for (var doc in querySnapshot.docs) {
  //       var data = doc.data() as Map<String, dynamic>;
  //       if (data.containsKey('exercises')) {
  //         exercisesData = List<Map<String, dynamic>>.from(data['exercises']
  //             .map((exercise) => {
  //                   'reps': exercise['reps'],
  //                   'weight': exercise['weight'],
  //                 })
  //             .toList());

  //         totalExercises += exercisesData.length;

  //         for (var exercise in exercisesData) {
  //           int weight = 0;
  //           int reps = 0;
  //           if (exercise['weight'] is int) {
  //             weight = exercise['weight'];
  //           } else if (exercise['weight'] is String) {
  //             weight = int.tryParse(exercise['weight']) ?? 0;
  //           }
  //           if (exercise['reps'] is int) {
  //             reps = exercise['reps'];
  //           } else if (exercise['reps'] is String) {
  //             reps = int.tryParse(exercise['reps']) ?? 0;
  //           }
  //           totalWeight +=
  //               weight * reps; // weight와 reps를 곱한 값을 totalWeight에 더합니다.
  //         }
  //       }
  //     }
  //     setState(() {
  //       result = totalExercises;
  //       sumweight = totalWeight;
  //     });
  //   } catch (e) {
  //     print('Error fetching document data: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Oswald',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade900,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.blueGrey.shade800,
                  title: const Text(
                    '진짜 종료하시겠습니까?',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    '운동을 종료하면 모든 진행 상황이 저장되지 않습니다. 계속하시겠습니까?',
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        '아니요',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const Homepage()),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        '예',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          tooltip: '뒤로 가기',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateRoutinePage(
                    myroutinename: _title,
                    clickroutinename: "",
                  ),
                ),
              ).then((value) {
                if (value == true) {
                  myCollectionName();
                }
              });
            },
            tooltip: '편집',
          ),
        ],
      ),
      body: Column(
        children: [
          Flexible(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.blueGrey.shade600,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer,
                            color: Colors.cyan.shade300, size: 30),
                        const SizedBox(width: 8),
                        Text(
                          'Exercise time: ',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Oswald',
                            color: Colors.cyan.shade300,
                            shadows: [
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatTime(_seconds),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Oswald',
                            color: Colors.cyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Sets',
                            style: const TextStyle(
                              fontSize: 25,
                              fontFamily: 'Oswald',
                              color: Colors.white70,
                            ),
                          ),


                          Text(
                            '$totalRows',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Volume',
                            style: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'Oswald',
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '$totalWeight',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.blueGrey.shade700,
                  width: 2,
                ),
              ),
              child: ListView.builder(
                itemCount: collectionNames.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 30.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(30.0),
                              backgroundColor: Colors.blueGrey.shade800,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: BorderSide(
                                  color: Colors.blueGrey.shade700,
                                  width: 2,
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StartRoutineNamePlay(
                                    currentroutinename: _title,
                                    clickroutinename: collectionNames[index],
                                  ),
                                ),
                              ).then((value) {
                                if (value == 'not done') {
                                  totalRoutineReps();
                                } else {
                                  setState(() {
                                    completionStatus[index] = true;
                                  });
                                  totalRoutineReps();
                                }
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  collectionNames[index],
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Oswald',
                                  ),
                                ),
                                if (completionStatus[index])
                                  const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 28,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey.shade800,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          alignment: Alignment.center,
          child: FloatingActionButton.extended(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.blueGrey.shade800,
                    title: const Text(
                      '운동을 종료하시겠습니까?',
                      style: TextStyle(color: Colors.white),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '아니요',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                
                          saveRoutine(
                            _title,
                            result,
                            sumweight,
                            _seconds,
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Homepage()),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          '예',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(
              Icons.mood,
              color: Colors.white,
            ),
            label: const Text(
              "완료",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Oswald',
              ),
            ),
            backgroundColor: Colors.cyan.shade700,
          ),
        ),
      ),
    );
  }
}
