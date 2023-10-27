import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../drawers/homescreen_drawer.dart';
import '../appbars/appbar_widget.dart';
import '../overlays/appinfo_overlay.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'dart:developer' as dev;

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  OverlayEntry? appInfoOverlayEntry;
  List<String> favoriteApps = [];

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

  List<String> listAllFavoriteGroups() {
    List<String> favoriteGroups = [];

    Future<SharedPreferences> futurePrefs = SharedPreferences.getInstance();

    futurePrefs.then((prefs) {
      if (prefs.containsKey("FavoriteGroups")) {
        favoriteGroups = prefs.getStringList("FavoriteGroups")!;
      }
    });

    dev.log(favoriteGroups.toString());
    return favoriteGroups;
  }

  Widget body() {
    Future<List<AppInfo>> futureListAppInfo;
    List<AppInfo> listInstalledFavs = [];

    futureListAppInfo = InstalledApps.getInstalledApps(true, true);
    Future<SharedPreferences> prefs = SharedPreferences.getInstance();

    prefs.then((value) {
      if (value.containsKey("FavoriteApps")) {
        favoriteApps = value.getStringList("FavoriteApps")!;
      }
      futureListAppInfo.then((thenInfo) {
        for (AppInfo appInfo in thenInfo) {
          if (favoriteApps.contains(appInfo.name)) {
            //dev.log("Hittade " + appInfo.name!);
            listInstalledFavs.add(appInfo);
          }
        }
      });
    });

    return Center(
      //child: Column(
      child: ListView(
        //mainAxisAlignment: MainAxisAlignment.center,

        children: [
          FutureBuilder(
              future: futureListAppInfo,
              builder: (context, futureData) {
                if (futureData.hasData) {
                  return createWidgetFromListOfApps(listInstalledFavs);
                } else {
                  return const Text("Loading...");
                }
              }),
          //searchField(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    listAllFavoriteGroups();
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
