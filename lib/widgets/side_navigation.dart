import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SideNavigationDrawer extends StatelessWidget {

  final Function onTap;
  SideNavigationDrawer({this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DrawerHeader(
              decoration:
              BoxDecoration(color: Theme.of(context).backgroundColor),
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 3,
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).primaryColor,
              ),
              title: Text('Logout'),
              onTap: () => onTap(1),
            ),
            Divider(
              height: 2,
            ),
            ListTile(
              leading: Icon(
                Icons.account_balance_wallet,
                color: Theme.of(context).primaryColor,
              ),
              title: Text('Wallet'),
              onTap: () => onTap(2),
            ),

            ListTile(
              leading: Icon(
                Icons.qr_code_scanner,
                color: Theme.of(context).primaryColor,
              ),
              title: Text('Scan QR code'),
              onTap: () => onTap(3),
            ),

            ListTile(
              leading: Icon(
                Icons.timer,
                color: Theme.of(context).primaryColor,
              ),
              title: Text('Time Remaining'),
              onTap: () => onTap(4),
            ),
            ListTile(
              leading: Icon(
                Icons.help_outline,
                color: Theme.of(context).primaryColor,
              ),
              title: Text('Terms & Conditions'),
              onTap: () => onTap(5),
            ),
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
              ),
              title: Text('Terms of Service'),
              onTap: () => onTap(6),
            ),
            ListTile(
              leading: Icon(
                Icons.feedback,
                color: Theme.of(context).primaryColor,
              ),
              title: Text('FeedBack'),
              onTap: () => onTap(7),
            ),
          ],
        ),
      ),
    );
  }
}