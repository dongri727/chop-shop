import 'package:chop_shop/menu/menu_data.dart';
import 'package:flutter/material.dart';

typedef NavigateTo(MenuItemData item);

/// This widget displays the single menu section of the [MainMenuWidget].
/// There are main sections, as loaded from the menu.json file in the　assets folder.

class MenuSection extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color accentColor;
  final List<MenuItemData> menuOptions;
  final NavigateTo navigateTo;

  const MenuSection(this.title, this.backgroundColor, this.accentColor,
      this.menuOptions, this.navigateTo,
      {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20.0,
              color: accentColor,
            ),
          ),
        ),
        SingleChildScrollView(
          child: Column(children: menuOptions.map<Widget>((item) {
            return Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: ListTile(
                tileColor: backgroundColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                title: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 16.0,
                  ),
                ),
                onTap: () => navigateTo(item),
              ),
            );
          }).toList(),
          ),
        )
      ],
    );
  }
}
