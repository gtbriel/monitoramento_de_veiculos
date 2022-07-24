import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  Map<String, dynamic> data_atual = {};
  late VideoPlayerController _controller;
  late String hash_atual;
  late FToast fToast;
  bool _haveVideo = false;
  bool _haveData = false;

  @override
  void initState() {
    super.initState();
    _haveData = false;
    fToast = FToast();
    fToast.init(context);
    getFirstDoc();
  }

  getFirstDoc() async {
    await FirebaseFirestore.instance
        .collection('users')
        .limit(1)
        .get()
        .then((querySnapshot) => {
              initializeVideo(querySnapshot.docs[0].id),
              data_atual = querySnapshot.docs[0].data(),
              hash_atual = querySnapshot.docs[0].id,
              _haveData = true
            });
  }

  _showToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.grey,
      ),
      child: Text(
        msg,
        style: const TextStyle(color: Colors.white),
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 5),
    );
  }

  Future<String?> getDownloadURL(String fileId) async {
    try {
      String downloadURL = await storage.ref(fileId).getDownloadURL();
      return downloadURL;
    } catch (e) {
      return null;
    }
  }

  getCurrentColor(Map<String, dynamic> data) {
    if (data['acidente'] == true && data['atendimento'] == false) {
      return Colors.redAccent;
    } else if (data['acidente'] == false) {
      return Colors.greenAccent;
    } else if (data['acidente'] == true && data['atendimento'] == true) {
      return Colors.orangeAccent;
    } else {
      return Colors.black;
    }
  }

  initializeVideo(String str) async {
    var value = await getDownloadURL(str + ".mp4");
    if (value != null) {
      _controller = VideoPlayerController.network(value)
        ..initialize().then((_) {
          _controller.play();
          _controller.setLooping(true);
          _haveVideo = true;
          setState(() {});
        });
    } else {
      _haveVideo = false;
      setState(() {});
    }
  }

  updateByHash(String hash, Map<String, dynamic> info) {
    var document = FirebaseFirestore.instance.collection('users').doc(hash);
    document.update(info);
  }

  @override
  Widget build(BuildContext context) {
    displayVideo(Map<String, dynamic> data_atual) {
      if (_haveVideo && data_atual['acidente'] == true) {
        return Container(
          padding:
              const EdgeInsets.only(top: 10, left: 50, right: 50, bottom: 20),
          child: GestureDetector(
            onTap: () {},
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
        );
      } else {
        return Container(
          padding:
              const EdgeInsets.only(top: 10, left: 50, right: 50, bottom: 200),
          child: GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Image.asset('assets/images/logo.png', scale: 3),
                const SizedBox(
                  height: 30,
                ),
                const Text("Video not available..."),
              ],
            ),
          ),
        );
      }
    }

    Widget buildInfos(Map<String, dynamic> data_atual) {
      if (data_atual.isNotEmpty) {
        return SingleChildScrollView(
          controller: ScrollController(),
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "Ultimas informações:",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  data_atual['velocidade'].toString() != 'null'
                      ? "Velocidade: " + data_atual['velocidade'].toString()
                      : "Velocidade: ",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  data_atual['aceleracao'].toString() != 'null'
                      ? "Aceleração: " + data_atual['aceleracao'].toString()
                      : "Aceleração: ",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Informações do Cliente:",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Nome Completo: " + data_atual['nome'].toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Documento: " + data_atual['identidade'].toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Veículo: " +
                      data_atual['modelo_veiculo'] +
                      " - " +
                      data_atual['placa_veiculo'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Plano: " + data_atual['tipo_plano'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 15,
                )
              ],
            ),
          ),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        );
      }
    }

    Widget renderCallButton(Map<String, dynamic> data_atual) {
      if (data_atual['atendimento'] == true) {
        return MaterialButton(
          minWidth: MediaQuery.of(context).size.height - 800,
          height: 60,
          onPressed: () {
            updateByHash(hash_atual,
                <String, dynamic>{"atendimento": false, "acidente": false});
            _haveVideo = false;
          },
          color: getCurrentColor(data_atual),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: const Text(
            "Encerrar chamado",
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white70),
          ),
        );
      } else if (data_atual['acidente'] == true &&
          data_atual['atendimento'] == false) {
        return MaterialButton(
          minWidth: MediaQuery.of(context).size.height - 800,
          height: 60,
          onPressed: () {
            updateByHash(hash_atual, <String, dynamic>{"atendimento": true});
          },
          color: getCurrentColor(data_atual),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: const Text(
            "Responder chamado",
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white70),
          ),
        );
      } else {
        return Container();
      }
    }

    Widget buildHelpIcons(Map<String, dynamic> data_atual) {
      if (data_atual.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Entrar em contato:",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    child:
                        Image.asset('assets/images/ambulancia.jpg', scale: 9),
                    onTap: () {
                      _showToast(
                          "Ligando para emergência, fique disponível na linha.");
                    },
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  InkWell(
                    child: Image.asset('assets/images/telefone.png', scale: 7),
                    onTap: () {},
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  InkWell(
                    child: Image.asset('assets/images/wpp.png', scale: 11),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              renderCallButton(data_atual)
            ],
          ),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.black,
          ),
        );
      }
    }

    if (_haveData == true) {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: (() {
            initializeVideo(hash_atual);
          }),
          child: Icon(Icons.refresh),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 30, top: 50),
                      child: ListView(
                        controller: ScrollController(),
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                              var data_item =
                                  document.data()! as Map<String, dynamic>;
                              String ultima_loc =
                                  data_item['localizacao'] == 'null'
                                      ? data_item['localizacao']
                                      : "Não disponível";
                              String ultima_att = data_item['datetime']
                                          .seconds !=
                                      null
                                  ? DateTime.fromMillisecondsSinceEpoch(
                                          data_item['datetime'].seconds * 1000)
                                      .toString()
                                  : "Não disponível";

                              return InkWell(
                                onTap: () async {
                                  data_atual = data_item;
                                  hash_atual = document.id;
                                  initializeVideo(document.id);
                                },
                                splashColor: getCurrentColor(data_item),
                                splashFactory: InkRipple.splashFactory,
                                child: Card(
                                  child: ClipPath(
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              left: BorderSide(
                                                  color: getCurrentColor(
                                                      data_item),
                                                  width: 5))),
                                      child: ListTile(
                                        title: Text(
                                          data_item['nome'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text("Última atualização: " +
                                                ultima_att),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text("Última localização: " +
                                                ultima_loc),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })
                            .toList()
                            .cast(),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(50),
                    color: Colors.white70,
                    height: MediaQuery.of(context).size.height - 100,
                    width: MediaQuery.of(context).size.width - 500,
                    child: SingleChildScrollView(
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(hash_atual)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<
                                      DocumentSnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.hasData) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  displayVideo(snapshot.data!.data()
                                      as Map<String, dynamic>),
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: Container(
                                            height: 350,
                                            width: 400,
                                            margin: const EdgeInsets.only(
                                                bottom:
                                                    6.0), //Same as `blurRadius` i guess
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              color: Colors.white,
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  offset:
                                                      Offset(0.0, 1.0), //(x,y)
                                                  blurRadius: 6.0,
                                                ),
                                              ],
                                            ),
                                            child: buildInfos(
                                                snapshot.data!.data()
                                                    as Map<String, dynamic>)),
                                      ),
                                      const SizedBox(
                                        width: 50,
                                      ),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: Container(
                                          height: 350,
                                          width: 400,
                                          margin: const EdgeInsets.only(
                                              bottom:
                                                  6.0), //Same as `blurRadius` i guess
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            color: Colors.white,
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.grey,
                                                offset:
                                                    Offset(0.0, 1.0), //(x,y)
                                                blurRadius: 6.0,
                                              ),
                                            ],
                                          ),
                                          child: buildHelpIcons(snapshot.data!
                                              .data() as Map<String, dynamic>),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              );
                            } else {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text("Loading information...",
                                      style: TextStyle(fontSize: 28)),
                                ],
                              );
                            }
                          }),
                    ),
                  ),
                ],
              );
            }),
      );
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              CircularProgressIndicator(
                color: Colors.blue,
              ),
              SizedBox(
                height: 30,
              ),
              Text("Loading information...", style: TextStyle(fontSize: 28)),
            ],
          ),
        ),
      );
    }
  }
}
