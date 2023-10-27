import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
//import 'dart:developer' as dev;

class AppInfoOverlay extends StatefulWidget {
  //const AppInfoOverlay({super.key});
  const AppInfoOverlay(
      {Key? key,
      required this.appInfo,
      required this.closeWidgetCallbackFunction,
      required this.addAppToFavorite,
      required this.removeAppFromFavorite,
      required this.checkIfAppIsFavorite})
      : super(key: key);
  final AppInfo appInfo;
  final Function closeWidgetCallbackFunction;
  final Function addAppToFavorite;
  final Function removeAppFromFavorite;
  final Function checkIfAppIsFavorite;

  @override
  State<AppInfoOverlay> createState() => _AppInfoOverlayState();
}

class _AppInfoOverlayState extends State<AppInfoOverlay> {
  @override
  Widget build(BuildContext context) {
    return body();
  }

  Widget backButton() {
    return Row(children: [
      TextButton.icon(
        onPressed: () {
          widget.closeWidgetCallbackFunction();
        },
        onLongPress: () {},
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.arrow_back),
        label: const Text("Back"),
      ),
    ]);
  }

  Widget logo(AppInfo appInfo) {
    return Center(
      child: Image.memory(
        appInfo.icon!,
        width: 50,
        height: 50,
      ),
    );
  }

  Widget appname(AppInfo appInfo) {
    return Text(
      appInfo.name!,
      style: Theme.of(context).textTheme.headlineLarge,
    );
  }

  Widget favoriteButton(AppInfo appInfo) {
    String buttonText = "Loading...";

    bool isFav = widget.checkIfAppIsFavorite(appInfo.name);

    isFav == true
        ? buttonText = "Remove ${appInfo.name} from favorites."
        : buttonText = "Add ${appInfo.name} as favorite.";

    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        setState(() {
          isFav == true
              ? widget.removeAppFromFavorite(appInfo.name)
              : widget.addAppToFavorite(appInfo.name);
        });
      },
      child: Text(buttonText),
    );
  }

  Widget body() {
    AppInfo appInfo = widget.appInfo;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 50, 20, 50),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(204, 0, 0, 0),
      ),
      child: Column(
        children: [
          backButton(),
          logo(appInfo),
          appname(appInfo),
          favoriteButton(appInfo),
        ],
      ),
    );
  }
}
