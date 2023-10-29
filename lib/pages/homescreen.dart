import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../drawers/homescreen_drawer.dart';
import '../appbars/appbar_widget.dart';
import '../overlays/appinfo_overlay.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'dart:developer' as dev;
import '../settings/settings.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> with settings_mixin {
  OverlayEntry? appInfoOverlayEntry;
  List<String> favoriteApps = [];
  List<String> favoriteGroups = [];

  Widget app(String name, context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
      child: Container(
        decoration: BoxDecoration(
            color: const Color.fromARGB(204, 0, 0, 0),
            borderRadius: BorderRadius.circular(10)),
        width: 1000,
        height: 50,
        alignment: AlignmentDirectional.center,
        child: Text(
          name,
          style: Theme.of(this.context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget searchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(204, 0, 0, 0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const TextField(
          style: TextStyle(
            color: Colors.white,
          ),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            hintText: "Search:",
            hintStyle: TextStyle(color: Color.fromARGB(255, 105, 105, 105)),
          ),
        ),
      ),
    );
  }

  void closeAppInfoOverlay() {
    appInfoOverlayEntry?.remove();
    appInfoOverlayEntry = null;
  }

  void showAppInfoOverlay(AppInfo appInfo) {
    appInfoOverlayEntry = OverlayEntry(
      builder: (context) => AppInfoOverlay(
        appInfo: appInfo,
        closeWidgetCallbackFunction: closeAppInfoOverlay,
        addAppToFavorite: addAppToFavorite,
        removeAppFromFavorite: removeAppFromFavorite,
        checkIfAppIsFavorite: checkIfAppIsFavorite,
      ),
    );
    final overlay = Overlay.of(context);
    overlay.insert(appInfoOverlayEntry!);
  }

  Widget createWidgetFromAppInfo(AppInfo appInfo) {
    return Container(
      margin: const EdgeInsetsDirectional.only(top: 5, bottom: 5),
      decoration: BoxDecoration(
          color: const Color.fromARGB(204, 0, 0, 0),
          borderRadius: BorderRadius.circular(10)),
      child: TextButton.icon(
          onLongPress: () {
            //removeAppFromFavorite(appInfo.name!);
            showAppInfoOverlay(appInfo);
          },
          onPressed: () {
            //setState(() {
            InstalledApps.startApp(appInfo.packageName!);
            // });
          },
          icon: Image.memory(appInfo.icon!, width: 25, height: 25),
          label: Text(appInfo.name!,
              style: Theme.of(context).textTheme.titleMedium)),
    );
  }

  Widget createWidgetFromListOfApps(List<AppInfo>? listAppInfo) {
    return Column(
      children: [
        for (AppInfo appInfo in listAppInfo!) createWidgetFromAppInfo(appInfo),
      ],
    );
  }

  void addAppToFavorite(String appName) {
    if (favoriteApps.contains(appName)) return;

    setState(() {
      Future<SharedPreferences> prefs = SharedPreferences.getInstance();
      prefs.then((fPrefs) {
        favoriteApps.add(appName);
        fPrefs.setStringList("FavoriteApps", favoriteApps);
      });
    });
  }

  void removeAppFromFavorite(String appName) {
    if (!favoriteApps.contains(appName)) return;

    setState(() {
      Future<SharedPreferences> prefs = SharedPreferences.getInstance();
      prefs.then((fPrefs) {
        favoriteApps.remove(appName);
        fPrefs.setStringList("FavoriteApps", favoriteApps);
      });
    });
  }

  bool checkIfAppIsFavorite(String appName) {
    if (favoriteApps.contains(appName)) {
      return true;
    }
    return false;
  }

  void createFavoriteGroup(String group) {
    if (favoriteGroups.contains(group)) return;

    favoriteGroups.add(group);

    Future<SharedPreferences> futurePrefs = SharedPreferences.getInstance();
    futurePrefs.then((prefs) {
      prefs.setStringList("FavoriteGroups", favoriteGroups);
    });
  }

  List<String> listAllFavoriteGroups() {
    Future<SharedPreferences> futurePrefs = SharedPreferences.getInstance();

    futurePrefs.then((prefs) {
      if (prefs.containsKey("FavoriteGroups")) {
        favoriteGroups = prefs.getStringList("FavoriteGroups")!;
      }
    });

    dev.log(favoriteGroups.toString());

    return favoriteGroups;
  }

  void deleteFavoriteGroup(String group) {
    if (!favoriteGroups.contains(group)) return;

    favoriteGroups.remove(group);

    Future<SharedPreferences> futurePrefs = SharedPreferences.getInstance();
    futurePrefs.then((prefs) {
      prefs.setStringList("FavoriteGroups", favoriteGroups);
    });
  }

  Future<List<AppInfo>> futureListInstalledFavs() async {
    List<AppInfo> listInstalledFavs = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("FavoriteApps")) {
      favoriteApps = prefs.getStringList("FavoriteApps")!;
    }

    List<AppInfo> listAppInfo =
        await InstalledApps.getInstalledApps(true, true);

    for (AppInfo appInfo in listAppInfo) {
      if (favoriteApps.contains(appInfo.name)) {
        listInstalledFavs.add(appInfo);
      }
    }

    return listInstalledFavs;
  }

  Widget body() {
    Future<List<AppInfo>> futureListAppInfo = futureListInstalledFavs();

    return Center(
      child: ListView(
        children: [
          FutureBuilder(
              future: futureListAppInfo,
              builder: (context, futureData) {
                if (futureData.hasData) {
                  return createWidgetFromListOfApps(futureData.data);
                } else {
                  return const Text("Loading...");
                }
              }),
          FutureBuilder(
              future: futureListAppInfo,
              builder: (context, futureData) {
                return Column(children: [
                  Text(favoriteGroups.toString()),
                  Text(favoriteApps.toString())
                ]);
              }),

          TextButton(
              onPressed: () {
                setState(() {
                  createFavoriteGroup("Social");
                });
                ("Social");
              },
              onLongPress: () {
                setState(() {
                  createFavoriteGroup("Media");
                });
              },
              child: const Text("Create Social/Media")),
          TextButton(
              onPressed: () {
                setState(() {
                  deleteFavoriteGroup("Social");
                });
                ("Social");
              },
              onLongPress: () {
                setState(() {
                  deleteFavoriteGroup("Media");
                });
              },
              child: const Text("Delete Social/Media"))
          //searchField(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: appBarWidget("Launcher"),
      drawer: DrawerWidget(
        addAppToFavorite: addAppToFavorite,
        removeAppFromFavorite: removeAppFromFavorite,
        checkIfAppIsFavorite: checkIfAppIsFavorite,
      ),
      body: body(),
    );
  }
}
