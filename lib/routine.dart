import 'package:flutter/material.dart';
import 'create_routine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  TextEditingController nameController = TextEditingController();
  String _title = '';
  List<String> collectionNames = [];

  @override
  void initState() {
    super.initState();
    myCollectionName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNameInputDialog(context);
    });
  }

  void deleteData(String documentId) async {
    try {
      // 문서 삭제
      await FirebaseFirestore.instance
          .collection("Routine")
          .doc('Myroutine')
          .collection(nameController.text)
          .doc(documentId)
          .delete();
      myCollectionName();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  void deleteCollection(String collectionPath) async {
    try {
      // 해당 컬렉션의 모든 문서를 가져옴
      var collectionRef = FirebaseFirestore.instance
          .collection("Routine")
          .doc('Myroutine')
          .collection(collectionPath);

      var snapshots = await collectionRef.get();

      // 모든 문서를 개별적으로 삭제
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }

      // 추가적으로 컬렉션의 문서가 모두 삭제됐는지 확인하고, 필요에 따라 추가 작업 수행
      myCollectionName();
    } catch (e) {
      print('Error deleting collection: $e');
    }
  }

  void myCollectionName() async {
    try {
      // 내루틴 가져오기
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Routine')
          .doc('Myroutine')
          .collection(nameController.text)
          .get();
      List<String> names = querySnapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        collectionNames = names;
      });
    } catch (e) {
      print('Error fetching collection names: $e');
    }
  }

  void _showNameInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 39, 34, 34),
          title: Text(
            'My routine name',
            style: TextStyle(color: Colors.red),
          ),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "이름을 입력하세요",
              hintStyle: TextStyle(color: Colors.grey), // 힌트 텍스트 색상
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red), // 기본 상태의 밑줄 색상
              ),
              fillColor: Colors.white, // 텍스트 필드 배경 색상
              filled: true,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                '취소',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                '확인',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                setState(() {
                  _title = nameController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void saveRoutineName() async {
    var db = FirebaseFirestore.instance;

    if (nameController.text.isNotEmpty) {
      try {
        await db
            .collection('Routine')
            .doc('Routinename')
            .collection('Names')
            .add({'name': nameController.text});
        // 지정한 ID로 문서 참조 후 데이터 저장
      } catch (e) {
        print('Error adding document: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: TextStyle(
            color: Color.fromARGB(255, 243, 8, 8),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 17, 6, 6),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('정말 나가시겠습니까?'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('아니오'),
                      onPressed: () {
                        Navigator.of(context).pop(); // 팝업 닫기
                      },
                    ),
                    TextButton(
                      child: Text('예'),
                      onPressed: () {
                        deleteCollection(nameController.text);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('저장하시겠습니까?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('아니오'),
                            onPressed: () {
                              Navigator.of(context).pop(); // 팝업 닫기
                            },
                          ),
                          TextButton(
                            child: Text('예'),
                            onPressed: () {
                              Navigator.of(context).pop(); // 확인 팝업 닫기
                              saveRoutineName();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('저장되었습니다'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('확인'),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // 저장 완료 팝업 닫기
                                          Navigator.of(context)
                                              .pop(); // 이전 화면으로 이동
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: ListView.builder(
            itemCount: collectionNames.length,
            itemBuilder: (context, index) {
              String collectionName = collectionNames[index];

              return Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 30.0), // 좌우 여백 추가
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(25.0),
                          backgroundColor:
                              Color.fromARGB(255, 39, 34, 34), // 배경 색상
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15.0), // 둥근 모서리 반경 설정
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateRoutinePage(
                                myroutinename: _title,
                                clickroutinename: collectionNames[index],
                              ),
                            ),
                          ).then((value) {
                            if (value == true) {
                              myCollectionName();
                            }
                            if (value == false) {
                              deleteData(collectionNames[index]);
                            }
                          });
                        },
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween, // 아이템 간의 공간을 최대화
                          children: [
                            Text(
                              collectionName,
                              style:
                                  TextStyle(fontSize: 18.0, color: Colors.red),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                deleteData(collectionName);
                              },
                            ), // 오른쪽 끝에 아이콘
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton.extended(
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
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: Text(
          "생성",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 199, 25, 19),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
