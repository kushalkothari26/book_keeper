import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:book_keeper/themes/theme_provider.dart';
import 'package:provider/provider.dart';
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'),backgroundColor: Colors.transparent,foregroundColor: Theme.of(context).colorScheme.primary,),
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10)
        ),
        margin: const EdgeInsets.all(25),
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Dark Mode",style:TextStyle(color: Theme.of(context).colorScheme.onPrimary,fontSize: 16),),
            CupertinoSwitch(value: Provider.of<ThemeProvider>(context,listen:false).isDarkMode,
                onChanged: (value)=>Provider.of<ThemeProvider>(context,listen:false).toggleTheme()
            )],
        ),
      ),
    );
  }
}
