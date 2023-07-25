import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kplayer/kplayer.dart';
// import 'package:kplayer_with_audioplayers/kplayer_with_audioplayers.dart';

// StreamController for isDarkMode
final isDarkMode = ValueNotifier(true);
void main() {
  Player.boot();
  runApp(
    ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, snapshot, w) {
        return MaterialApp(
          themeMode: isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: isDarkMode.value ? Brightness.dark : Brightness.light,
          ),
          darkTheme: ThemeData.dark(),
          home: const MyApp(),
        );
      },
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var player = Player.create(
      media: PlayerMedia.network("https://physia.github.io/kflutter/kplayer/online_example/assets/assets/Introducing_flutter.mp3"), autoPlay: true)
    ..init();
  final _loadFromNetworkController =
      TextEditingController(text: "https://physia.github.io/kflutter/kplayer/online_example/assets/assets/Introducing_flutter.mp3");
  final _loadFromAssetController = TextEditingController(text: "assets/Introducing_flutter.mp3");
  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
    player.dispose();
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('KPlayer'),
        // add action to open Github page
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.open_in_new), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Load from network"),
            subtitle: TextField(
              controller: _loadFromNetworkController,
              decoration: const InputDecoration(hintText: "URL of the media to load"),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                setState(() {
                  player.dispose();
                  player = Player.create(
                    media: PlayerMedia.network("https://physia.github.io/kflutter/kplayer/online_example/assets/assets/Introducing_flutter.mp3"),
                    autoPlay: true,
                  )..init();
                });
              },
            ),
          ),
          const Divider(),
          // load from Assets
          ListTile(
            leading: const Icon(Icons.audiotrack),
            title: const Text("Load from assets"),
            subtitle: TextField(
              controller: _loadFromAssetController,
              decoration: const InputDecoration(hintText: "assets path"),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                setState(() {
                  player.dispose();
                  for (var player in PlayerController.palyers) {
                    player.pause();
                  }
                  player = Player.create(
                    media: PlayerMedia.asset(_loadFromAssetController.text),
                    autoPlay: true,
                  )..init();
                });
              },
            ),
          ),
          const Divider(),
          // use file picker to load from file
          Opacity(
            opacity: PlatformEnv.isWeb ? 0.3 : 1,
            child: IgnorePointer(
              ignoring: PlatformEnv.isWeb,
              child: ListTile(
                leading: const Icon(Icons.folder),
                title: Text("Load from file${PlatformEnv.isWeb ? " (Web not sopported currently)" : ""}"),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();

                    if (result != null) {
                      setState(() {
                        player.dispose();
                        player = Player.create(media: PlayerMedia.file(result.files.single.path!))..init();
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          const Divider(),
          // widget for log
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 11, color: Color.fromARGB(166, 177, 177, 177)),
              child: StreamBuilder<PlayerEvent>(
                  stream: player.streams.events,
                  builder: (context, snapshot) {
                    return Column(
                      children: [
                        const Text(
                          "Logs",
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 10),
                        Table(
                          border: TableBorder.all(
                            width: 1,
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          columnWidths: const {
                            0: FractionColumnWidth(0.2),
                            1: FractionColumnWidth(0.8),
                          },
                          children: [
                            TableRow(children: [
                              const Text("Duration", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(player.duration.toString()),
                            ]),
                            TableRow(children: [
                              const Text("Position", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(player.position.toString()),
                            ]),
                            TableRow(children: [
                              const Text("Volume", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(player.volume.toString()),
                            ]),
                            TableRow(children: [
                              const Text("Speed", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(player.speed.toString()),
                            ]),
                            TableRow(children: [
                              const Text("Loop", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(player.loop.toString()),
                            ]),
                            TableRow(children: [
                              const Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(player.status.toString()),
                            ]),
                            TableRow(children: [
                              const Text("Media type", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(player.media.type.toString()),
                            ]),
                            TableRow(children: [
                              const Text("Media resource", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(player.media.resource.toString()),
                            ]),
                            TableRow(children: [
                              const Text("Platform Adaptive Player", style: TextStyle(fontWeight: FontWeight.bold)),
                              // table display the platform adaptive player from the map Player.platforms
                              Table(
                                border: TableBorder.all(width: 1, color: Colors.grey.withOpacity(0.5)),
                                children: [
                                  for (var platform in Player.platforms.entries)
                                    TableRow(children: [
                                      Text("${platform.key}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text("${platform.value?.name}"),
                                    ]),
                                ],
                              ),
                            ]),
                          ],
                        ),
                      ],
                    );
                  }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 60,
          child: PlayerBar(player: player, options: [
            ValueListenableBuilder(
              valueListenable: isDarkMode,
              builder: (context, snapshot, w) {
                return SwitchListTile(
                  secondary: const Icon(Icons.brightness_2),
                  title: const Text("Dark mode"),
                  value: isDarkMode.value,
                  onChanged: (bool value) {
                    isDarkMode.value = !isDarkMode.value;
                  },
                );
              },
            ),
          ]),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     MethodChannel channel = const MethodChannel('kplayer_channel');
      //     var result = await channel.invokeMethod(
      //         'GetSystemVolume', 'Hello from flutter');
      //     print("result.toString()");
      //     print(result);
      //   },
      //   child: const Icon(Icons.replay),
      // ),
    );
  }
}
