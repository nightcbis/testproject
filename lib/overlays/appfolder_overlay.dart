import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'appinfo_overlay.dart';
//import 'dart:developer' as dev;

class AppFolderOverlay extends StatefulWidget {
  //const AppFolder({super.key});
  const AppFolderOverlay(
      {Key? key,
      required this.closeWidgetCallbackFunction,
      required this.addAppToFavorite,
      required this.removeAppFromFavorite,
      required this.checkIfAppIsFavorite})
      : super(key: key);
  final Function addAppToFavorite;
  final Function removeAppFromFavorite;
  final Function closeWidgetCallbackFunction;
  final Function checkIfAppIsFavorite;
  @override
  State<AppFolderOverlay> createState() => _AppFolderOverlayState();
}

class _AppFolderOverlayState extends State<AppFolderOverlay> {
  OverlayEntry? appInfoOverlayEntry;

  @override
  Widget build(BuildContext context) {
    return body(context);
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
        addAppToFavorite: widget.addAppToFavorite,
        removeAppFromFavorite: widget.removeAppFromFavorite,
        checkIfAppIsFavorite: widget.checkIfAppIsFavorite,
      ),
    );
    final overlay = Overlay.of(context);
    overlay.insert(appInfoOverlayEntry!);
  }

  Widget gridItem(context, AppInfo appInfo) {
    return Container(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          TextButton.icon(
            onLongPress: () {
              //widget.addAppToFavorite(app.name!);
              showAppInfoOverlay(appInfo);
            },
            onPressed: () {
              widget.closeWidgetCallbackFunction();
              InstalledApps.startApp(appInfo.packageName!);
            },
            icon: Image.memory(appInfo.icon!, width: 25, height: 25),
            label: Text(appInfo.name!,
                style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }

  Widget widgetFromListOfApps(context, List<AppInfo>? appar) {
    return Flexible(
      child: GridView.count(
        crossAxisCount: 3,
        children: [for (AppInfo app in appar!) gridItem(context, app)],
      ),
    );
  }

  Widget body(context) {
    List<AppInfo> iApps = [];
    Future<List<AppInfo>> iAppsFuture =
        InstalledApps.getInstalledApps(true, true);
    iAppsFuture.then(
      (iAppList) {
        for (AppInfo app in iAppList) {
          iApps.add(app);
        }
      },
    );
    return FutureBuilder(
        future: iAppsFuture,
        builder: (context, futureData) {
          if (futureData.hasData) {
            return widgetFromListOfApps(context, futureData.data);
          } else {
            return const Text("Loading...");
          }
        });
  }
}
