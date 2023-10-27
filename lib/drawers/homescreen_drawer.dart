import 'package:flutter/material.dart';
import 'package:testproject/overlays/appfolder_overlay.dart';

class DrawerWidget extends StatefulWidget {
  //const DrawerWidget({super.key});
  const DrawerWidget({
    Key? key,
    required this.addAppToFavorite,
    required this.removeAppFromFavorite,
    required this.checkIfAppIsFavorite,
  }) : super(key: key);
  final Function addAppToFavorite;
  final Function removeAppFromFavorite;
  final Function checkIfAppIsFavorite;
  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  OverlayEntry? entry;

  Widget drawerItem(title, insert) {
    return Container(
      padding: const EdgeInsetsDirectional.only(top: 0),
      child: TextButton(
        onPressed: () {
          insert();
        },
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  Widget goToNavRoute(title, navRoute) {
    return drawerItem(title, () {
      Navigator.pushNamed(context, navRoute);
    });
  }

  Widget openWithOverlay(title, action) {
    return drawerItem(title, action);
  }

  void closeOverylayAppFolder() {
    entry?.remove();
    entry = null;
  }

  Widget overlayContainerWithBackButton(classToInsert) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 50, 20, 50),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(125, 0, 0, 0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: closeOverylayAppFolder,
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back"),
              ),
            ],
          ),
          classToInsert,
        ],
      ),
    );
  }

  showOverlayAppFolder() {
    entry = OverlayEntry(
      builder: (context) => overlayContainerWithBackButton(
        AppFolderOverlay(
          closeWidgetCallbackFunction: closeOverylayAppFolder,
          addAppToFavorite: widget.addAppToFavorite,
          removeAppFromFavorite: widget.removeAppFromFavorite,
          checkIfAppIsFavorite: widget.checkIfAppIsFavorite,
        ),
      ),
    );
    final overlay = Overlay.of(context);
    overlay.insert(entry!);
    Navigator.pop(context); //Hide drawer
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: const Color.fromARGB(207, 0, 0, 0),
      child: Container(
        margin: const EdgeInsets.only(top: 50),
        child: Column(children: [
          const Icon(Icons.launch),
          Text(
            style: Theme.of(context).textTheme.titleMedium,
            "Andys Launcher",
          ),
          Container(
            padding: const EdgeInsets.only(
              top: 50,
            ),
          ),
          //goToNavRoute("Homescreen", "/"),
          openWithOverlay("AppFolder", showOverlayAppFolder),
        ]),
      ),
    );
  }
}
